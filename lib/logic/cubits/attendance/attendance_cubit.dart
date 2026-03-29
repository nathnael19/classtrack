import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:classtrack/logic/api_service.dart';
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

  // True while secondary data (history, summary) is still being fetched
  // after the initial fast data has already arrived.
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
  WebSocketChannel? _channel;

  AttendanceCubit() : super(AttendanceState.initial());

  Future<void> fetchAllData() async {
    emit(state.copyWith(status: AttendanceStatus.loading, isLoadingSecondary: true));

    try {
      // --- Tier 1: Fastest, most visible data (user name + active sessions + upcoming) ---
      // These are small payloads and appear at the top of the screen.
      // Emit them immediately so the user sees their name and today's info right away.
      final tier1 = await Future.wait([
        api.getCurrentUser(),                   // user name/avatar
        api.dio.get(api.v1('/sessions/active')), // live session banner
        api.getUpcomingSessions(),               // upcoming classes list
        api.getEnrolledCourses(),                // course chips
      ]);

      final activeSessions = (tier1[1] as Response).data as List<dynamic>;

      emit(state.copyWith(
        status: AttendanceStatus.success,
        userData: tier1[0] as Map<String, dynamic>,
        activeSessions: activeSessions,
        upcomingSessions: tier1[2] as List<dynamic>,
        enrolledCourses: tier1[3] as List<dynamic>,
        isLoadingSecondary: true, // Still waiting on history + summary
      ));

      // Subscribe to live session updates as soon as we know the active session
      _subscribeToSessions(activeSessions);

      // --- Tier 2: Heavier data (attendance summary + full history) ---
      // These take longer (computed on the server). Fetch them in the background
      // so the dashboard already feels responsive.
      final tier2 = await Future.wait([
        api.getAttendanceSummary(), // attendance % calculation
        api.getAttendanceHistory(), // full log
      ]);

      emit(state.copyWith(
        summary: tier2[0] as Map<String, dynamic>,
        history: tier2[1] as List<dynamic>,
        isLoadingSecondary: false,
      ));
    } catch (e) {
      debugPrint('AttendanceCubit Error: $e');
      emit(state.copyWith(
        status: AttendanceStatus.failure,
        error: e.toString(),
        isLoadingSecondary: false,
      ));
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
