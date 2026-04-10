import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend_mobile/screens/machine/create_machine_page.dart';
import 'package:frontend_mobile/models/machine.dart';

void main() {
  Widget makePage({List<Machine>? machines}) {
    return MaterialApp(
      home: CreateMachinePage(machines: machines ?? []),
    );
  }

  testWidgets('Page loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(makePage());

    expect(find.text('Добавить аппарат'), findsOneWidget);
    expect(find.text('Название'), findsOneWidget);
    expect(find.text('Тип аппарата'), findsOneWidget);
    expect(find.text('Сохранить'), findsOneWidget);
  });

  testWidgets('Shows error when fields are empty', (WidgetTester tester) async {
    await tester.pumpWidget(makePage());

    await tester.tap(find.text('Сохранить'));
    await tester.pump();

    expect(
      find.text('Название или тип аппарата не заполнены'),
      findsOneWidget,
    );
  });

  testWidgets('Detects duplicate machine name', (WidgetTester tester) async {
    await tester.pumpWidget(
      makePage(
        machines: [
          Machine(
            id: 1,
            name: 'TestMachine',
            type: 'Water',
            location: '',
            serialNumber: '',
          ),
        ],
      ),
    );

    // ввод имени
    await tester.enterText(find.byType(TextField).first, 'TestMachine');

    // выбираем тип
    await tester.tap(find.text('Тип аппарата'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Water').last);
    await tester.pump();

    // сохранить
    await tester.tap(find.text('Сохранить'));
    await tester.pump();

    expect(find.text('Такое название уже существует'), findsOneWidget);
  });
}
