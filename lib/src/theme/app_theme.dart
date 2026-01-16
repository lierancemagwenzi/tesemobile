import 'dart:ui';

import 'package:flutter/material.dart';

final Color brandGreen = const Color(0xFF00D285);
final Color brandRed = const Color(0xFFFF4B2B);

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: false,
  scaffoldBackgroundColor: Colors.white,
  primaryColor: brandGreen,
  cardColor: Colors.white,
  appBarTheme: const AppBarTheme(backgroundColor: Colors.white, elevation: 0),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
    bodyMedium: TextStyle(color: Colors.black87),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: false,
  scaffoldBackgroundColor: const Color(0xFF0D1117), // Deep dark navy/black
  primaryColor: brandGreen,
  cardColor: const Color(0xFF161B22), // Slightly lighter for cards
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0D1117),
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
