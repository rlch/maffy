import 'package:flutter_test/flutter_test.dart';
import 'package:maffy/providers/calculator_provider.dart';
import 'package:maffy/models/calculator_state.dart';

void main() {
  group('CalculatorProvider - Input', () {
    test('Input numbers', () {
      final calculator = CalculatorProvider();

      calculator.input('1');
      expect(calculator.state.displayExpression, '1');

      calculator.input('2');
      expect(calculator.state.displayExpression, '12');

      calculator.input('3');
      expect(calculator.state.displayExpression, '123');
    });

    test('Input operators', () {
      final calculator = CalculatorProvider();

      calculator.input('5');
      calculator.input('+');
      calculator.input('3');
      expect(calculator.state.displayExpression, '5+3');
    });

    test('Input decimal point', () {
      final calculator = CalculatorProvider();

      calculator.input('3');
      calculator.input('.');
      calculator.input('1');
      calculator.input('4');
      expect(calculator.state.displayExpression, '3.14');
    });

    test('Input functions with auto parenthesis', () {
      final calculator = CalculatorProvider();

      calculator.input('sin');
      expect(calculator.state.displayExpression, 'sin(');

      calculator.input('3');
      calculator.input('0');
      expect(calculator.state.displayExpression, 'sin(30');
    });

    test('Input constants', () {
      final calculator = CalculatorProvider();

      calculator.input('π');
      expect(calculator.state.displayExpression, 'π');

      calculator.clear();

      calculator.input('e');
      expect(calculator.state.displayExpression, 'e');
    });
  });

  group('CalculatorProvider - Operations', () {
    test('Clear', () {
      final calculator = CalculatorProvider();

      calculator.input('1');
      calculator.input('2');
      calculator.input('3');
      calculator.clear();

      expect(calculator.state.displayExpression, '');
      expect(calculator.state.result, '0');
      expect(calculator.state.errorMessage, null);
    });

    test('Backspace', () {
      final calculator = CalculatorProvider();

      calculator.input('1');
      calculator.input('2');
      calculator.input('3');
      expect(calculator.state.displayExpression, '123');

      calculator.backspace();
      expect(calculator.state.displayExpression, '12');

      calculator.backspace();
      expect(calculator.state.displayExpression, '1');

      calculator.backspace();
      expect(calculator.state.displayExpression, '');
    });

    test('Backspace function', () {
      final calculator = CalculatorProvider();

      calculator.input('sin');
      expect(calculator.state.displayExpression, 'sin(');

      calculator.backspace();
      expect(calculator.state.displayExpression, '');
    });

    test('Calculate', () {
      final calculator = CalculatorProvider();

      calculator.input('2');
      calculator.input('+');
      calculator.input('3');
      calculator.calculate();

      expect(calculator.state.result, '5');
      expect(calculator.state.history.length, 1);
      expect(calculator.state.history[0].expression, '2+3');
      expect(calculator.state.history[0].result, '5');
    });

    test('Toggle sign', () {
      final calculator = CalculatorProvider();

      calculator.input('5');
      calculator.toggleSign();
      expect(calculator.state.displayExpression, '-5');

      calculator.toggleSign();
      expect(calculator.state.displayExpression, '5');
    });
  });

  group('CalculatorProvider - Live Evaluation', () {
    test('Live evaluation updates result', () {
      final calculator = CalculatorProvider();

      calculator.input('2');
      expect(calculator.state.result, '2');

      calculator.input('+');
      expect(calculator.state.result, '2');

      calculator.input('3');
      expect(calculator.state.result, '5');
    });

    test('Live evaluation with parentheses', () {
      final calculator = CalculatorProvider();

      calculator.input('(');
      calculator.input('2');
      calculator.input('+');
      calculator.input('3');
      // Should auto-close and evaluate
      expect(calculator.state.result, '5');
    });
  });

  group('CalculatorProvider - Memory Operations', () {
    test('Memory clear', () {
      final calculator = CalculatorProvider();

      calculator.input('5');
      calculator.calculate();
      calculator.memoryAdd();
      expect(calculator.state.memory, 5);

      calculator.memoryClear();
      expect(calculator.state.memory, 0);
    });

    test('Memory add', () {
      final calculator = CalculatorProvider();

      calculator.input('5');
      calculator.calculate();
      calculator.memoryAdd();
      expect(calculator.state.memory, 5);

      calculator.clear();
      calculator.input('3');
      calculator.calculate();
      calculator.memoryAdd();
      expect(calculator.state.memory, 8);
    });

    test('Memory subtract', () {
      final calculator = CalculatorProvider();

      calculator.input('1');
      calculator.input('0');
      calculator.calculate();
      calculator.memoryAdd();
      expect(calculator.state.memory, 10);

      calculator.clear();
      calculator.input('3');
      calculator.calculate();
      calculator.memorySubtract();
      expect(calculator.state.memory, 7);
    });

    test('Memory recall', () {
      final calculator = CalculatorProvider();

      calculator.input('5');
      calculator.calculate();
      calculator.memoryAdd();
      
      calculator.clear();
      calculator.memoryRecall();

      expect(calculator.state.displayExpression, contains('5'));
    });
  });

  group('CalculatorProvider - Angle Mode', () {
    test('Toggle angle mode', () {
      final calculator = CalculatorProvider();

      expect(calculator.state.angleMode, AngleMode.degrees);

      calculator.toggleAngleMode();
      expect(calculator.state.angleMode, AngleMode.radians);

      calculator.toggleAngleMode();
      expect(calculator.state.angleMode, AngleMode.degrees);
    });

    test('Sin in degrees vs radians', () {
      final calculator = CalculatorProvider();

      // Degrees mode
      calculator.input('sin');
      calculator.input('9');
      calculator.input('0');
      calculator.calculate();
      expect(calculator.state.result, '1');

      calculator.clear();

      // Radians mode
      calculator.toggleAngleMode();
      calculator.input('sin');
      calculator.input('1');
      calculator.input('.');
      calculator.input('5');
      calculator.input('7');
      calculator.calculate();
      expect(
        double.parse(calculator.state.result),
        closeTo(1.0, 0.01),
      );
    });
  });

  group('CalculatorProvider - History', () {
    test('History is saved', () {
      final calculator = CalculatorProvider();

      calculator.input('2');
      calculator.input('+');
      calculator.input('3');
      calculator.calculate();

      expect(calculator.state.history.length, 1);
      expect(calculator.state.history[0].expression, '2+3');
      expect(calculator.state.history[0].result, '5');

      calculator.clear();
      calculator.input('5');
      calculator.input('×');
      calculator.input('4');
      calculator.calculate();

      expect(calculator.state.history.length, 2);
      expect(calculator.state.history[0].expression, '5×4');
      expect(calculator.state.history[0].result, '20');
    });

    test('History limit', () {
      final calculator = CalculatorProvider();

      // Add 55 calculations
      for (int i = 0; i < 55; i++) {
        calculator.clear();
        calculator.input('1');
        calculator.calculate();
      }

      // Should only keep 50
      expect(calculator.state.history.length, 50);
    });

    test('Clear history', () {
      final calculator = CalculatorProvider();

      calculator.input('2');
      calculator.input('+');
      calculator.input('3');
      calculator.calculate();

      expect(calculator.state.history.length, 1);

      calculator.clearHistory();
      expect(calculator.state.history.length, 0);
    });

    test('Load from history', () {
      final calculator = CalculatorProvider();

      calculator.input('2');
      calculator.input('+');
      calculator.input('3');
      calculator.calculate();

      final historyItem = calculator.state.history[0];

      calculator.clear();
      calculator.loadFromHistory(historyItem);

      expect(calculator.state.displayExpression, '2+3');
      expect(calculator.state.result, '5');
    });
  });

  group('CalculatorProvider - Error Handling', () {
    test('Division by zero error', () {
      final calculator = CalculatorProvider();

      calculator.input('5');
      calculator.input('÷');
      calculator.input('0');
      calculator.calculate();

      expect(calculator.state.errorMessage, isNotNull);
      expect(calculator.state.errorMessage, contains('infinite'));
    });

    test('Clear on next input after error', () {
      final calculator = CalculatorProvider();

      calculator.input('5');
      calculator.input('÷');
      calculator.input('0');
      calculator.calculate();

      expect(calculator.state.errorMessage, isNotNull);

      calculator.input('2');
      expect(calculator.state.displayExpression, '2');
      expect(calculator.state.errorMessage, null);
    });

    test('Clear on next input after equals', () {
      final calculator = CalculatorProvider();

      calculator.input('2');
      calculator.input('+');
      calculator.input('3');
      calculator.calculate();

      expect(calculator.state.shouldClearOnNextInput, true);

      calculator.input('5');
      expect(calculator.state.displayExpression, '5');
      expect(calculator.state.shouldClearOnNextInput, false);
    });
  });
}
