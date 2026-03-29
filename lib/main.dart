import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:classtrack/screens/splash_screen.dart';
import 'package:classtrack/theme/design_theme.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:classtrack/logic/cubits/onboarding/onboarding_cubit.dart';
import 'package:classtrack/logic/cubits/auth/auth_cubit.dart';
import 'package:classtrack/logic/cubits/theme/theme_cubit.dart';
import 'package:classtrack/logic/cubits/attendance/attendance_cubit.dart';
import 'package:classtrack/logic/services/cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize SharedPreferences and CacheService early, before any cubit runs
  final prefs = await SharedPreferences.getInstance();
  await CacheService().initWithPrefs(prefs);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => OnboardingCubit(prefs: prefs)),
        BlocProvider(create: (context) => AuthCubit(prefs: prefs)),
        BlocProvider(create: (context) => ThemeCubit(prefs: prefs)),
        BlocProvider(create: (context) => AttendanceCubit()..fetchAllData()),
      ],
      child: const ClassTrackApp(),
    ),
  );
}

class ClassTrackApp extends StatelessWidget {
  const ClassTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp(
          title: 'Class Track',
          theme: ClassTrackTheme.lightTheme,
          darkTheme: ClassTrackTheme.darkTheme,
          themeMode: themeMode,
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
