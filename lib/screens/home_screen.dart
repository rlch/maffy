import 'package:flutter/material.dart';
import 'package:math_keyboard/math_keyboard.dart';
import 'package:provider/provider.dart';

import '../providers/graph_state.dart';
import '../theme/geogebra_theme.dart';
import '../widgets/expression_sidebar.dart';
import '../widgets/geogebra_app_bar.dart';
import '../widgets/graph_view_2d.dart';
import '../widgets/graph_view_3d.dart';
import '../widgets/navigation_drawer.dart';

/// GeoGebra-style graphing calculator home screen.
///
/// Layout:
///  - [GeoGebraAppBar] at the top with the Maffy logo and current app name.
///  - Left: [ExpressionSidebar] (expressions, sliders, points).
///  - Center: 2D or 3D graph view.
///  - Right floating column: zoom +/-, reset and more-options buttons.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MathKeyboardViewInsets(
      child: Scaffold(
        backgroundColor: GG.appBg,
        drawer: const NavigationDrawerWidget(),
        body: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Builder(
                builder: (context) => GeoGebraAppBar(
                  subtitle: context.watch<GraphState>().is3DMode
                      ? '3D Calculator'
                      : 'Graphing Calculator',
                  onMenuTap: () => Scaffold.of(context).openDrawer(),
                  actions: [
                    GeoGebraHeaderAction(
                      icon: Icons.help_outline,
                      label: 'Help',
                      onPressed: () => _showHelp(context),
                    ),
                    GeoGebraHeaderAction(
                      icon: Icons.save_outlined,
                      label: 'Save',
                      primary: true,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  const ExpressionSidebar(),
                  Expanded(child: _GraphArea()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Maffy — Graphing Calculator'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How to use',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text('• Type expressions like x^2 or sin(x)'),
              Text('• Use the + button to add sliders or points'),
              Text('• Click the colored circle to toggle visibility'),
              Text('• Drag on the graph to pan, scroll to zoom'),
              Text('• Switch between 2D and 3D from the menu'),
              SizedBox(height: 16),
              Text(
                'Supported functions',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text('sin, cos, tan, sqrt, ln, log, abs, floor, ceil'),
              Text('asin, acos, atan, sinh, cosh, tanh'),
              Text('e^x, x^n, x!, nCr, nPr'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class _GraphArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GraphState>(
      builder: (context, state, _) {
        return Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.white,
                child: state.is3DMode
                    ? const GraphView3D()
                    : const GraphView2D(),
              ),
            ),
            Positioned(
              right: 16,
              top: 16,
              child: _GraphControls(state: state),
            ),
          ],
        );
      },
    );
  }
}

class _GraphControls extends StatelessWidget {
  final GraphState state;
  const _GraphControls({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FloatButton(
          icon: Icons.add,
          tooltip: 'Zoom in',
          onTap: () => _zoom(0.8),
        ),
        const SizedBox(height: 8),
        _FloatButton(
          icon: Icons.remove,
          tooltip: 'Zoom out',
          onTap: () => _zoom(1.25),
        ),
        const SizedBox(height: 8),
        _FloatButton(
          icon: Icons.filter_center_focus,
          tooltip: 'Reset view',
          onTap: () => state.setViewBounds(
            xMin: -10,
            xMax: 10,
            yMin: -10,
            yMax: 10,
          ),
        ),
      ],
    );
  }

  void _zoom(double factor) {
    final xCenter = (state.xMin + state.xMax) / 2;
    final yCenter = (state.yMin + state.yMax) / 2;
    final xRange = (state.xMax - state.xMin) * factor / 2;
    final yRange = (state.yMax - state.yMin) * factor / 2;
    state.setViewBounds(
      xMin: xCenter - xRange,
      xMax: xCenter + xRange,
      yMin: yCenter - yRange,
      yMax: yCenter + yRange,
    );
  }
}

class _FloatButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _FloatButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: GG.panelDivider),
            ),
            child: Icon(icon, color: GG.textPrimary, size: 20),
          ),
        ),
      ),
    );
  }
}
