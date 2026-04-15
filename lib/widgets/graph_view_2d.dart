import 'package:flutter/widgets.dart';
import 'package:mafs_flutter/mafs_flutter.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:provider/provider.dart';

import '../models/expression_entry.dart';
import '../providers/editing_state.dart';
import '../providers/graph_state.dart';
import '../services/expression_parser.dart';

/// The 2D graph view using mafs-flutter
class GraphView2D extends StatelessWidget {
  const GraphView2D({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch both GraphState and EditingState for updates
    final graphState = context.watch<GraphState>();
    final editingState = context.watch<EditingState>();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Mafs(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          viewBox: ViewBox(
            x: (graphState.xMin, graphState.xMax),
            y: (graphState.yMin, graphState.yMax),
          ),
          pan: true,
          zoom: true,
          children: [
            // Coordinate grid
            Coordinates.cartesian(),

            // Plot all visible functions
            ...graphState.visibleFunctions.expand(
              (func) => _buildPlot(func, graphState, editingState),
            ),

            // Plot functions from empty expressions being edited
            ...graphState.entries
                .whereType<EmptyExpression>()
                .where((e) => editingState.hasLiveValue(e.id))
                .expand((e) => _buildLivePlot(e.id, graphState, editingState)),

            // Plot all visible points
            ...graphState.visiblePoints.map((point) => _buildPoint(point)),
          ],
        );
      },
    );
  }

  /// Parse and strip common prefixes from latex (y=..., f(x)=...)
  String _stripPrefix(String latex) {
    // Handle "y = ..." format - strip the "y = " prefix
    final yEqualsMatch = RegExp(r'^y\s*=\s*(.+)$').firstMatch(latex);
    if (yEqualsMatch != null) return yEqualsMatch.group(1)!;

    // Handle "f(x) = ..." format - strip the function definition prefix
    final funcDefMatch =
        RegExp(r'^[a-zA-Z]\s*\([a-zA-Z]\)\s*=\s*(.+)$').firstMatch(latex);
    if (funcDefMatch != null) return funcDefMatch.group(1)!;

    return latex;
  }

  List<Widget> _buildPlot(
    FunctionExpression func,
    GraphState graphState,
    EditingState editingState,
  ) {
    final parser = ExpressionParserService();

    // Use live value if being edited, otherwise use committed value
    final latex =
        _stripPrefix(editingState.getLiveValue(func.id) ?? func.latex);

    final result = parser.parseTeX(latex);
    if (result is! ParseSuccess) return const [];

    // Check if expression contains y variable — render as implicit curve
    final vars = parser.extractVariables(result.expression);
    if (vars.contains('y')) {
      return _buildImplicitSegments(
        func.id, result.expression, graphState, func.color, parser,
      );
    }

    return [
      Plot.ofX(
        key: ValueKey('plot-${func.id}'),
        y: (x) {
          final y = parser.evaluate(
            result.expression,
            x,
            variables: graphState.sliderValues,
          );
          return y ?? double.nan;
        },
        color: func.color,
      ),
    ];
  }

  List<Widget> _buildLivePlot(
    String id,
    GraphState graphState,
    EditingState editingState,
  ) {
    final parser = ExpressionParserService();
    final latex = _stripPrefix(editingState.getLiveValue(id) ?? '');

    final result = parser.parseTeX(latex);
    if (result is! ParseSuccess) return const [];

    const defaultColor = Color(0xFFC74440);

    // Check if expression contains y variable — render as implicit curve
    final vars = parser.extractVariables(result.expression);
    if (vars.contains('y')) {
      return _buildImplicitSegments(
          id, result.expression, graphState, defaultColor, parser);
    }

    return [
      Plot.ofX(
        key: ValueKey('live-plot-$id'),
        y: (x) {
          final y = parser.evaluate(
            result.expression,
            x,
            variables: graphState.sliderValues,
          );
          return y ?? double.nan;
        },
        color: defaultColor,
      ),
    ];
  }

  /// Render an implicit curve f(x,y) = 0 using marching squares.
  /// Returns a list of MafsPolyline segments.
  List<Widget> _buildImplicitSegments(
    String id,
    Expression expression,
    GraphState graphState,
    Color color,
    ExpressionParserService parser,
  ) {
    const resolution = 150;
    final xStep = (graphState.xMax - graphState.xMin) / resolution;
    final yStep = (graphState.yMax - graphState.yMin) / resolution;
    final sliders = graphState.sliderValues;

    // Evaluate the function on a grid
    final grid = List.generate(resolution + 1, (i) {
      final x = graphState.xMin + i * xStep;
      return List.generate(resolution + 1, (j) {
        final y = graphState.yMin + j * yStep;
        return parser.evaluateXY(expression, x, y, variables: sliders) ??
            double.nan;
      });
    });

    // Extract line segments where the function crosses zero (marching squares)
    final segments = <(Offset, Offset)>[];
    for (int i = 0; i < resolution; i++) {
      for (int j = 0; j < resolution; j++) {
        final v00 = grid[i][j];
        final v10 = grid[i + 1][j];
        final v01 = grid[i][j + 1];
        final v11 = grid[i + 1][j + 1];

        if (v00.isNaN || v10.isNaN || v01.isNaN || v11.isNaN) continue;

        final x0 = graphState.xMin + i * xStep;
        final x1 = x0 + xStep;
        final y0 = graphState.yMin + j * yStep;
        final y1 = y0 + yStep;

        // Classify corners by sign
        final c = (v00 > 0 ? 8 : 0) |
            (v10 > 0 ? 4 : 0) |
            (v11 > 0 ? 2 : 0) |
            (v01 > 0 ? 1 : 0);

        if (c == 0 || c == 15) continue;

        // Linear interpolation for zero crossing
        double lerp(double a, double b, double va, double vb) {
          if ((vb - va).abs() < 1e-12) return (a + b) / 2;
          return a + (b - a) * (-va / (vb - va));
        }

        final top = Offset(lerp(x0, x1, v01, v11), y1);
        final bottom = Offset(lerp(x0, x1, v00, v10), y0);
        final left = Offset(x0, lerp(y0, y1, v00, v01));
        final right = Offset(x1, lerp(y0, y1, v10, v11));

        switch (c) {
          case 1 || 14:
            segments.add((left, top));
          case 2 || 13:
            segments.add((top, right));
          case 3 || 12:
            segments.add((left, right));
          case 4 || 11:
            segments.add((bottom, right));
          case 5:
            segments.add((left, bottom));
            segments.add((top, right));
          case 6 || 9:
            segments.add((top, bottom));
          case 7 || 8:
            segments.add((left, bottom));
          case 10:
            segments.add((left, top));
            segments.add((bottom, right));
        }
      }
    }

    if (segments.isEmpty) return const [];

    // Chain adjacent segments into polylines to reduce widget count
    final polylines = _chainSegments(segments);

    return [
      for (int i = 0; i < polylines.length; i++)
        MafsPolyline(
          key: ValueKey('implicit-$id-$i'),
          points: polylines[i],
          color: color,
          weight: 2,
        ),
    ];
  }

  /// Chain nearby segments into longer polylines to reduce widget count
  List<List<Offset>> _chainSegments(List<(Offset, Offset)> segments) {
    if (segments.isEmpty) return [];

    const threshold = 1e-8;
    final used = List.filled(segments.length, false);
    final chains = <List<Offset>>[];

    for (int i = 0; i < segments.length; i++) {
      if (used[i]) continue;
      used[i] = true;

      final chain = [segments[i].$1, segments[i].$2];

      // Try to extend the chain forward
      bool extended = true;
      while (extended) {
        extended = false;
        final tail = chain.last;
        for (int j = 0; j < segments.length; j++) {
          if (used[j]) continue;
          final (a, b) = segments[j];
          if ((a - tail).distanceSquared < threshold) {
            chain.add(b);
            used[j] = true;
            extended = true;
            break;
          } else if ((b - tail).distanceSquared < threshold) {
            chain.add(a);
            used[j] = true;
            extended = true;
            break;
          }
        }
      }

      chains.add(chain);
    }

    return chains;
  }

  Widget _buildPoint(PointExpression point) {
    if (point.x == null || point.y == null) {
      return const SizedBox.shrink();
    }

    return MafsPoint(
      x: point.x!,
      y: point.y!,
      color: point.color,
    );
  }
}
