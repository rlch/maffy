import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:uuid/uuid.dart';

import '../models/expression_entry.dart';
import '../models/graph_colors.dart';
import '../services/expression_parser.dart';

/// Manages the state of the graphing calculator
class GraphState extends ChangeNotifier {
  final _uuid = const Uuid();
  final _parser = ExpressionParserService();

  /// All expression entries in the sidebar
  final List<ExpressionEntry> _entries = [];
  List<ExpressionEntry> get entries => List.unmodifiable(_entries);

  /// Current color index for new expressions
  int _colorIndex = 0;

  /// Whether we're in 2D or 3D mode
  bool _is3DMode = false;
  bool get is3DMode => _is3DMode;

  /// View bounds for the graph
  double _xMin = -10;
  double _xMax = 10;
  double _yMin = -10;
  double _yMax = 10;
  double _zMin = -10;
  double _zMax = 10;

  double get xMin => _xMin;
  double get xMax => _xMax;
  double get yMin => _yMin;
  double get yMax => _yMax;
  double get zMin => _zMin;
  double get zMax => _zMax;

  GraphState() {
    // Start with one empty expression slot
    _entries.add(EmptyExpression(id: _uuid.v4()));
  }

  /// Toggle between 2D and 3D mode
  void toggleMode() {
    _is3DMode = !_is3DMode;
    notifyListeners();
  }

  /// Set 2D/3D mode explicitly
  void setMode({required bool is3D}) {
    _is3DMode = is3D;
    notifyListeners();
  }

  /// Add a new function expression
  void addFunction(String latex) {
    final result = _parser.parseTeX(latex);
    final entry = switch (result) {
      ParseSuccess(:final expression) => FunctionExpression(
          id: _uuid.v4(),
          latex: latex,
          color: GraphColors.getColor(_colorIndex++),
          variables: _parser.extractVariables(expression),
        ),
      ParseError(:final message) => FunctionExpression(
          id: _uuid.v4(),
          latex: latex,
          color: GraphColors.getColor(_colorIndex++),
          error: message,
        ),
    };

    _insertBeforeEmpty(entry);
    notifyListeners();
  }

  /// Add a new slider variable
  void addSlider(String name, {double value = 0, double min = -10, double max = 10}) {
    final entry = SliderExpression(
      id: _uuid.v4(),
      name: name,
      value: value,
      min: min,
      max: max,
    );
    _insertBeforeEmpty(entry);
    notifyListeners();
  }

  /// Add a point
  void addPoint(double x, double y, {double? z}) {
    final latex = z != null ? '($x, $y, $z)' : '($x, $y)';
    final entry = PointExpression(
      id: _uuid.v4(),
      latex: latex,
      x: x,
      y: y,
      z: z,
      color: GraphColors.getColor(_colorIndex++),
    );
    _insertBeforeEmpty(entry);
    notifyListeners();
  }

  /// Update an existing expression's LaTeX
  void updateExpression(String id, String latex) {
    final index = _entries.indexWhere((e) => e.id == id);
    if (index == -1) return;

    final entry = _entries[index];

    if (entry is FunctionExpression) {
      final result = _parser.parseTeX(latex);
      _entries[index] = switch (result) {
        ParseSuccess(:final expression) => entry.copyWith(
            latex: latex,
            variables: _parser.extractVariables(expression),
            error: null,
          ),
        ParseError(:final message) => entry.copyWith(
            latex: latex,
            error: message,
          ),
      };
    } else if (entry is EmptyExpression && latex.isNotEmpty) {
      // Convert empty to function, but DON'T add new empty slot yet
      // (that happens in commitExpression to avoid focus loss)
      final result = _parser.parseTeX(latex);
      _entries[index] = switch (result) {
        ParseSuccess(:final expression) => FunctionExpression(
            id: id,
            latex: latex,
            color: GraphColors.getColor(_colorIndex++),
            variables: _parser.extractVariables(expression),
          ),
        ParseError(:final message) => FunctionExpression(
            id: id,
            latex: latex,
            color: GraphColors.getColor(_colorIndex++),
            error: message,
          ),
      };
    }

    notifyListeners();
  }

