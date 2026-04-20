import 'dart:math' as math;

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

                // Plot surfaces/curves for functions
                ...state.visibleFunctions.map((func) => _buildPlot(func, state)),

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

  /// Strip "y = ..." or "f(x) = ..." prefixes so what remains is f(x).
  String _stripPrefix(String latex) {
    final yEq = RegExp(r'^y\s*=\s*(.+)$').firstMatch(latex);
    if (yEq != null) return yEq.group(1)!;
    final fnDef = RegExp(r'^[a-zA-Z]\s*\([a-zA-Z]\)\s*=\s*(.+)$').firstMatch(latex);
    if (fnDef != null) return fnDef.group(1)!;
    return latex;
  }

  Widget _buildPlot(func, GraphState state) {
    final parser = ExpressionParserService();
    final latex = _stripPrefix(func.latex);
    final result = parser.parseTeX(latex);

    if (result is! ParseSuccess) {
      return const SizedBox.shrink();
    }

    // If the expression only depends on x (no y, no z), render it as a 2D
    // curve y = f(x) lying in the xy-plane rather than a surface that
    // spans the z dimension.
    final vars = parser.extractVariables(result.expression);
    final isPlanarCurve = !vars.contains('y') && !vars.contains('z');

    if (isPlanarCurve) {
      // Sample y = f(x) along the visible x range, skipping NaN values so
      // the curve breaks cleanly around discontinuities.
      const segments = 300;
      final dx = (state.xMax - state.xMin) / segments;
      final points = <Vector3>[];
      for (int i = 0; i <= segments; i++) {
        final x = state.xMin + i * dx;
        final y = parser.evaluate(
          result.expression,
          x,
          variables: state.sliderValues,
        );
        points.add(Vector3(x, y ?? double.nan, 0));
      }

      // Thickness scales with the current viewbox so the curve stays
      // visually proportional when the user zooms in or out.
      final halfWidth = 0.0015 *
          math.min(state.xMax - state.xMin, state.yMax - state.yMin);

      return _buildTubeMesh(points, halfWidth, func.color);
    }

    // For 3D, interpret the function as z = f(x, y)
    return Surface3D.fromFunction(
      z: (x, y) {
        final variables = Map<String, double>.from(state.sliderValues);
        variables['y'] = y;

        final z = parser.evaluate(
          result.expression,
          x,
          variables: variables,
        );
        return z ?? double.nan;
      },
      xDomain: (state.xMin, state.xMax),
      yDomain: (state.yMin, state.yMax),
      colorScale: ColorScales.viridis,
    );
  }

  /// Build a rectangular-cross-section tube mesh along a curve so the line
  /// has visible thickness from any viewing angle — three.js does not honor
  /// linewidth > 1 on most platforms. Points with non-finite y split the
  /// tube into disjoint segments.
  Widget _buildTubeMesh(List<Vector3> points, double halfWidth, Color color) {
    final vertices = <Vector3>[];
    final faces = <List<int>>[];

    void flush(List<Vector3> segment) {
      if (segment.length < 2) return;
      final base = vertices.length;

      for (int i = 0; i < segment.length; i++) {
        final prev = segment[i == 0 ? i : i - 1];
        final next = segment[i == segment.length - 1 ? i : i + 1];
        var tx = next.x - prev.x;
        var ty = next.y - prev.y;
        final len = math.sqrt(tx * tx + ty * ty);
        if (len < 1e-12) {
          tx = 1;
          ty = 0;
        } else {
          tx /= len;
          ty /= len;
        }
        // In-plane normal perpendicular to the tangent in the xy-plane.
        final nx = ty;
        final ny = -tx;

        final p = segment[i];
        // Four corners of the cross-section: (+n+z), (-n+z), (-n-z), (+n-z).
        vertices.add(Vector3(
            p.x + halfWidth * nx, p.y + halfWidth * ny, p.z + halfWidth));
        vertices.add(Vector3(
            p.x - halfWidth * nx, p.y - halfWidth * ny, p.z + halfWidth));
        vertices.add(Vector3(
            p.x - halfWidth * nx, p.y - halfWidth * ny, p.z - halfWidth));
        vertices.add(Vector3(
            p.x + halfWidth * nx, p.y + halfWidth * ny, p.z - halfWidth));
      }

      for (int i = 0; i < segment.length - 1; i++) {
        final a = base + i * 4;
        final b = a + 1;
        final c = a + 2;
        final d = a + 3;
        final a2 = base + (i + 1) * 4;
        final b2 = a2 + 1;
        final c2 = a2 + 2;
        final d2 = a2 + 3;
        faces.add([a, b, b2]);
        faces.add([a, b2, a2]);
        faces.add([b, c, c2]);
        faces.add([b, c2, b2]);
        faces.add([c, d, d2]);
        faces.add([c, d2, c2]);
        faces.add([d, a, a2]);
        faces.add([d, a2, d2]);
      }
    }

    final current = <Vector3>[];
    for (final p in points) {
      if (!p.y.isFinite) {
        flush(current);
        current.clear();
      } else {
        current.add(p);
      }
    }
    flush(current);

    if (faces.isEmpty) return const SizedBox.shrink();

    return Mesh3D(
      vertices: vertices,
      faces: faces,
      color: color,
      opacity: 1.0,
    );
  }

  Widget _buildPoint3D(point) {
    return Point3D(
      position: Vector3(point.x ?? 0, point.y ?? 0, point.z ?? 0),
      color: point.color,
    );
  }
}
