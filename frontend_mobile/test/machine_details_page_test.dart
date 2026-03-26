import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_mobile/models/machine.dart';
import 'package:frontend_mobile/screens/machine/machine_details_page.dart';

void main() {
  late Machine testMachine;

  setUp(() {
    testMachine = Machine(
      id: 1,
      name: 'Test Machine',
      type: 'Water',
      location: 'Test Location',
      serialNumber: '12345',
      isActive: true,
      latitude: 42.0,
      longitude: 69.0,
    );
  });

  Widget createWidget() {
    return MaterialApp(
      home: MachineDetailsPage(machine: testMachine),
    );
  }

  testWidgets('UI отображается', (WidgetTester tester) async {
    await tester.pumpWidget(createWidget());

    expect(find.text('Детали аппарата'), findsOneWidget);
    expect(find.text('Test Machine'), findsOneWidget);
    expect(find.byIcon(Icons.delete), findsOneWidget);
  });

  testWidgets('Открывается диалог при нажатии на поле', (WidgetTester tester) async {
    await tester.pumpWidget(createWidget());

    // нажимаем на "Название"
    await tester.tap(find.text('Название'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Изменить'), findsOneWidget);
  });

  testWidgets('Открывается диалог удаления', (WidgetTester tester) async {
    await tester.pumpWidget(createWidget());

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    expect(find.text('Удалить аппарат?'), findsOneWidget);
  });

  testWidgets('Отмена удаления работает', (WidgetTester tester) async {
    await tester.pumpWidget(createWidget());

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();

    expect(find.text('Удалить аппарат?'), findsNothing);
  });

  testWidgets('Back возвращает machine', (WidgetTester tester) async {
    Machine? returnedMachine;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MachineDetailsPage(machine: testMachine),
                  ),
                );
                returnedMachine = result;
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(returnedMachine, isNotNull);
    expect(returnedMachine!.name, 'Test Machine');
  });
}
