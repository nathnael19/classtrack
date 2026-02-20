import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:classtrack/screens/splash_screen.dart';
import 'package:classtrack/theme/design_theme.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:classtrack/logic/cubits/onboarding/onboarding_cubit.dart';
import 'package:classtrack/logic/cubits/auth/auth_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize SharedPreferences early to catch PlatformExceptions
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => OnboardingCubit(prefs: prefs)),
        BlocProvider(create: (context) => AuthCubit(prefs: prefs)),
      ],
      child: const ClassTrackApp(),
    ),
  );
}

class ClassTrackApp extends StatelessWidget {
  const ClassTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Class Track',
      theme: ClassTrackTheme.lightTheme,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
