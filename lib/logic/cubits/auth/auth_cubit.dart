import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:classtrack/logic/api_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated }

enum UserRole { student, lecturer }

class AuthState {
  final AuthStatus status;
  final bool isAuthenticated;
  final UserRole? userRole;
  final String? error;

  AuthState({
    required this.status,
    required this.isAuthenticated,
    this.userRole,
    this.error,
  });

  factory AuthState.initial() =>
      AuthState(status: AuthStatus.initial, isAuthenticated: false);

  AuthState copyWith({
    AuthStatus? status,
    bool? isAuthenticated,
    UserRole? userRole,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userRole: userRole ?? this.userRole,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthCubit extends Cubit<AuthState> {
  final SharedPreferences prefs;
  final ApiService api = ApiService();

  AuthCubit({required this.prefs}) : super(AuthState.initial()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    debugPrint('AuthCubit: Checking auth status...');
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      // Add a timeout to prevent hanging on Web if storage is slow
      final token = await api.getToken().timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          debugPrint('AuthCubit: Token check timed out');
          return null;
        },
      );

      if (token == null) {
        debugPrint('AuthCubit: No token found, unauthenticated');
        emit(state.copyWith(status: AuthStatus.unauthenticated, isAuthenticated: false));
        return;
      }

      debugPrint('AuthCubit: Token found, verifying...');
      // Verify token by getting user info
      final response = await api.dio.get(api.v1('/users/me'));
      final roleStr = response.data['role'];
      final userRole = roleStr == 'lecturer' ? UserRole.lecturer : UserRole.student;

      debugPrint('AuthCubit: Token verified, role: $roleStr');
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          isAuthenticated: true,
          userRole: userRole,
        ),
      );
    } catch (e) {
      debugPrint('AuthCubit: Auth Status Check Error: $e');
      if (e is DioException) {
        debugPrint('AuthCubit: Dio Error details: ${e.response?.data}');
      }
      await api.deleteToken();
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          isAuthenticated: false,
        ),
      );
    }
  }

  Future<void> login(String email, String password, UserRole role) async {
    debugPrint('AuthCubit: login started for $email');
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      debugPrint('AuthCubit: Sending POST to /api/v1/auth/token');
      final response = await api.dio.post(
        '/api/v1/auth/token',
        data: {
          'username': email,
          'password': password,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      final token = response.data['access_token'];
      debugPrint('AuthCubit: Login successful, saving token');
      await api.saveToken(token);
      
      // Get user info to confirm role
      debugPrint('AuthCubit: Fetching user info...');
      final userResponse = await api.dio.get(api.v1('/users/me'));
      final roleStr = userResponse.data['role'];
      final userRole = roleStr == 'lecturer' ? UserRole.lecturer : UserRole.student;

      debugPrint('AuthCubit: User info fetched, role: $roleStr');
      await prefs.setBool('is_logged_in', true);
      
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          isAuthenticated: true,
          userRole: userRole,
        ),
      );
    } catch (e) {
      debugPrint('AuthCubit: Login Error: $e');
      String errorMessage = 'Login failed';
      if (e is DioException) {
        errorMessage = e.response?.data['detail'] ?? 'Invalid credentials';
        debugPrint('AuthCubit: Login Dio Error details: ${e.response?.data}');
      }
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          isAuthenticated: false,
          error: errorMessage,
        ),
      );
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String studentId,
    int? departmentId,
    UserRole role = UserRole.student,
  }) async {
    debugPrint('AuthCubit: register started for $email');
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      debugPrint('AuthCubit: Sending POST to /api/v1/auth/register');
      await api.dio.post(
        '/api/v1/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'role': role == UserRole.lecturer ? 'lecturer' : 'student',
          'student_id': studentId,
          'department_id': departmentId,
        },
      );
      debugPrint('AuthCubit: Registration successful, logging in...');
      await login(email, password, role);
    } catch (e) {
      debugPrint('AuthCubit: Registration Error: $e');
      String errorMessage = 'Registration failed';
      if (e is DioException) {
        errorMessage = e.response?.data['detail'] ?? 'Registration failed';
        debugPrint('AuthCubit: Registration Dio Error details: ${e.response?.data}');
      }
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          isAuthenticated: false,
          error: errorMessage,
        ),
      );
    }
  }

  Future<void> logout() async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await api.deleteToken();
      await prefs.setBool('is_logged_in', false);
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          isAuthenticated: false,
          userRole: null,
          clearError: true,
        ),
      );
    } catch (e) {
      debugPrint('Logout Error: $e');
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          isAuthenticated: false,
        ),
      );
    }
  }
}