  /// Call this when user finishes editing (blur/submit) to ensure there's an empty slot
  void ensureEmptySlot() {
    // Only add empty slot if the last entry isn't already empty
    if (_entries.isEmpty || _entries.last is! EmptyExpression) {
      _entries.add(EmptyExpression(id: _uuid.v4()));
      notifyListeners();
    }
  }

  /// Update a slider's value
  void updateSliderValue(String id, double value) {
    final index = _entries.indexWhere((e) => e.id == id);
    if (index == -1) return;

    final entry = _entries[index];
    if (entry is SliderExpression) {
      _entries[index] = entry.copyWith(value: value);
      notifyListeners();
    }
  }

  /// Toggle animation for a slider
  void toggleSliderAnimation(String id) {
    final index = _entries.indexWhere((e) => e.id == id);
    if (index == -1) return;

    final entry = _entries[index];
    if (entry is SliderExpression) {
      _entries[index] = entry.copyWith(isAnimating: !entry.isAnimating);
      notifyListeners();
    }
  }

  /// Toggle visibility of an expression
  void toggleVisibility(String id) {
    final index = _entries.indexWhere((e) => e.id == id);
    if (index == -1) return;

    _entries[index] = _entries[index].copyWith(isVisible: !_entries[index].isVisible);
    notifyListeners();
  }

  /// Remove an expression
  void removeExpression(String id) {
    _entries.removeWhere((e) => e.id == id);

    // Ensure there's always at least one empty slot
    if (_entries.isEmpty || _entries.last is! EmptyExpression) {
      _entries.add(EmptyExpression(id: _uuid.v4()));
    }

    notifyListeners();
  }

  /// Change the color of an expression
  void changeColor(String id, Color color) {
    final index = _entries.indexWhere((e) => e.id == id);
    if (index == -1) return;

    final entry = _entries[index];
    if (entry is FunctionExpression) {
      _entries[index] = entry.copyWith(color: color);
    } else if (entry is PointExpression) {
      _entries[index] = entry.copyWith(color: color);
    }

    notifyListeners();
  }

  /// Update view bounds
  void setViewBounds({
    double? xMin,
    double? xMax,
    double? yMin,
    double? yMax,
    double? zMin,
    double? zMax,
  }) {
    _xMin = xMin ?? _xMin;
    _xMax = xMax ?? _xMax;
    _yMin = yMin ?? _yMin;
    _yMax = yMax ?? _yMax;
    _zMin = zMin ?? _zMin;
    _zMax = zMax ?? _zMax;
    notifyListeners();
  }

  /// Get all slider variable values for evaluation
  Map<String, double> get sliderValues {
    final values = <String, double>{};
    for (final entry in _entries) {
      if (entry is SliderExpression) {
        values[entry.name] = entry.value;
      }
    }
    return values;
  }

  /// Get all defined variable names (from sliders)
  Set<String> get definedVariables {
    return _entries
        .whereType<SliderExpression>()
        .map((e) => e.name)
        .toSet();
  }

  /// Get undefined variables for a given latex expression
  Set<String> getUndefinedVariables(String latex) {
    final result = _parser.parseTeX(latex);
    if (result is! ParseSuccess) return {};

    return _parser.getUndefinedVariables(
      result.expression,
      definedVariables: definedVariables,
    );
  }

  /// Check if a slider with this name already exists
  bool hasSlider(String name) {
    return _entries.whereType<SliderExpression>().any((e) => e.name == name);
  }

  /// Get all visible function expressions
  List<FunctionExpression> get visibleFunctions {
    return _entries
        .whereType<FunctionExpression>()
        .where((e) => e.isVisible && e.error == null)
        .toList();
  }

  /// Get all visible point expressions
  List<PointExpression> get visiblePoints {
    return _entries
        .whereType<PointExpression>()
        .where((e) => e.isVisible && e.error == null)
        .toList();
  }

  void _insertBeforeEmpty(ExpressionEntry entry) {
    // Insert before the last empty entry
    final lastEmptyIndex = _entries.lastIndexWhere((e) => e is EmptyExpression);
    if (lastEmptyIndex >= 0) {
      _entries.insert(lastEmptyIndex, entry);
    } else {
      _entries.add(entry);
      _entries.add(EmptyExpression(id: _uuid.v4()));
    }
  }
}
