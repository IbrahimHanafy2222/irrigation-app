import 'package:flutter/material.dart';

class AppTheme {
  static const greenDeep = Color(0xFF0a2e1a);
  static const greenMid = Color(0xFF1a5c35);
  static const greenBright = Color(0xFF2d9e5f);
  static const greenLight = Color(0xFF7dcca0);
  static const greenPale = Color(0xFFe8f5ee);
  static const cream = Color(0xFFf7f5f0);
  static const amber = Color(0xFFe8a020);
  static const danger = Color(0xFFd94040);

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: cream,
    colorScheme: ColorScheme.light(
      primary: greenBright,
      secondary: greenMid,
      surface: cream,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'DMSerifDisplay',
        fontSize: 32,
        color: Color(0xFF0a1a10),
      ),
      displayMedium: TextStyle(
        fontFamily: 'DMSerifDisplay',
        fontSize: 24,
        color: Color(0xFF0a1a10),
      ),
      titleLarge: TextStyle(
        fontFamily: 'DMSerifDisplay',
        fontSize: 20,
        color: Color(0xFF0a1a10),
      ),
      bodyLarge: TextStyle(
        fontFamily: 'DMSans',
        fontSize: 14,
        color: Color(0xFF3d5c48),
      ),
      bodyMedium: TextStyle(
        fontFamily: 'DMSans',
        fontSize: 13,
        color: Color(0xFF3d5c48),
      ),
      labelSmall: TextStyle(
        fontFamily: 'DMSans',
        fontSize: 10,
        color: Color(0xFF7a9a84),
        letterSpacing: 0.1,
      ),
    ),
  );
}
