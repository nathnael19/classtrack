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

  AttendanceState({
    required this.status,
    this.activeSessions = const [],
    this.upcomingSessions = const [],
    this.history = const [],
    this.enrolledCourses = const [],
    this.summary,
    this.userData,
    this.error,
  });

  factory AttendanceState.initial() => AttendanceState(status: AttendanceStatus.initial);

  AttendanceState copyWith({
    AttendanceStatus? status,
    List<dynamic>? activeSessions,
    List<dynamic>? upcomingSessions,
    List<dynamic>? history,
    List<dynamic>? enrolledCourses,
    Map<String, dynamic>? summary,
    Map<String, dynamic>? userData,
    String? error,
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
    );
  }
}

class AttendanceCubit extends Cubit<AttendanceState> {
  final ApiService api = ApiService();
  WebSocketChannel? _channel;

  AttendanceCubit() : super(AttendanceState.initial());

  Future<void> fetchAllData() async {
    emit(state.copyWith(status: AttendanceStatus.loading));
    try {
      final results = await Future.wait([
        api.dio.get(api.v1('/sessions/active')),
        api.getUpcomingSessions(),
        api.getAttendanceHistory(),
        api.getAttendanceSummary(),
        api.getCurrentUser(),
        api.getEnrolledCourses(),
      ]);

      final activeSessions = (results[0] as Response).data as List<dynamic>;

      emit(state.copyWith(
        status: AttendanceStatus.success,
        activeSessions: activeSessions,
        upcomingSessions: results[1] as List<dynamic>,
        history: results[2] as List<dynamic>,
        summary: results[3] as Map<String, dynamic>,
        userData: results[4] as Map<String, dynamic>,
        enrolledCourses: results[5] as List<dynamic>,
      ));

      _subscribeToSessions(activeSessions);
    } catch (e) {
      debugPrint('AttendanceCubit Error: $e');
      emit(state.copyWith(
        status: AttendanceStatus.failure,
        error: e.toString(),
      ));
    }
  }

  void _subscribeToSessions(List<dynamic> sessions) {
    // Close existing channel if any
    _channel?.sink.close();
    _channel = null;

    if (sessions.isEmpty) return;

    // Listen to the first active session for parity with web lecturer view
    final sessionId = sessions[0]['id'];
    final baseUrl = api.dio.options.baseUrl.replaceFirst('http', 'ws');
    final wsUrl = '$baseUrl/api/v1/sessions/$sessionId/ws';

    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _channel!.stream.listen((message) {
        final data = jsonDecode(message);
        if (data['type'] == 'attendance_recorded') {
          // If the broadcasted student ID matches the current user, or just to be safe, refresh all data
          refresh();
        }
      }, onError: (err) {
        debugPrint('WebSocket Error: $err');
      }, onDone: () {
        debugPrint('WebSocket Closed');
      });
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
