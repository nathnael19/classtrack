import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final SharedPreferences prefs;
  static const String _themeKey = 'dark_mode';

  ThemeCubit({required this.prefs})
    : super(
        prefs.getBool(_themeKey) == true ? ThemeMode.dark : ThemeMode.light,
      );

  void toggleTheme(bool isDark) async {
    await prefs.setBool(_themeKey, isDark);
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  bool get isDarkMode => state == ThemeMode.dark;
}
