import 'package:flutter/material.dart';

class AppStyles {
    // Цвета
    static const primary = Colors.blue;
    static const errorColor = Colors.red;
    static const background = Colors.white;  // Белый цвет фона
    static const accent = Colors.green;      // Зеленый цвет акцента
    static const textPrimary = Colors.black; // Черный для основного текста
    static const textSecondary = Colors.grey; // Серый для вторичного текста
    
    // Тексты
    static const TextStyle titleText = TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
    );

    static const TextStyle bodyText = TextStyle(
        fontSize: 16,
    );

    // Отступы
    static const EdgeInsets screenPadding = EdgeInsets.all(16);
    static const EdgeInsets fieldPadding = EdgeInsets.symmetric(vertical: 8);

    // Контейнер с адаптивной шириной
    static BoxConstraints get containerConstraints => const BoxConstraints(
        maxWidth: 500,
    );
}
