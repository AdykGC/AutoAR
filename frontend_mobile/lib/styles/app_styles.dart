import 'package:flutter/material.dart';

class AppStyles {
    // Цвета
    static const primaryColor = Colors.blue;
    static const errorColor = Colors.red;
    
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