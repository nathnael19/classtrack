import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:classtrack/logic/api_service.dart';
import 'package:classtrack/logic/device_helper.dart';
import 'package:classtrack/logic/services/cache_service.dart';

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
      final token = await api.getToken();

      if (token == null) {
        debugPrint('AuthCubit: No token found, unauthenticated');
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          isAuthenticated: false,
        ));
        return;
      }

      debugPrint('AuthCubit: Token found, verifying...');
      // Verify token by getting user info
      final response = await api.dio.get(api.v1('/users/me'));
      final roleStr = response.data['role'];
      final userRole =
          roleStr == 'lecturer' ? UserRole.lecturer : UserRole.student;

      debugPrint('AuthCubit: Token verified, role: $roleStr');
      await prefs.setString('user_role', roleStr);
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
        final statusCode = e.response?.statusCode;
        debugPrint('AuthCubit: Dio Error status code: $statusCode');
        debugPrint('AuthCubit: Dio Error details: ${e.response?.data}');
        
        // Only delete token if it's explicitly an auth failure (401 or 403)
        if (statusCode == 401 || statusCode == 403) {
          debugPrint('AuthCubit: Invalid token, deleting and logging out');
          await api.deleteToken();
          await prefs.remove('user_role');
          await prefs.setBool('is_logged_in', false);
          emit(
            state.copyWith(
              status: AuthStatus.unauthenticated,
              isAuthenticated: false,
            ),
          );
          return;
        }
        
        // For network errors or 500s, assume the token might still be valid
        debugPrint('AuthCubit: Network or server error, retaining token for retry');
        final savedRole = prefs.getString('user_role');
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            isAuthenticated: true,
            userRole: savedRole == 'lecturer' ? UserRole.lecturer : UserRole.student, 
          ),
        );
      } else {
        // Non-dio errors (like storage failure)
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            isAuthenticated: false,
          ),
        );
      }
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
      await prefs.setString('user_role', roleStr);

      // Register device fingerprint for students (background, non-blocking)
      if (roleStr == 'student') {
        getDeviceInfo().then((info) async {
          try {
            await api.registerDevice(
              deviceId: info['device_id']!,
              deviceModel: info['device_model'],
            );
            debugPrint('AuthCubit: Device registered successfully');
          } catch (e) {
            debugPrint('AuthCubit: Device registration failed: $e');
          }
        });
      }

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
    String? section,
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
          'section': section,
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
      await prefs.remove('user_role');
      // Clear cached attendance data so it doesn't show up for the next login
      final cache = CacheService();
      await cache.init();
      await cache.clearAll();
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

  Future<void> forgotPassword(String email) async {
    debugPrint('AuthCubit: forgotPassword started for $email');
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      await api.forgotPassword(email);
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    } catch (e) {
      debugPrint('AuthCubit: ForgotPassword Error: $e');
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        error: 'Failed to send reset email. Please try again later.',
      ));
    }
  }
}
