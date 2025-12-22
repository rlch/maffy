import 'package:equatable/equatable.dart';

/// Angle mode for trigonometric functions
enum AngleMode { degrees, radians }

/// Calculator state model
class CalculatorState extends Equatable {
  final String displayExpression;
  final String result;
  final double memory;
  final AngleMode angleMode;
  final List<CalculationHistory> history;
  final String? errorMessage;
  final bool shouldClearOnNextInput;

  const CalculatorState({
    this.displayExpression = '',
    this.result = '0',
    this.memory = 0,
    this.angleMode = AngleMode.degrees,
    this.history = const [],
    this.errorMessage,
    this.shouldClearOnNextInput = false,
  });

  CalculatorState copyWith({
    String? displayExpression,
    String? result,
    double? memory,
    AngleMode? angleMode,
    List<CalculationHistory>? history,
    String? errorMessage,
    bool? shouldClearOnNextInput,
  }) {
    return CalculatorState(
      displayExpression: displayExpression ?? this.displayExpression,
      result: result ?? this.result,
      memory: memory ?? this.memory,
      angleMode: angleMode ?? this.angleMode,
      history: history ?? this.history,
      errorMessage: errorMessage,
      shouldClearOnNextInput:
          shouldClearOnNextInput ?? this.shouldClearOnNextInput,
    );
  }

  CalculatorState clearError() {
    return copyWith(errorMessage: null);
  }

  @override
  List<Object?> get props => [
        displayExpression,
        result,
        memory,
        angleMode,
        history,
        errorMessage,
        shouldClearOnNextInput,
      ];
}

/// History entry for calculations
class CalculationHistory extends Equatable {
  final String expression;
  final String result;
  final DateTime timestamp;

  const CalculationHistory({
    required this.expression,
    required this.result,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [expression, result, timestamp];
}
