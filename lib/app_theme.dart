import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors (Islamic aesthetic)
  static const Color primaryColor = Color(0xFF0F3D3E); // Emerald/Teal Green
  static const Color secondaryColor = Color(0xFFB9B29F); // Warm Beige
  static const Color backgroundColor = Color(0xFFF5F1E9); // Light Sand/Beige
  static const Color accentColor = Color(0xFFDBB76C); // Gold (for highlights)
  static const Color smallContainer = Color(0xFFEDE7DD); // Light beige

  // Dark Theme Colors
  static const Color darkPrimaryColor = Color(0xFFDBB76C); // Golden highlight
  static const Color darkSecondaryColor = Color(0xFF9E9E9E); // Grey
  static const Color darkBackgroundColor = Color(0xFF1A1A1A); // Dark grey/black
  static const Color darkSmallContainer = Color(0xFF2D2D2D);
  static const Color darkBigContainer = Color(0xFF3D3D3D);

  // Light Theme
  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: accentColor,
      background: backgroundColor,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0F3D3E),
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: Color(0xFF3E3D3C),
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        color: Color(0xFF77736A),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    useMaterial3: true,
  );

  // Dark Theme
  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    primaryColor: darkPrimaryColor,
    scaffoldBackgroundColor: darkBackgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: darkSecondaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: darkPrimaryColor,
      primary: darkPrimaryColor,
      secondary: accentColor,
      background: darkBackgroundColor,
      brightness: Brightness.dark,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: Color(0xFFEAEAEA),
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        color: Colors.white70,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimaryColor,
        foregroundColor: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    useMaterial3: true,
  );

  // Helper methods
  static Color getCurrentBackgroundColor(bool isDarkMode) {
    return isDarkMode ? darkBackgroundColor : backgroundColor;
  }

  static Color getCurrentPrimaryColor(bool isDarkMode) {
    return isDarkMode ? darkPrimaryColor : primaryColor;
  }

  static Color getCurrentSmallContainer(bool isDarkMode) {
    return isDarkMode ? darkSmallContainer : smallContainer;
  }
}
