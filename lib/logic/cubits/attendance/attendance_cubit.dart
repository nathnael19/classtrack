import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:classtrack/logic/api_service.dart';
import 'package:flutter/foundation.dart';

enum AttendanceStatus { initial, loading, success, failure }

class AttendanceState {
  final AttendanceStatus status;
  final List<dynamic> activeSessions;
  final List<dynamic> upcomingSessions;
  final List<dynamic> history;
  final Map<String, dynamic>? summary;
  final Map<String, dynamic>? userData;
  final String? error;

  AttendanceState({
    required this.status,
    this.activeSessions = const [],
    this.upcomingSessions = const [],
    this.history = const [],
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
    Map<String, dynamic>? summary,
    Map<String, dynamic>? userData,
    String? error,
  }) {
    return AttendanceState(
      status: status ?? this.status,
      activeSessions: activeSessions ?? this.activeSessions,
      upcomingSessions: upcomingSessions ?? this.upcomingSessions,
      history: history ?? this.history,
      summary: summary ?? this.summary,
      userData: userData ?? this.userData,
      error: error,
    );
  }
}

class AttendanceCubit extends Cubit<AttendanceState> {
  final ApiService api = ApiService();

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
      ]);

      emit(state.copyWith(
        status: AttendanceStatus.success,
        activeSessions: (results[0] as Response).data as List<dynamic>,
        upcomingSessions: results[1] as List<dynamic>,
        history: results[2] as List<dynamic>,
        summary: results[3] as Map<String, dynamic>,
        userData: results[4] as Map<String, dynamic>,
      ));
    } catch (e) {
      debugPrint('AttendanceCubit Error: $e');
      emit(state.copyWith(
        status: AttendanceStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> refresh() => fetchAllData();
}
