import 'package:flutter/widgets.dart';
import 'package:flutter_plot/flutter_plot.dart';
import 'package:provider/provider.dart';

import '../providers/graph_state.dart';
import '../services/expression_parser.dart';

/// The 3D graph view using flutter-plot
class GraphView3D extends StatelessWidget {
  const GraphView3D({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GraphState>(
      builder: (context, state, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Plot3D(
              // Let it fill available space
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              viewBox: ViewBox3D(
                x: (state.xMin, state.xMax),
                y: (state.yMin, state.yMax),
                z: (state.zMin, state.zMax),
              ),
              controls: const OrbitControlsConfig(),
              children: [
                // 3D axes
                Axes3D.cartesian(),

                // Plot surfaces for 3D functions
                ...state.visibleFunctions.map((func) => _buildSurface(func, state)),

                // Plot 3D points
                ...state.visiblePoints
                    .where((p) => p.z != null)
                    .map((point) => _buildPoint3D(point)),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSurface(func, GraphState state) {
    final parser = ExpressionParserService();
    final result = parser.parseTeX(func.latex);

    if (result is! ParseSuccess) {
      return const SizedBox.shrink();
    }

    // For 3D, we interpret the function as z = f(x, y)
    return Surface3D.fromFunction(
      z: (x, y) {
        // Bind both x and y for 3D evaluation
        final variables = Map<String, double>.from(state.sliderValues);
        variables['y'] = y;
        
        final z = parser.evaluate(
          result.expression,
          x,
          variables: variables,
        );
        return z ?? double.nan;
      },
      colorScale: ColorScales.viridis,
    );
  }

  Widget _buildPoint3D(point) {
    return Point3D(
      position: Vector3(point.x ?? 0, point.y ?? 0, point.z ?? 0),
      color: point.color,
    );
  }
}
