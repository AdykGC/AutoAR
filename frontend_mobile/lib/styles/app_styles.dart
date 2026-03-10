import 'package:flutter/material.dart';

class AppStyles {

  // =======================================================
  // COLORS
  // =======================================================

  static const Color background = Color(0xFF000000);
  static const Color primary = Color(0xFF1E1E2F);
  static const Color secondary = Color(0xFF3A3A5C);

  static const Color accent = Color(0xFF8827FF);
  static const Color fab = Color(0xFF7500B9);

  static const Color dashboardCard = Color(0xFF28253F);

  static const Color accentGreen = Colors.greenAccent;
  static const Color accentRed = Colors.redAccent;

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0B0);

  static const Color selected = Color(0xFFA200FF);
  static const Color unselected = Colors.white70;

  static const String fontFamily = "Roboto";


  // =======================================================
  // TEXT STYLES
  // =======================================================

  static const TextStyle pageTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle pageSubtitle = TextStyle(
    fontSize: 14,
    color: textSecondary,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 14,
    color: textPrimary,
  );

  static const TextStyle smallText = TextStyle(
    fontSize: 12,
    color: textSecondary,
  );

  static const TextStyle dashboardTitle = TextStyle(
    fontSize: 12,
    color: textSecondary,
  );

  static const TextStyle dashboardValue = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle alertMessage = TextStyle(
    color: textSecondary,
  );

  static const TextStyle alertTime = TextStyle(
    fontSize: 12,
    color: Colors.white38,
  );


  // =======================================================
  // GLOBAL THEME
  // =======================================================

  static final ThemeData theme = ThemeData(

    fontFamily: fontFamily,

    scaffoldBackgroundColor: background,

    brightness: Brightness.dark,

    // ================= APPBAR =================

    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),

    // ================= COLOR SCHEME =================

    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: accent,
      surface: secondary,
    ),

    // ================= CARD =================

    cardTheme: CardThemeData(
      color: dashboardCard,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // ================= TEXT =================

    textTheme: const TextTheme(

      titleLarge: pageTitle,
      titleMedium: sectionTitle,

      bodyLarge: bodyText,
      bodyMedium: bodyText,

      bodySmall: smallText,
    ),

    // ================= INPUT FIELD =================

    inputDecorationTheme: InputDecorationTheme(

      filled: true,
      fillColor: secondary,

      labelStyle: const TextStyle(color: textSecondary),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white24),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white24),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: accent,
          width: 2,
        ),
      ),
    ),

    // ================= BUTTON =================

    elevatedButtonTheme: ElevatedButtonThemeData(

      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,

        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 20,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),

    // ================= TEXT BUTTON =================

    textButtonTheme: TextButtonThemeData(

      style: TextButton.styleFrom(
        foregroundColor: accent,
      ),
    ),

    // ================= FAB =================

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: fab,
      foregroundColor: Colors.white,
    ),

    // ================= BOTTOM NAV =================

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: primary,
      selectedItemColor: selected,
      unselectedItemColor: unselected,
      type: BottomNavigationBarType.fixed,
    ),

    // ================= SNACKBAR =================

    snackBarTheme: const SnackBarThemeData(
      backgroundColor: secondary,
      contentTextStyle: TextStyle(color: Colors.white),
    ),

    // ================= DIVIDER =================

    dividerTheme: const DividerThemeData(
      color: Colors.white24,
      thickness: 1,
    ),

  );
}
