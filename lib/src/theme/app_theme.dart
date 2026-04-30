import 'dart:ui';

import 'package:flutter/material.dart';

final Color brandGreen = const Color(0xFF00D285);
final Color brandRed = const Color(0xFFFF4B2B);

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: false, // It is better to use true and override M3 quirks
  scaffoldBackgroundColor: Colors.white,
  primaryColor: brandGreen,
  fontFamily: 'Figtree',
  // Use ColorScheme for better Material 3 compatibility
  colorScheme:
      ColorScheme.fromSeed(
        seedColor: brandGreen,
        brightness: Brightness.light,
      ).copyWith(
        surface: Colors.white,
        onSurface: Colors.black, // Ensures text on white is visible
      ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black, // Fixes "invisible" icons/text
    elevation: 0,
    scrolledUnderElevation: 0, // Prevents color change on scroll
    centerTitle: false,
    iconTheme: IconThemeData(color: Colors.black),
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),

  textTheme: const TextTheme(
    headlineLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
    bodyMedium: TextStyle(color: Colors.black87),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Figtree',
  useMaterial3: false,
  scaffoldBackgroundColor: Colors.black,
  // scaffoldBackgroundColor: const Color(0xFF0D1117), // Deep dark navy/black
  primaryColor: brandGreen,
  cardColor: const Color(0xFF161B22).withValues(alpha: 0.3), // Slightly lighter for cards
  appBarTheme:  AppBarTheme(
    backgroundColor: Color(0xFF0D1117).withValues(alpha: 0.3),
    elevation: 0,
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    bodyMedium: TextStyle(color: Colors.white70),
  ),

  colorScheme: ColorScheme.dark(
    primary: brandGreen,
    secondary: const Color(0xFFFFD700), // Tese Gold
    surface: const Color(0xFF161B22), // Used for Cards and Sheets
    onSurface: Colors.white, // Text color on top of surfaces
    outline: Colors.white10, // Border colors
  ),
);
