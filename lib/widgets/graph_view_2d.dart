import 'package:flutter/widgets.dart';
import 'package:mafs_flutter/mafs_flutter.dart';
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
            ...graphState.visibleFunctions.map(
              (func) => _buildPlot(func, graphState, editingState),
            ),

            // Plot functions from empty expressions being edited
            ...graphState.entries
                .whereType<EmptyExpression>()
                .where((e) => editingState.hasLiveValue(e.id))
                .map((e) => _buildLivePlot(e.id, graphState, editingState)),

            // Plot all visible points
            ...graphState.visiblePoints.map((point) => _buildPoint(point)),
          ],
        );
      },
    );
  }

  Widget _buildPlot(
    FunctionExpression func,
    GraphState graphState,
    EditingState editingState,
  ) {
    final parser = ExpressionParserService();

    // Use live value if being edited, otherwise use committed value
    var latex = editingState.getLiveValue(func.id) ?? func.latex;

    // Handle "y = ..." format - strip the "y = " prefix
    final yEqualsMatch = RegExp(r'^y\s*=\s*(.+)$').firstMatch(latex);
    if (yEqualsMatch != null) {
      latex = yEqualsMatch.group(1)!;
    }

    // Handle "f(x) = ..." format - strip the function definition prefix
    final funcDefMatch = RegExp(r'^[a-zA-Z]\s*\([a-zA-Z]\)\s*=\s*(.+)$').firstMatch(latex);
    if (funcDefMatch != null) {
      latex = funcDefMatch.group(1)!;
    }

    final result = parser.parseTeX(latex);

    if (result is! ParseSuccess) {
      return const SizedBox.shrink();
    }

    return Plot.ofX(
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
    );
  }

  Widget _buildLivePlot(
    String id,
    GraphState graphState,
    EditingState editingState,
  ) {
    final parser = ExpressionParserService();
    var latex = editingState.getLiveValue(id) ?? '';

    // Handle "y = ..." format
    final yEqualsMatch = RegExp(r'^y\s*=\s*(.+)$').firstMatch(latex);
    if (yEqualsMatch != null) {
      latex = yEqualsMatch.group(1)!;
    }

    // Handle "f(x) = ..." format
    final funcDefMatch = RegExp(r'^[a-zA-Z]\s*\([a-zA-Z]\)\s*=\s*(.+)$').firstMatch(latex);
    if (funcDefMatch != null) {
      latex = funcDefMatch.group(1)!;
    }

    final result = parser.parseTeX(latex);

    if (result is! ParseSuccess) {
      return const SizedBox.shrink();
    }

    // Use a default color for live editing
    return Plot.ofX(
      key: ValueKey('live-plot-$id'),
      y: (x) {
        final y = parser.evaluate(
          result.expression,
          x,
          variables: graphState.sliderValues,
        );
        return y ?? double.nan;
      },
      color: const Color(0xFFC74440), // Default red
    );
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
