import 'package:flutter/material.dart';
import 'package:classtrack/screens/splash_screen.dart';
import 'package:classtrack/theme/design_theme.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const ClassTrackApp());
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
