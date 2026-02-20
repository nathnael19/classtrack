import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:classtrack/screens/onboarding_screen.dart';
import 'package:classtrack/theme/design_theme.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:classtrack/logic/cubits/onboarding/onboarding_cubit.dart';
import 'package:classtrack/logic/cubits/auth/auth_cubit.dart';
import 'package:classtrack/screens/auth/login_screen.dart';
import 'package:classtrack/screens/student/student_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Remove the native splash as soon as the Flutter UI is ready to show splash_screen.dart
    FlutterNativeSplash.remove();

    // Standard delay for branding
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Access the cubits
    final onboardingCubit = context.read<OnboardingCubit>();
    final authCubit = context.read<AuthCubit>();

    // Wait for OnboardingCubit initialization
    if (onboardingCubit.state.status == OnboardingStatus.initial ||
        onboardingCubit.state.status == OnboardingStatus.loading) {
      await for (final state in onboardingCubit.stream) {
        if (state.status != OnboardingStatus.initial &&
            state.status != OnboardingStatus.loading) {
          break;
        }
      }
    }

    // Wait for AuthCubit initialization
    if (authCubit.state.status == AuthStatus.initial ||
        authCubit.state.status == AuthStatus.loading) {
      await for (final state in authCubit.stream) {
        if (state.status != AuthStatus.initial &&
            state.status != AuthStatus.loading) {
          break;
        }
      }
    }

    if (!mounted) return;

    final isOnboardingCompleted = onboardingCubit.state.isCompleted;
    final isAuthenticated = authCubit.state.isAuthenticated;

    Widget nextScreen;
    if (!isOnboardingCompleted) {
      nextScreen = const OnboardingScreen();
    } else if (!isAuthenticated) {
      nextScreen = const LoginScreen();
    } else {
      nextScreen = const StudentDashboardScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClassTrackTheme.primaryBlue,
      body: Stack(
        children: [
          // Background Dot Pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: CustomPaint(painter: DotPatternPainter()),
            ),
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),
                  // App Icon Container (Glassmorphism effect)
                  SvgPicture.asset(
                    'assets/logo.svg',
                    width: 200,
                    fit: BoxFit.cover,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // App Title
                  Text(
                    'ClassTrack',
                    style: ClassTrackTheme.lightTheme.textTheme.displayLarge
                        ?.copyWith(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                  ),
                  const SizedBox(height: 8),
                  // App Subtitle
                  Text(
                    'Secure Smart Attendance',
                    style: ClassTrackTheme.lightTheme.textTheme.bodyLarge
                        ?.copyWith(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                        ),
                  ),
                  const Spacer(flex: 2),
                  // Loading Section
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'INITIALIZING',
                    style: ClassTrackTheme.lightTheme.textTheme.labelLarge
                        ?.copyWith(
                          color: Colors.white.withValues(alpha: 0.6),
                          letterSpacing: 4,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const Spacer(flex: 1),
                  // Footer
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      'v2.4.0 • Powered by Geofencing',
                      style: ClassTrackTheme.lightTheme.textTheme.bodySmall
                          ?.copyWith(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 12,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5;

    const double spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
