import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../api_service.dart';

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
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final token = await api.getToken();
      if (token == null) {
        emit(state.copyWith(status: AuthStatus.unauthenticated, isAuthenticated: false));
        return;
      }

      // Verify token by getting user info
      final response = await api.dio.get(api.v1('/users/me'));
      final roleStr = response.data['role'];
      final userRole = roleStr == 'lecturer' ? UserRole.lecturer : UserRole.student;

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          isAuthenticated: true,
          userRole: userRole,
        ),
      );
    } catch (e) {
      debugPrint('Auth Status Check Error: $e');
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
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final formData = FormData.fromMap({
        'username': email,
        'password': password,
      });

      final response = await api.dio.post(
        '/api/v1/auth/token',
        data: formData,
      );

      final token = response.data['access_token'];
      await api.saveToken(token);
      
      // Get user info to confirm role
      final userResponse = await api.dio.get(api.v1('/users/me'));
      final roleStr = userResponse.data['role'];
      final userRole = roleStr == 'lecturer' ? UserRole.lecturer : UserRole.student;

      await prefs.setBool('is_logged_in', true);
      
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          isAuthenticated: true,
          userRole: userRole,
        ),
      );
    } catch (e) {
      debugPrint('Login Error: $e');
      String errorMessage = 'Login failed';
      if (e is DioException) {
        errorMessage = e.response?.data['detail'] ?? 'Invalid credentials';
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
