import 'package:flutter/material.dart';

class AppStyles {
  // ===== Цвета =====
  static const Color background = Color.fromARGB(255, 0, 0, 0);
  static const Color dashboardCard = Color.fromARGB(255, 40, 37, 63);
  static const Color accentGreen = Colors.greenAccent;
  static const Color accentRed = Colors.redAccent;
  static const Color fab = Color(0xFF7500B9);
  static const Color primary = Color(0xFF1E1E2F);      // тёмно-синий/фиолетовый
  static const Color secondary = Color(0xFF3A3A5C);    // синий акцент
  static const Color accent = Color.fromARGB(255, 136, 39, 255);       // светлый фиолетовый
  static const Color textPrimary = Color.fromARGB(255, 255, 255, 255);  // светлый серый
  static const Color textSecondary = Color(0xFFB0B0B0);// серый для вспомогательного текста
  static const Color selected = Color.fromARGB(255, 162, 0, 255);
  static const Color unselected = Color.fromARGB(255, 255, 253, 253);
  static const String fontFamily = 'Roboto';

  

  // ===== Текстовые стили =====
  static const TextStyle overviewLabel = TextStyle(
    color: accentGreen,
    fontSize: 12,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle pageTitle = TextStyle(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle pageSubtitle = TextStyle(
    color: Colors.white70,
    fontSize: 14,
  );

  static const TextStyle sectionTitle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );

  static const TextStyle dashboardTitle = TextStyle(
    color: Colors.white70,
    fontSize: 12,
  );

  static const TextStyle dashboardValue = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle dashboardChange = TextStyle(
    fontSize: 12,
  );

  static const TextStyle alertUnit = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle alertMessage = TextStyle(
    color: Colors.white70,
  );

  static const TextStyle alertTime = TextStyle(
    color: Colors.white38,
    fontSize: 12,
  );
}
