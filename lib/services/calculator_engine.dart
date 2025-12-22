import 'dart:math' as math;
import 'package:math_expressions/math_expressions.dart';

/// Calculator engine for parsing and evaluating mathematical expressions
class CalculatorEngine {
  /// Evaluate a mathematical expression
  /// Returns the result as a string, or throws an exception on error
  static String evaluate(String expression, {bool isDegrees = true}) {
    try {
      if (expression.isEmpty) {
        return '0';
      }

      // Preprocess the expression
      String processedExpression = _preprocessExpression(expression, isDegrees);

      // Parse and evaluate
      // ignore: deprecated_member_use
      Parser parser = Parser();
      Expression exp = parser.parse(processedExpression);
      ContextModel context = ContextModel();

      // Add constants
      context.bindVariable(Variable('pi'), Number(math.pi));
      context.bindVariable(Variable('e'), Number(math.e));

      double result = exp.evaluate(EvaluationType.REAL, context);

      // Handle special cases
      if (result.isNaN) {
        throw Exception('Invalid calculation');
      }
      if (result.isInfinite) {
        throw Exception('Result is infinite');
      }

      // Format the result
      return _formatResult(result);
    } on FormatException catch (e) {
      throw Exception('Syntax error: ${e.message}');
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  /// Preprocess expression to handle special functions and symbols
  static String _preprocessExpression(String expression, bool isDegrees) {
    String processed = expression;

    // Replace π with pi
    processed = processed.replaceAll('π', 'pi');
    processed = processed.replaceAll('Pi', 'pi');

    // Replace × and ÷ with * and /
    processed = processed.replaceAll('×', '*');
    processed = processed.replaceAll('÷', '/');

    // Handle percentage (convert % to /100)
    processed = processed.replaceAllMapped(
      RegExp(r'(\d+\.?\d*)%'),
      (match) => '(${match.group(1)})/100',
    );

    // Handle implicit multiplication
    processed = _handleImplicitMultiplication(processed);

    // Handle trigonometric functions with degree conversion
    if (isDegrees) {
      processed = _convertDegreesToRadians(processed);
    }

    // Handle factorial
    processed = _handleFactorial(processed);

    // Handle sqrt as a function call
    processed = processed.replaceAllMapped(
      RegExp(r'sqrt\s*\('),
      (match) => 'sqrt(',
    );

    // Handle log10
    processed = processed.replaceAllMapped(
      RegExp(r'log10\s*\(([^)]+)\)'),
      (match) => 'log(${match.group(1)})/log(10)',
    );

    // Handle ln (natural log)
    processed = processed.replaceAll('ln', 'log');

    // Handle exp
    processed = processed.replaceAllMapped(
      RegExp(r'exp\s*\(([^)]+)\)'),
      (match) => 'e^(${match.group(1)})',
    );

    return processed;
  }

  /// Convert degree-based trig functions to radians
  static String _convertDegreesToRadians(String expression) {
    // sin, cos, tan in degrees
    expression = expression.replaceAllMapped(
      RegExp(r'sin\s*\(([^)]+)\)'),
      (match) => 'sin((${match.group(1)})*pi/180)',
    );

    expression = expression.replaceAllMapped(
      RegExp(r'cos\s*\(([^)]+)\)'),
      (match) => 'cos((${match.group(1)})*pi/180)',
    );

    expression = expression.replaceAllMapped(
      RegExp(r'tan\s*\(([^)]+)\)'),
      (match) => 'tan((${match.group(1)})*pi/180)',
    );

    // Inverse trig functions - convert radians result to degrees
    expression = expression.replaceAllMapped(
      RegExp(r'asin\s*\(([^)]+)\)'),
      (match) => '(asin(${match.group(1)})*180/pi)',
    );

    expression = expression.replaceAllMapped(
      RegExp(r'acos\s*\(([^)]+)\)'),
      (match) => '(acos(${match.group(1)})*180/pi)',
    );

    expression = expression.replaceAllMapped(
      RegExp(r'atan\s*\(([^)]+)\)'),
      (match) => '(atan(${match.group(1)})*180/pi)',
    );

    return expression;
  }

  /// Handle implicit multiplication (e.g., "2π" -> "2*π", "3(4+5)" -> "3*(4+5)")
  static String _handleImplicitMultiplication(String expression) {
    // Number followed by letter or (
    expression = expression.replaceAllMapped(
      RegExp(r'(\d)([a-zA-Z(π])'),
      (match) => '${match.group(1)}*${match.group(2)}',
    );

    // ) followed by (
    expression = expression.replaceAllMapped(
      RegExp(r'\)\s*\('),
      (match) => ')*(', 
    );

    // ) followed by number
    expression = expression.replaceAllMapped(
      RegExp(r'\)\s*(\d)'),
      (match) => ')*${match.group(1)}',
    );

    return expression;
  }

  /// Handle factorial notation
  static String _handleFactorial(String expression) {
    // Find all factorial expressions (number!)
    return expression.replaceAllMapped(
      RegExp(r'(\d+)!'),
      (match) {
        int n = int.parse(match.group(1)!);
        if (n > 170) {
          throw Exception('Factorial overflow');
        }
        return _factorial(n).toString();
      },
    );
  }

  /// Calculate factorial
  static double _factorial(int n) {
    if (n < 0) {
      throw Exception('Factorial of negative number');
    }
    if (n == 0 || n == 1) return 1;

    double result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  /// Format the result for display
  static String _formatResult(double result) {
    // Handle very small numbers
    if (result.abs() < 1e-10 && result != 0) {
      return result.toStringAsExponential(6);
    }

    // Handle very large numbers
    if (result.abs() > 1e10) {
      return result.toStringAsExponential(6);
    }

    // For normal numbers, remove trailing zeros
    String formatted = result.toString();

    if (formatted.contains('.')) {
      // Remove trailing zeros after decimal point
      formatted = formatted.replaceAll(RegExp(r'\.?0+$'), '');
    }

    // If result is an integer, display without decimal point
    if (result == result.roundToDouble()) {
      return result.toInt().toString();
    }

    // Limit to 10 decimal places
    if (formatted.contains('.') && formatted.split('.')[1].length > 10) {
      return result.toStringAsFixed(10).replaceAll(RegExp(r'\.?0+$'), '');
    }

    return formatted;
  }

  /// Validate if expression has balanced parentheses
  static bool hasBalancedParentheses(String expression) {
    int count = 0;
    for (int i = 0; i < expression.length; i++) {
      if (expression[i] == '(') count++;
      if (expression[i] == ')') count--;
      if (count < 0) return false;
    }
    return count == 0;
  }

  /// Auto-close parentheses if needed
  static String autoCloseParentheses(String expression) {
    int openCount = expression.split('(').length - 1;
    int closeCount = expression.split(')').length - 1;
    int diff = openCount - closeCount;

    if (diff > 0) {
      return expression + (')' * diff);
    }
    return expression;
  }
}
