import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum OnboardingStatus { initial, loading, notSeen, seen }

class OnboardingState {
  final OnboardingStatus status;
  final bool isCompleted;

  OnboardingState({required this.status, required this.isCompleted});

  factory OnboardingState.initial() =>
      OnboardingState(status: OnboardingStatus.initial, isCompleted: false);

  OnboardingState copyWith({OnboardingStatus? status, bool? isCompleted}) {
    return OnboardingState(
      status: status ?? this.status,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class OnboardingCubit extends Cubit<OnboardingState> {
  final SharedPreferences prefs;

  OnboardingCubit({required this.prefs}) : super(OnboardingState.initial()) {
    checkOnboardingStatus();
  }

  Future<void> checkOnboardingStatus() async {
    emit(state.copyWith(status: OnboardingStatus.loading));
    try {
      final isCompleted = prefs.getBool('onboarding_completed') ?? false;
      emit(
        state.copyWith(
          status: isCompleted
              ? OnboardingStatus.seen
              : OnboardingStatus.notSeen,
          isCompleted: isCompleted,
        ),
      );
    } catch (e) {
      debugPrint('Onboarding Status Check Error: $e');
      emit(
        state.copyWith(status: OnboardingStatus.notSeen, isCompleted: false),
      );
    }
  }

  Future<void> completeOnboarding() async {
    emit(state.copyWith(status: OnboardingStatus.loading));
    try {
      await prefs.setBool('onboarding_completed', true);
      emit(state.copyWith(status: OnboardingStatus.seen, isCompleted: true));
    } catch (e) {
      debugPrint('Complete Onboarding Error: $e');
      emit(
        state.copyWith(status: OnboardingStatus.notSeen, isCompleted: false),
      );
    }
  }
}
