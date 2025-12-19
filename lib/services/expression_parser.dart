import 'dart:math' as math;
import 'package:math_expressions/math_expressions.dart';
import 'package:math_keyboard/math_keyboard.dart';

/// Service for parsing and evaluating mathematical expressions
class ExpressionParserService {
  static final ExpressionParserService _instance = ExpressionParserService._();
  factory ExpressionParserService() => _instance;
  ExpressionParserService._();

  final GrammarParser _parser = GrammarParser();
  final ContextModel _context = ContextModel();

  /// Built-in variables that don't need sliders
  static const Set<String> builtInVariables = {'x', 'y', 'z', 't', 'e', 'pi', 'π'};

  /// Parse a TeX string into a math Expression
  /// Returns the parsed expression or null if parsing fails
  ParseResult parseTeX(String tex) {
    try {
      // Use math_keyboard's TeXParser to convert to expression string
      final expression = TeXParser(tex).parse();
      return ParseResult.success(expression);
    } catch (e) {
      return ParseResult.error('Parse error: ${e.toString()}');
    }
  }

  /// Parse an expression string (like "x^2 + 1") into a math Expression
  ParseResult parseExpression(String expressionString) {
    try {
      final expression = _parser.parse(expressionString);
      return ParseResult.success(expression);
    } catch (e) {
      return ParseResult.error('Parse error: ${e.toString()}');
    }
  }

  /// Evaluate an expression for a given x value
  double? evaluate(
    Expression expression,
    double x, {
    Map<String, double> variables = const {},
  }) {
    try {
      _context.bindVariable(Variable('x'), Number(x));

      // Bind any additional variables (like slider values)
      for (final entry in variables.entries) {
        _context.bindVariable(Variable(entry.key), Number(entry.value));
      }

      final result = expression.evaluate(EvaluationType.REAL, _context);
      if (result is double && result.isFinite) {
        return result;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Generate points for plotting a function
  List<math.Point<double>> generatePoints(
    Expression expression, {
    required double xMin,
    required double xMax,
    int sampleCount = 500,
    Map<String, double> variables = const {},
  }) {
    final points = <math.Point<double>>[];
    final step = (xMax - xMin) / sampleCount;

    for (int i = 0; i <= sampleCount; i++) {
      final x = xMin + i * step;
      final y = evaluate(expression, x, variables: variables);
      if (y != null) {
        points.add(math.Point(x, y));
      }
    }

    return points;
  }

  /// Detect the type of expression from TeX input
  ExpressionType detectType(String tex) {
    final trimmed = tex.trim();

    // Check for function definition: f(x) = ...
    if (RegExp(r'^[a-zA-Z]\s*\([a-zA-Z]\)\s*=').hasMatch(trimmed)) {
      return ExpressionType.functionDefinition;
    }

    // Check for y = ... style
    if (RegExp(r'^y\s*=').hasMatch(trimmed)) {
      return ExpressionType.yEquals;
    }

    // Check for variable assignment: L = ... (single uppercase letter = number)
    if (RegExp(r'^[A-Z]\s*=\s*-?\d').hasMatch(trimmed)) {
      return ExpressionType.slider;
    }

    // Check for point: (x, y)
    if (RegExp(r'^\s*\(.*,.*\)\s*$').hasMatch(trimmed)) {
      return ExpressionType.point;
    }

    // Check for implicit equation: ... = ...
    if (trimmed.contains('=')) {
      return ExpressionType.implicitEquation;
    }

    // Default to y = f(x) style expression
    return ExpressionType.expression;
  }

  /// Parse a function definition like "f(x) = x^2"
  /// Returns (functionName, variableName, expression) or null if not a function def
  FunctionDefinition? parseFunctionDefinition(String tex) {
    // Match patterns like "f(x) = ..." or "g(t) = ..."
    final match = RegExp(r'^([a-zA-Z])\s*\(([a-zA-Z])\)\s*=\s*(.+)$').firstMatch(tex);
    if (match == null) return null;

    final funcName = match.group(1)!;
    final varName = match.group(2)!;
    final exprStr = match.group(3)!;

    final result = parseExpression(exprStr);
    if (result is ParseSuccess) {
      return FunctionDefinition(
        name: funcName,
        variable: varName,
        expression: result.expression,
        expressionString: exprStr,
      );
    }
    return null;
  }

  /// Parse "y = ..." and return just the right-hand side expression
  String? parseYEquals(String tex) {
    final match = RegExp(r'^y\s*=\s*(.+)$').firstMatch(tex);
    return match?.group(1);
  }

  /// Get undefined variables (variables that need sliders)
  Set<String> getUndefinedVariables(
    Expression expression, {
    Set<String> definedVariables = const {},
  }) {
    final allVars = extractVariables(expression);
    return allVars
        .where((v) => !builtInVariables.contains(v.toLowerCase()))
        .where((v) => !definedVariables.contains(v))
        .toSet();
  }

  /// Extract variables used in an expression
  Set<String> extractVariables(Expression expression) {
    final variables = <String>{};
    _extractVariablesRecursive(expression, variables);
    return variables;
  }

  void _extractVariablesRecursive(Expression expr, Set<String> variables) {
    if (expr is Variable) {
      variables.add(expr.name);
    } else if (expr is BinaryOperator) {
      _extractVariablesRecursive(expr.first, variables);
      _extractVariablesRecursive(expr.second, variables);
    } else if (expr is UnaryOperator) {
      _extractVariablesRecursive(expr.exp, variables);
    } else if (expr is MathFunction) {
      // MathFunction has args list
      for (final arg in expr.args) {
        _extractVariablesRecursive(arg, variables);
      }
    }
  }
}

/// Result of parsing an expression
sealed class ParseResult {
  const ParseResult();

  factory ParseResult.success(Expression expression) = ParseSuccess._;
  factory ParseResult.error(String message) = ParseError._;
}

class ParseSuccess extends ParseResult {
  final Expression expression;
  const ParseSuccess._(this.expression);
}

class ParseError extends ParseResult {
  final String message;
  const ParseError._(this.message);
}

/// Type of expression detected
enum ExpressionType {
  functionDefinition, // f(x) = x^2
  yEquals, // y = x^2
  expression, // x^2 (implicitly y = x^2)
  slider, // L = 5
  point, // (2, 3)
  implicitEquation, // x^2 + y^2 = 1
}

/// A parsed function definition
class FunctionDefinition {
  final String name;
  final String variable;
  final Expression expression;
  final String expressionString;

  const FunctionDefinition({
    required this.name,
    required this.variable,
    required this.expression,
    required this.expressionString,
  });
}
