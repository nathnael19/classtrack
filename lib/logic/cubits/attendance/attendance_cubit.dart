import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:classtrack/logic/api_service.dart';
import 'package:classtrack/logic/services/cache_service.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

enum AttendanceStatus { initial, loading, success, failure }

class AttendanceState {
  final AttendanceStatus status;
  final List<dynamic> activeSessions;
  final List<dynamic> upcomingSessions;
  final List<dynamic> history;
  final List<dynamic> enrolledCourses;
  final Map<String, dynamic>? summary;
  final Map<String, dynamic>? userData;
  final String? error;

  /// True while secondary data (history, summary) is still being fetched
  /// after the initial fast data has already arrived.
  final bool isLoadingSecondary;

  AttendanceState({
    required this.status,
    this.activeSessions = const [],
    this.upcomingSessions = const [],
    this.history = const [],
    this.enrolledCourses = const [],
    this.summary,
    this.userData,
    this.error,
    this.isLoadingSecondary = false,
  });

  factory AttendanceState.initial() =>
      AttendanceState(status: AttendanceStatus.initial);

  AttendanceState copyWith({
    AttendanceStatus? status,
    List<dynamic>? activeSessions,
    List<dynamic>? upcomingSessions,
    List<dynamic>? history,
    List<dynamic>? enrolledCourses,
    Map<String, dynamic>? summary,
    Map<String, dynamic>? userData,
    String? error,
    bool? isLoadingSecondary,
  }) {
    return AttendanceState(
      status: status ?? this.status,
      activeSessions: activeSessions ?? this.activeSessions,
      upcomingSessions: upcomingSessions ?? this.upcomingSessions,
      history: history ?? this.history,
      enrolledCourses: enrolledCourses ?? this.enrolledCourses,
      summary: summary ?? this.summary,
      userData: userData ?? this.userData,
      error: error,
      isLoadingSecondary: isLoadingSecondary ?? this.isLoadingSecondary,
    );
  }
}

class AttendanceCubit extends Cubit<AttendanceState> {
  final ApiService api = ApiService();
  final CacheService _cache = CacheService();
  WebSocketChannel? _channel;

  AttendanceCubit() : super(AttendanceState.initial());

  Future<void> fetchAllData() async {
    await _cache.init();

    // -----------------------------------------------------------------------
    // Step 1: Show stale cached data immediately so the UI feels instant.
    // -----------------------------------------------------------------------
    final cachedUser = _cache.readStale<Map<String, dynamic>>(CacheKeys.userData);
    final cachedCourses = _cache.readStale<List<dynamic>>(CacheKeys.enrolledCourses);
    final cachedUpcoming = _cache.readStale<List<dynamic>>(CacheKeys.upcomingSessions);
    final cachedActive = _cache.readStale<List<dynamic>>(CacheKeys.activeSessions);
    final cachedSummary = _cache.readStale<Map<String, dynamic>>(CacheKeys.attendanceSummary);
    final cachedHistory = _cache.readStale<List<dynamic>>(CacheKeys.attendanceHistory);

    final hasCachedData = cachedUser != null;

    if (hasCachedData) {
      // Instantly show cached data — no loading state
      emit(AttendanceState(
        status: AttendanceStatus.success,
        userData: cachedUser,
        enrolledCourses: cachedCourses ?? [],
        upcomingSessions: cachedUpcoming ?? [],
        activeSessions: cachedActive ?? [],
        summary: cachedSummary,
        history: cachedHistory ?? [],
        isLoadingSecondary: true, // Indicate background refresh is happening
      ));
    } else {
      // First launch — show loading state
      emit(state.copyWith(status: AttendanceStatus.loading, isLoadingSecondary: true));
    }

    // -----------------------------------------------------------------------
    // Step 2: Fetch fresh data in the background.
    // Tier 1 — most visible (name, sessions, courses) — refreshed first.
    // -----------------------------------------------------------------------
    try {
      final tier1 = await Future.wait([
        api.getCurrentUser(),
        api.dio.get(api.v1('/sessions/active')),
        api.getUpcomingSessions(),
        api.getEnrolledCourses(),
      ]);

      final freshUser = tier1[0] as Map<String, dynamic>;
      final freshActive = (tier1[1] as Response).data as List<dynamic>;
      final freshUpcoming = tier1[2] as List<dynamic>;
      final freshCourses = tier1[3] as List<dynamic>;

      // Persist to cache
      await Future.wait([
        _cache.write(CacheKeys.userData, freshUser, ttlMinutes: CacheTTL.userData),
        _cache.write(CacheKeys.activeSessions, freshActive, ttlMinutes: CacheTTL.activeSessions),
        _cache.write(CacheKeys.upcomingSessions, freshUpcoming, ttlMinutes: CacheTTL.upcomingSessions),
        _cache.write(CacheKeys.enrolledCourses, freshCourses, ttlMinutes: CacheTTL.enrolledCourses),
      ]);

      emit(state.copyWith(
        status: AttendanceStatus.success,
        userData: freshUser,
        activeSessions: freshActive,
        upcomingSessions: freshUpcoming,
        enrolledCourses: freshCourses,
        isLoadingSecondary: true,
      ));

      _subscribeToSessions(freshActive);

      // -----------------------------------------------------------------------
      // Step 3: Tier 2 — heavier server-computed data (summary + history)
      // -----------------------------------------------------------------------
      final tier2 = await Future.wait([
        api.getAttendanceSummary(),
        api.getAttendanceHistory(),
      ]);

      final freshSummary = tier2[0] as Map<String, dynamic>;
      final freshHistory = tier2[1] as List<dynamic>;

      await Future.wait([
        _cache.write(CacheKeys.attendanceSummary, freshSummary, ttlMinutes: CacheTTL.attendanceSummary),
        _cache.write(CacheKeys.attendanceHistory, freshHistory, ttlMinutes: CacheTTL.attendanceHistory),
      ]);

      emit(state.copyWith(
        summary: freshSummary,
        history: freshHistory,
        isLoadingSecondary: false,
      ));
    } catch (e) {
      debugPrint('AttendanceCubit Error: $e');
      // If we had cached data, stay in success state. Otherwise fail.
      if (hasCachedData) {
        emit(state.copyWith(isLoadingSecondary: false));
      } else {
        emit(state.copyWith(
          status: AttendanceStatus.failure,
          error: e.toString(),
          isLoadingSecondary: false,
        ));
      }
    }
  }

  void _subscribeToSessions(List<dynamic> sessions) {
    _channel?.sink.close();
    _channel = null;

    if (sessions.isEmpty) return;

    final sessionId = sessions[0]['id'];
    final baseUrl = api.dio.options.baseUrl.replaceFirst('http', 'ws');
    final wsUrl = '$baseUrl/api/v1/sessions/$sessionId/ws';

    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _channel!.stream.listen(
        (message) {
          final data = jsonDecode(message);
          if (data['type'] == 'attendance_recorded') {
            refresh();
          }
        },
        onError: (err) => debugPrint('WebSocket Error: $err'),
        onDone: () => debugPrint('WebSocket Closed'),
      );
    } catch (e) {
      debugPrint('WebSocket Connection Error: $e');
    }
  }

  Future<void> refresh() => fetchAllData();

  @override
  Future<void> close() {
    _channel?.sink.close();
    return super.close();
  }
}
