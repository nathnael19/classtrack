import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  final Dio dio = Dio(
    BaseOptions(
      baseUrl:
          'http://10.240.140.40:8000', // Root for auth/token, will add /api/v1 prefix for others
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  final _storage = const FlutterSecureStorage();

  ApiService._internal() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // Helper for v1 endpoints
  String v1(String path) => '/api/v1$path';

  Future<List<dynamic>> getEnrolledCourses() async {
    final response = await dio.get(v1('/courses/'));
    return response.data;
  }

  Future<List<dynamic>> getAttendanceHistory() async {
    final response = await dio.get(v1('/attendance/history'));
    return response.data;
  }

  Future<List<dynamic>> getUpcomingSessions() async {
    final response = await dio.get(v1('/sessions/upcoming'));
    return response.data;
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await dio.get(v1('/users/me'));
    return response.data;
  }

  Future<Map<String, dynamic>> getSession(int id) async {
    final response = await dio.get(v1('/sessions/$id'));
    return response.data;
  }

  Future<List<dynamic>> getSessions({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final Map<String, dynamic> queryParameters = {};
    if (startDate != null) {
      queryParameters['start_date'] = startDate.toUtc().toIso8601String();
    }
    if (endDate != null) {
      queryParameters['end_date'] = endDate.toUtc().toIso8601String();
    }
    final response = await dio.get(
      v1('/sessions/'),
      queryParameters: queryParameters,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await dio.put(v1('/users/me'), data: data);
    return response.data;
  }

  Future<List<dynamic>> getActiveSessions() async {
    final response = await dio.get(v1('/sessions/active'));
    return response.data;
  }

  Future<Map<String, dynamic>> getAttendanceSummary() async {
    final response = await dio.get(v1('/attendance/summary'));
    return response.data;
  }

  Future<List<dynamic>> getDepartments() async {
    final response = await dio.get(v1('/departments/'));
    return response.data;
  }
}
