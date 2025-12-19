import 'package:equatable/equatable.dart';
import 'package:flutter/painting.dart';

/// Represents a single entry in the expression list (like Desmos sidebar)
sealed class ExpressionEntry extends Equatable {
  final String id;
  final bool isVisible;

  const ExpressionEntry({
    required this.id,
    this.isVisible = true,
  });

  ExpressionEntry copyWith({bool? isVisible});
}

/// A mathematical function expression like f(x) = x^2
class FunctionExpression extends ExpressionEntry {
  /// The raw TeX string from the math keyboard
  final String latex;

  /// The function name (e.g., "f", "g", "h")
  final String? functionName;

  /// The variable(s) used (e.g., "x", "y", "t")
  final Set<String> variables;

  /// The color to render this function
  final Color color;

  /// Any error from parsing
  final String? error;

  const FunctionExpression({
    required super.id,
    required this.latex,
    this.functionName,
    this.variables = const {'x'},
    required this.color,
    this.error,
    super.isVisible = true,
  });

  @override
  List<Object?> get props => [id, latex, functionName, variables, color, isVisible, error];

  @override
  FunctionExpression copyWith({
    String? latex,
    String? functionName,
    Set<String>? variables,
    Color? color,
    String? error,
    bool? isVisible,
  }) {
    return FunctionExpression(
      id: id,
      latex: latex ?? this.latex,
      functionName: functionName ?? this.functionName,
      variables: variables ?? this.variables,
      color: color ?? this.color,
      error: error,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

/// A variable slider like L = 0.2 with range [-10, 10]
class SliderExpression extends ExpressionEntry {
  /// The variable name
  final String name;

  /// Current value
  final double value;

  /// Minimum value
  final double min;

  /// Maximum value
  final double max;

  /// Step size (null for continuous)
  final double? step;

  /// Whether the slider is currently animating
  final bool isAnimating;

  const SliderExpression({
    required super.id,
    required this.name,
    required this.value,
    this.min = -10,
    this.max = 10,
    this.step,
    this.isAnimating = false,
    super.isVisible = true,
  });

  @override
  List<Object?> get props => [id, name, value, min, max, step, isAnimating, isVisible];

  @override
  SliderExpression copyWith({
    String? name,
    double? value,
    double? min,
    double? max,
    double? step,
    bool? isAnimating,
    bool? isVisible,
  }) {
    return SliderExpression(
      id: id,
      name: name ?? this.name,
      value: value ?? this.value,
      min: min ?? this.min,
      max: max ?? this.max,
      step: step ?? this.step,
      isAnimating: isAnimating ?? this.isAnimating,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

/// A point to plot like (2, 3)
class PointExpression extends ExpressionEntry {
  final String latex;
  final double? x;
  final double? y;
  final double? z; // For 3D
  final Color color;
  final String? error;

  const PointExpression({
    required super.id,
    required this.latex,
    this.x,
    this.y,
    this.z,
    required this.color,
    this.error,
    super.isVisible = true,
  });

  @override
  List<Object?> get props => [id, latex, x, y, z, color, isVisible, error];

  @override
  PointExpression copyWith({
    String? latex,
    double? x,
    double? y,
    double? z,
    Color? color,
    String? error,
    bool? isVisible,
  }) {
    return PointExpression(
      id: id,
      latex: latex ?? this.latex,
      x: x ?? this.x,
      y: y ?? this.y,
      z: z ?? this.z,
      color: color ?? this.color,
      error: error,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

/// An empty expression slot (for adding new expressions)
class EmptyExpression extends ExpressionEntry {
  const EmptyExpression({required super.id});

  @override
  List<Object?> get props => [id];

  @override
  EmptyExpression copyWith({bool? isVisible}) => this;
}
