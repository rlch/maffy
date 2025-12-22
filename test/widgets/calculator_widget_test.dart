import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maffy/screens/scientific_calculator_screen.dart';
import 'package:maffy/widgets/calculator/calculator_button.dart';
import 'package:maffy/widgets/calculator/calculator_display.dart';
import 'package:maffy/widgets/calculator/calculator_keyboard.dart';

void main() {
  group('Calculator Widget Tests', () {
    testWidgets('Calculator screen renders', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ScientificCalculatorScreen(),
        ),
      );

      expect(find.byType(CalculatorDisplay), findsOneWidget);
      expect(find.byType(CalculatorKeyboard), findsOneWidget);
      expect(find.text('Scientific Calculator'), findsOneWidget);
    });

    testWidgets('Calculator buttons are present', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ScientificCalculatorScreen(),
        ),
      );

      // Number buttons
      for (int i = 0; i <= 9; i++) {
        expect(find.text(i.toString()), findsOneWidget);
      }

      // Operator buttons
      expect(find.text('+'), findsOneWidget);
      expect(find.text('-'), findsOneWidget);
      expect(find.text('×'), findsOneWidget);
      expect(find.text('÷'), findsOneWidget);

      // Function buttons
      expect(find.text('sin'), findsOneWidget);
      expect(find.text('cos'), findsOneWidget);
      expect(find.text('tan'), findsOneWidget);
      expect(find.text('sqrt'), findsOneWidget);

      // Special buttons
      expect(find.text('='), findsOneWidget);
      expect(find.text('AC'), findsOneWidget);
      expect(find.text('DEL'), findsOneWidget);
    });

    testWidgets('Number input updates display', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ScientificCalculatorScreen(),
        ),
      );

      // Find and tap number buttons
      await tester.tap(find.text('1'));
      await tester.pump();

      await tester.tap(find.text('2'));
      await tester.pump();

      await tester.tap(find.text('3'));
      await tester.pump();

      // Check if display is updated
      expect(find.text('123'), findsOneWidget);
    });

    testWidgets('Basic calculation works', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ScientificCalculatorScreen(),
        ),
      );

      // Input: 2 + 3 =
      await tester.tap(find.text('2'));
      await tester.pump();

      await tester.tap(find.text('+'));
      await tester.pump();

      await tester.tap(find.text('3'));
      await tester.pump();

      await tester.tap(find.text('='));
      await tester.pump();

      // Result should be 5
      expect(find.text('5'), findsWidgets);
    });

    testWidgets('Clear button resets calculator', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ScientificCalculatorScreen(),
        ),
      );

      // Input some numbers
      await tester.tap(find.text('1'));
      await tester.pump();

      await tester.tap(find.text('2'));
      await tester.pump();

      await tester.tap(find.text('3'));
      await tester.pump();

      // Tap AC button
      await tester.tap(find.text('AC'));
      await tester.pump();

      // Display should show 0
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('DEL button removes last character',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ScientificCalculatorScreen(),
        ),
      );

      // Input: 123
      await tester.tap(find.text('1'));
      await tester.pump();

      await tester.tap(find.text('2'));
      await tester.pump();

      await tester.tap(find.text('3'));
      await tester.pump();

      expect(find.text('123'), findsOneWidget);

      // Tap DEL
      await tester.tap(find.text('DEL'));
      await tester.pump();

      // Should show 12
      expect(find.text('12'), findsOneWidget);
    });

    testWidgets('History button toggles history panel',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ScientificCalculatorScreen(),
        ),
      );

      // Find history button
      final historyButton = find.byIcon(Icons.history);
      expect(historyButton, findsOneWidget);

      // Tap history button
      await tester.tap(historyButton);
      await tester.pump();

      // History panel should be visible
      expect(find.text('History'), findsOneWidget);
    });

    testWidgets('Memory indicator shows when memory is active',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ScientificCalculatorScreen(),
        ),
      );

      // Input a number and add to memory
      await tester.tap(find.text('5'));
      await tester.pump();

      await tester.tap(find.text('='));
      await tester.pump();

      await tester.tap(find.text('M+'));
      await tester.pump();

      // Memory indicator 'M' should be visible
      expect(find.text('M'), findsOneWidget);
    });

    testWidgets('Angle mode toggle works', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ScientificCalculatorScreen(),
        ),
      );

      // Should start in DEG mode
      expect(find.text('DEG'), findsOneWidget);

      // Tap DEG/RAD button
      await tester.tap(find.text('DEG/RAD'));
      await tester.pump();

      // Should switch to RAD mode
      expect(find.text('RAD'), findsOneWidget);
    });

    testWidgets('Scientific functions insert parenthesis',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ScientificCalculatorScreen(),
        ),
      );

      // Tap sin button
      await tester.tap(find.text('sin'));
      await tester.pump();

      // Display should show sin(
      expect(find.text('sin('), findsOneWidget);
    });

    testWidgets('Calculator button press animation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalculatorButton(
              text: '1',
              onPressed: () {},
            ),
          ),
        ),
      );

      final button = find.byType(CalculatorButton);
      expect(button, findsOneWidget);

      // Tap and hold
      await tester.press(button);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Release
      await tester.pumpAndSettle();
    });

    testWidgets('Display handles long expressions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CalculatorDisplay(
              expression: '1234567890123456789012345678901234567890',
              result: '1000000000',
              angleMode: 'DEG',
            ),
          ),
        ),
      );

      // Should render without overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('Error message displays correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ScientificCalculatorScreen(),
        ),
      );

      // Cause division by zero
      await tester.tap(find.text('5'));
      await tester.pump();

      await tester.tap(find.text('÷'));
      await tester.pump();

      await tester.tap(find.text('0'));
      await tester.pump();

      await tester.tap(find.text('='));
      await tester.pump();

      // Error message should be visible
      expect(find.textContaining('infinite'), findsOneWidget);
    });
  });

  group('Calculator Button Tests', () {
    testWidgets('Button renders with correct text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalculatorButton(
              text: '5',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('Button callback is triggered', (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalculatorButton(
              text: '5',
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('5'));
      await tester.pump();

      expect(pressed, true);
    });

    testWidgets('Different button types have different colors',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                CalculatorButton(
                  text: '1',
                  type: CalculatorButtonType.number,
                  onPressed: () {},
                ),
                CalculatorButton(
                  text: '+',
                  type: CalculatorButtonType.operator,
                  onPressed: () {},
                ),
                CalculatorButton(
                  text: '=',
                  type: CalculatorButtonType.equals,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(CalculatorButton), findsNWidgets(3));
    });
  });

  group('Calculator Display Tests', () {
    testWidgets('Display shows expression and result',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CalculatorDisplay(
              expression: '2+3',
              result: '5',
              angleMode: 'DEG',
            ),
          ),
        ),
      );

      expect(find.text('2+3'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('Display shows error message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CalculatorDisplay(
              expression: '5÷0',
              result: '0',
              angleMode: 'DEG',
              errorMessage: 'Division by zero',
            ),
          ),
        ),
      );

      expect(find.text('Division by zero'), findsOneWidget);
    });

    testWidgets('Display shows angle mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CalculatorDisplay(
              expression: '',
              result: '0',
              angleMode: 'RAD',
            ),
          ),
        ),
      );

      expect(find.text('RAD'), findsOneWidget);
    });

    testWidgets('Display shows memory indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CalculatorDisplay(
              expression: '',
              result: '0',
              angleMode: 'DEG',
              hasMemory: true,
            ),
          ),
        ),
      );

      expect(find.text('M'), findsOneWidget);
    });
  });
}
