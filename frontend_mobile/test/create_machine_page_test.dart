import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mobile/screens/machine/create_machine_page.dart';

void main() {
  group('CreateMachinePage Tests', () {

    testWidgets('UI отображается корректно', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreateMachinePage(),
        ),
      );

      expect(find.text('Добавить аппарат'), findsOneWidget);
      expect(find.text('Название'), findsOneWidget);
      expect(find.text('Тип аппарата'), findsOneWidget);
      expect(find.text('Сохранить'), findsOneWidget);
    });

    testWidgets('Можно ввести название', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreateMachinePage(),
        ),
      );

      await tester.enterText(find.byType(TextField).first, 'Test Machine');
      await tester.pump();

      expect(find.text('Test Machine'), findsOneWidget);
    });

    testWidgets('Работает Dropdown', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreateMachinePage(),
        ),
      );

      // открыть dropdown
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // выбрать элемент
      await tester.tap(find.text('Water').last);
      await tester.pumpAndSettle();

      expect(find.text('Water'), findsWidgets);
    });

    testWidgets('Кнопка нажимается без ошибок', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreateMachinePage(),
        ),
      );

      await tester.tap(find.text('Сохранить'));
      await tester.pump();

      // Проверяем что приложение не упало
      expect(find.byType(CreateMachinePage), findsOneWidget);
    });

  });
}
