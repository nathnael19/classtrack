import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final bool isAuthenticated;
  final String? error;

  AuthState({required this.status, required this.isAuthenticated, this.error});

  factory AuthState.initial() =>
      AuthState(status: AuthStatus.initial, isAuthenticated: false);

  AuthState copyWith({
    AuthStatus? status,
    bool? isAuthenticated,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthCubit extends Cubit<AuthState> {
  final SharedPreferences prefs;

  AuthCubit({required this.prefs}) : super(AuthState.initial()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final isAuthenticated = prefs.getBool('is_logged_in') ?? false;
      emit(
        state.copyWith(
          status: isAuthenticated
              ? AuthStatus.authenticated
              : AuthStatus.unauthenticated,
          isAuthenticated: isAuthenticated,
        ),
      );
    } catch (e) {
      debugPrint('Auth Status Check Error: $e');
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          isAuthenticated: false,
        ),
      );
    }
  }

  Future<void> login(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      // Mock login delay
      await Future.delayed(const Duration(seconds: 1));

      // Simple validation for demonstration
      if (email.contains('@') && password.length >= 6) {
        await prefs.setBool('is_logged_in', true);
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            isAuthenticated: true,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            isAuthenticated: false,
            error: 'Invalid email or password',
          ),
        );
      }
    } catch (e) {
      debugPrint('Login Error: $e');
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          isAuthenticated: false,
          error: 'An error occurred during login: $e',
        ),
      );
    }
  }

  Future<void> logout() async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await prefs.setBool('is_logged_in', false);
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          isAuthenticated: false,
        ),
      );
    } catch (e) {
      debugPrint('Logout Error: $e');
      // Still set to unauthenticated on error for safety
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          isAuthenticated: false,
        ),
      );
    }
  }
}
