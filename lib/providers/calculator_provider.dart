import 'package:flutter/foundation.dart';
import '../models/calculator_state.dart';
import '../services/calculator_engine.dart';
import '../services/calculator_memory.dart';

/// Calculator state provider
class CalculatorProvider extends ChangeNotifier {
  CalculatorState _state = const CalculatorState();
  final CalculatorMemory _memory = CalculatorMemory();

  CalculatorState get state => _state;

  /// Input a character/string into the calculator
  void input(String value) {
    try {
      String newExpression = _state.displayExpression;

      // If should clear on next input (after equals or error), clear first
      if (_state.shouldClearOnNextInput) {
        newExpression = '';
        _updateState(_state.copyWith(
          displayExpression: '',
          shouldClearOnNextInput: false,
          errorMessage: null,
        ));
      }

      // Handle special inputs
      if (value == 'AC') {
        clear();
        return;
      }

      if (value == 'DEL') {
        backspace();
        return;
      }

      if (value == '=') {
        calculate();
        return;
      }

      if (value == '+/-') {
        toggleSign();
        return;
      }

      // Memory operations
      if (value == 'MC') {
        memoryClear();
        return;
      }

      if (value == 'MR') {
        memoryRecall();
        return;
      }

      if (value == 'M+') {
        memoryAdd();
        return;
      }

      if (value == 'M-') {
        memorySubtract();
        return;
      }

      // Toggle angle mode
      if (value == 'DEG/RAD') {
        toggleAngleMode();
        return;
      }

      // Handle function inputs (add opening parenthesis)
      if (_isFunctionInput(value)) {
        newExpression += '$value(';
      } else {
        newExpression += value;
      }

      _updateState(_state.copyWith(
        displayExpression: newExpression,
        errorMessage: null,
      ));

      // Live evaluation
      _liveEvaluate();
    } catch (e) {
      _updateState(_state.copyWith(
        errorMessage: e.toString(),
      ));
    }
  }

  /// Check if input is a function that requires parentheses
  bool _isFunctionInput(String value) {
    const functions = [
      'sin',
      'cos',
      'tan',
      'asin',
      'acos',
      'atan',
      'ln',
      'log10',
      'sqrt',
      'exp'
    ];
    return functions.contains(value);
  }

  /// Perform live evaluation of the expression
  void _liveEvaluate() {
    try {
      if (_state.displayExpression.isEmpty) {
        _updateState(_state.copyWith(result: '0'));
        return;
      }

      // Auto-close parentheses for evaluation
      String expr =
          CalculatorEngine.autoCloseParentheses(_state.displayExpression);

      String result = CalculatorEngine.evaluate(
        expr,
        isDegrees: _state.angleMode == AngleMode.degrees,
      );

      _updateState(_state.copyWith(result: result));
    } catch (e) {
      // Don't show errors during live evaluation, only on explicit calculate
      if (kDebugMode) {
        print('Live eval error: $e');
      }
    }
  }

  /// Calculate the final result
  void calculate() {
    try {
      if (_state.displayExpression.isEmpty) {
        return;
      }

      // Auto-close parentheses
      String expr =
          CalculatorEngine.autoCloseParentheses(_state.displayExpression);

      String result = CalculatorEngine.evaluate(
        expr,
        isDegrees: _state.angleMode == AngleMode.degrees,
      );

      // Add to history
      final history = List<CalculationHistory>.from(_state.history);
      history.insert(
        0,
        CalculationHistory(
          expression: _state.displayExpression,
          result: result,
          timestamp: DateTime.now(),
        ),
      );

      // Keep only last 50 history items
      if (history.length > 50) {
        history.removeRange(50, history.length);
      }

      _updateState(_state.copyWith(
        result: result,
        history: history,
        shouldClearOnNextInput: true,
        errorMessage: null,
      ));
    } catch (e) {
      _updateState(_state.copyWith(
        errorMessage: e.toString(),
        shouldClearOnNextInput: true,
      ));
    }
  }

  /// Clear all
  void clear() {
    _updateState(const CalculatorState());
  }

  /// Backspace - remove last character
  void backspace() {
    if (_state.displayExpression.isEmpty) return;

    String expr = _state.displayExpression;

    // Check if last input is a function name
    final functions = ['sin', 'cos', 'tan', 'asin', 'acos', 'atan', 'ln', 'log10', 'sqrt', 'exp'];
    
    for (String func in functions) {
      if (expr.endsWith('$func(')) {
        expr = expr.substring(0, expr.length - func.length - 1);
        _updateState(_state.copyWith(displayExpression: expr));
        _liveEvaluate();
        return;
      }
    }

    // Regular backspace
    expr = expr.substring(0, expr.length - 1);
    _updateState(_state.copyWith(displayExpression: expr));
    _liveEvaluate();
  }

  /// Toggle sign of current number
  void toggleSign() {
    String expr = _state.displayExpression;

    if (expr.isEmpty) return;

    // Find the last number in the expression
    final match = RegExp(r'([\d.]+)$').firstMatch(expr);

    if (match != null) {
      String number = match.group(1)!;
      int start = match.start;

      // Check if already negative
      if (start > 0 && expr[start - 1] == '-') {
        // Remove the negative sign
        expr = expr.substring(0, start - 1) + number;
      } else {
        // Add negative sign
        expr = expr.substring(0, start) + '-' + number;
      }

      _updateState(_state.copyWith(displayExpression: expr));
      _liveEvaluate();
    }
  }

  /// Toggle between degrees and radians
  void toggleAngleMode() {
    final newMode = _state.angleMode == AngleMode.degrees
        ? AngleMode.radians
        : AngleMode.degrees;

    _updateState(_state.copyWith(angleMode: newMode));
    _liveEvaluate();
  }

  /// Memory clear
  void memoryClear() {
    _memory.clear();
    _updateState(_state.copyWith(memory: 0));
  }

  /// Memory recall
  void memoryRecall() {
    if (_memory.hasValue) {
      String memValue = _memory.value.toString();
      input(memValue);
    }
  }

  /// Memory add
  void memoryAdd() {
    try {
      double currentValue = double.parse(_state.result);
      _memory.add(currentValue);
      _updateState(_state.copyWith(memory: _memory.value));
    } catch (e) {
      if (kDebugMode) {
        print('Memory add error: $e');
      }
    }
  }

  /// Memory subtract
  void memorySubtract() {
    try {
      double currentValue = double.parse(_state.result);
      _memory.subtract(currentValue);
      _updateState(_state.copyWith(memory: _memory.value));
    } catch (e) {
      if (kDebugMode) {
        print('Memory subtract error: $e');
      }
    }
  }

  /// Clear history
  void clearHistory() {
    _updateState(_state.copyWith(history: []));
  }

  /// Load expression from history
  void loadFromHistory(CalculationHistory history) {
    _updateState(_state.copyWith(
      displayExpression: history.expression,
      result: history.result,
      shouldClearOnNextInput: false,
    ));
  }

  void _updateState(CalculatorState newState) {
    _state = newState;
    notifyListeners();
  }
}
