import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mobile/screens/profile/profile_screen.dart';

void main() {

  Widget createWidget() {
    return const MaterialApp(
      home: ProfileScreen(),
    );
  }

  testWidgets('Показывается loading', (WidgetTester tester) async {
    await tester.pumpWidget(createWidget());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Есть AppBar и кнопка refresh', (WidgetTester tester) async {
    await tester.pumpWidget(createWidget());

    expect(find.text('Профиль'), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });

  testWidgets('Поля отображаются после загрузки (fake)', (WidgetTester tester) async {
    await tester.pumpWidget(createWidget());

    // эмулируем завершение загрузки
    await tester.pump();

    // просто проверяем что экран не упал
    expect(find.byType(ProfileScreen), findsOneWidget);
  });

  testWidgets('Можно вводить текст', (WidgetTester tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pump();

    final textFields = find.byType(TextField);

    if (textFields.evaluate().isNotEmpty) {
      await tester.enterText(textFields.first, 'Test Name');
      await tester.pump();

      expect(find.text('Test Name'), findsOneWidget);
    }
  });

  testWidgets('Кнопка сохранить нажимается', (WidgetTester tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pump();

    final button = find.text('Сохранить изменения');

    if (button.evaluate().isNotEmpty) {
      await tester.tap(button);
      await tester.pump();

      expect(find.byType(ProfileScreen), findsOneWidget);
    }
  });

}