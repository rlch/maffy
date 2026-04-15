import 'package:flutter_test/flutter_test.dart';
import 'package:maffy/services/calculator_engine.dart';

void main() {
  group('CalculatorEngine - Basic Operations', () {
    test('Addition', () {
      expect(CalculatorEngine.evaluate('2+3'), '5');
      expect(CalculatorEngine.evaluate('10+20'), '30');
      expect(CalculatorEngine.evaluate('0.5+0.5'), '1');
    });

    test('Subtraction', () {
      expect(CalculatorEngine.evaluate('5-3'), '2');
      expect(CalculatorEngine.evaluate('10-20'), '-10');
      expect(CalculatorEngine.evaluate('0.8-0.3'), '0.5');
    });

    test('Multiplication', () {
      expect(CalculatorEngine.evaluate('2×3'), '6');
      expect(CalculatorEngine.evaluate('5*4'), '20');
      expect(CalculatorEngine.evaluate('0.5×4'), '2');
    });

    test('Division', () {
      expect(CalculatorEngine.evaluate('6÷3'), '2');
      expect(CalculatorEngine.evaluate('10/2'), '5');
      expect(CalculatorEngine.evaluate('1÷4'), '0.25');
    });

    test('Division by zero', () {
      expect(
        () => CalculatorEngine.evaluate('5÷0'),
        throwsException,
      );
    });

    test('Order of operations', () {
      expect(CalculatorEngine.evaluate('2+3×4'), '14');
      expect(CalculatorEngine.evaluate('(2+3)×4'), '20');
      expect(CalculatorEngine.evaluate('10-2×3'), '4');
      expect(CalculatorEngine.evaluate('(10-2)×3'), '24');
    });
  });

  group('CalculatorEngine - Advanced Operations', () {
    test('Power', () {
      expect(CalculatorEngine.evaluate('2^3'), '8');
      expect(CalculatorEngine.evaluate('10^2'), '100');
      expect(CalculatorEngine.evaluate('2^0.5'), '1.4142135624');
    });

    test('Square root', () {
      expect(CalculatorEngine.evaluate('sqrt(4)'), '2');
      expect(CalculatorEngine.evaluate('sqrt(16)'), '4');
      expect(CalculatorEngine.evaluate('sqrt(2)'), '1.4142135624');
    });

    test('Factorial', () {
      expect(CalculatorEngine.evaluate('5!'), '120');
      expect(CalculatorEngine.evaluate('0!'), '1');
      expect(CalculatorEngine.evaluate('10!'), '3628800');
    });

    test('Factorial overflow', () {
      expect(
        () => CalculatorEngine.evaluate('200!'),
        throwsException,
      );
    });

    test('Percentage', () {
      expect(CalculatorEngine.evaluate('50%'), '0.5');
      expect(CalculatorEngine.evaluate('25%'), '0.25');
      expect(CalculatorEngine.evaluate('100×50%'), '50');
    });
  });

  group('CalculatorEngine - Trigonometric Functions (Degrees)', () {
    test('Sine', () {
      expect(CalculatorEngine.evaluate('sin(0)', isDegrees: true), '0');
      expect(CalculatorEngine.evaluate('sin(30)', isDegrees: true), '0.5');
      expect(CalculatorEngine.evaluate('sin(90)', isDegrees: true), '1');
    });

    test('Cosine', () {
      expect(CalculatorEngine.evaluate('cos(0)', isDegrees: true), '1');
      expect(CalculatorEngine.evaluate('cos(60)', isDegrees: true), '0.5');
      expect(CalculatorEngine.evaluate('cos(90)', isDegrees: true),
          startsWith('0.000000'));
    });

    test('Tangent', () {
      expect(CalculatorEngine.evaluate('tan(0)', isDegrees: true), '0');
      expect(CalculatorEngine.evaluate('tan(45)', isDegrees: true), '1');
    });

    test('Inverse sine', () {
      expect(CalculatorEngine.evaluate('asin(0)', isDegrees: true), '0');
      expect(CalculatorEngine.evaluate('asin(0.5)', isDegrees: true), '30');
      expect(CalculatorEngine.evaluate('asin(1)', isDegrees: true), '90');
    });

    test('Inverse cosine', () {
      expect(CalculatorEngine.evaluate('acos(1)', isDegrees: true), '0');
      expect(CalculatorEngine.evaluate('acos(0.5)', isDegrees: true), '60');
      expect(CalculatorEngine.evaluate('acos(0)', isDegrees: true), '90');
    });

    test('Inverse tangent', () {
      expect(CalculatorEngine.evaluate('atan(0)', isDegrees: true), '0');
      expect(CalculatorEngine.evaluate('atan(1)', isDegrees: true), '45');
    });
  });

  group('CalculatorEngine - Trigonometric Functions (Radians)', () {
    test('Sine in radians', () {
      expect(CalculatorEngine.evaluate('sin(0)', isDegrees: false), '0');
      expect(
        double.parse(
            CalculatorEngine.evaluate('sin(1.5707963)', isDegrees: false)),
        closeTo(1.0, 0.0001),
      );
    });

    test('Cosine in radians', () {
      expect(CalculatorEngine.evaluate('cos(0)', isDegrees: false), '1');
      expect(
        double.parse(
            CalculatorEngine.evaluate('cos(3.14159265)', isDegrees: false)),
        closeTo(-1.0, 0.0001),
      );
    });
  });

  group('CalculatorEngine - Logarithmic and Exponential', () {
    test('Natural logarithm', () {
      expect(CalculatorEngine.evaluate('ln(1)'), '0');
      expect(
        double.parse(CalculatorEngine.evaluate('ln(2.71828)')),
        closeTo(1.0, 0.001),
      );
    });

    test('Log base 10', () {
      expect(CalculatorEngine.evaluate('log10(1)'), '0');
      expect(CalculatorEngine.evaluate('log10(10)'), '1');
      expect(CalculatorEngine.evaluate('log10(100)'), '2');
    });

    test('Exponential', () {
      expect(
        double.parse(CalculatorEngine.evaluate('exp(0)')),
        closeTo(1.0, 0.0001),
      );
      expect(
        double.parse(CalculatorEngine.evaluate('exp(1)')),
        closeTo(2.71828, 0.001),
      );
    });
  });

  group('CalculatorEngine - Constants', () {
    test('Pi constant', () {
      expect(
        double.parse(CalculatorEngine.evaluate('π')),
        closeTo(3.14159265, 0.0001),
      );
      expect(CalculatorEngine.evaluate('2×π'), startsWith('6.283'));
    });

    test('Euler\'s number', () {
      expect(
        double.parse(CalculatorEngine.evaluate('e')),
        closeTo(2.71828, 0.001),
      );
      expect(CalculatorEngine.evaluate('2×e'), startsWith('5.436'));
    });
  });

  group('CalculatorEngine - Implicit Multiplication', () {
    test('Number and constant', () {
      expect(CalculatorEngine.evaluate('2π'), startsWith('6.283'));
      expect(CalculatorEngine.evaluate('3e'), startsWith('8.154'));
    });

    test('Number and parenthesis', () {
      expect(CalculatorEngine.evaluate('2(3+4)'), '14');
      expect(CalculatorEngine.evaluate('5(2)'), '10');
    });

    test('Parenthesis and parenthesis', () {
      expect(CalculatorEngine.evaluate('(2+3)(4+5)'), '45');
    });
  });

  group('CalculatorEngine - Parentheses', () {
    test('Balanced parentheses', () {
      expect(CalculatorEngine.hasBalancedParentheses('(2+3)'), true);
      expect(CalculatorEngine.hasBalancedParentheses('((2+3)×4)'), true);
      expect(CalculatorEngine.hasBalancedParentheses('2+3'), true);
    });

    test('Unbalanced parentheses', () {
      expect(CalculatorEngine.hasBalancedParentheses('(2+3'), false);
      expect(CalculatorEngine.hasBalancedParentheses('2+3)'), false);
      expect(CalculatorEngine.hasBalancedParentheses(')2+3('), false);
    });

    test('Auto-close parentheses', () {
      expect(CalculatorEngine.autoCloseParentheses('(2+3'), '(2+3)');
      expect(
          CalculatorEngine.autoCloseParentheses('((2+3)×4'), '((2+3)×4)');
      expect(CalculatorEngine.autoCloseParentheses('2+3'), '2+3');
    });
  });

  group('CalculatorEngine - Complex Expressions', () {
    test('Complex nested expressions', () {
      expect(CalculatorEngine.evaluate('((2+3)×(4+5))÷3'), '15');
      expect(CalculatorEngine.evaluate('sqrt((3^2)+(4^2))'), '5');
    });

    test('Mixed operations', () {
      expect(
        CalculatorEngine.evaluate('2+3×4-5÷2'),
        '11.5',
      );
      expect(
        CalculatorEngine.evaluate('(2+3)×(4-5)÷2'),
        '-2.5',
      );
    });
  });

  group('CalculatorEngine - Edge Cases', () {
    test('Empty expression', () {
      expect(CalculatorEngine.evaluate(''), '0');
    });

    test('Single number', () {
      expect(CalculatorEngine.evaluate('42'), '42');
      expect(CalculatorEngine.evaluate('3.14'), '3.14');
    });

    test('Very large numbers', () {
      final result = CalculatorEngine.evaluate('10^15');
      expect(result, contains('e+'));
    });

    test('Very small numbers', () {
      final result = CalculatorEngine.evaluate('10^-15');
      expect(result, contains('e-'));
    });

    test('Invalid expressions', () {
      expect(() => CalculatorEngine.evaluate('2++3'), throwsException);
      expect(() => CalculatorEngine.evaluate('2÷÷3'), throwsException);
    });
  });

  group('CalculatorEngine - Result Formatting', () {
    test('Integer results', () {
      expect(CalculatorEngine.evaluate('2+3'), '5');
      expect(CalculatorEngine.evaluate('10÷2'), '5');
    });

    test('Decimal results', () {
      expect(CalculatorEngine.evaluate('1÷3'), startsWith('0.333'));
      expect(CalculatorEngine.evaluate('1÷2'), '0.5');
    });

    test('Remove trailing zeros', () {
      expect(CalculatorEngine.evaluate('2.0+3.0'), '5');
      expect(CalculatorEngine.evaluate('1.5×2'), '3');
    });
  });
}
