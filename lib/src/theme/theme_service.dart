import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = "isDarkMode";

  // Save the preference
  Future<void> saveThemeMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode);
  }

  // Load the preference (defaults to light mode)
  Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isDarkMode = prefs.getBool(_themeKey) ?? false;
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }
}
