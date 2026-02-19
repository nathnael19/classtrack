import 'package:flutter/material.dart';
import 'package:classtrack/screens/splash_screen.dart';
import 'package:classtrack/theme/design_theme.dart';

void main() {
  runApp(const ClassTrackApp());
}

class ClassTrackApp extends StatelessWidget {
  const ClassTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClassTrack',
      theme: ClassTrackTheme.lightTheme,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
