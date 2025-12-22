import 'package:flutter/material.dart';
import 'package:math_keyboard/math_keyboard.dart';
import 'package:provider/provider.dart';

import '../providers/graph_state.dart';
import '../widgets/expression_sidebar.dart';
import '../widgets/graph_view_2d.dart';
import '../widgets/graph_view_3d.dart';
import '../widgets/navigation_drawer.dart';

/// The main home screen with sidebar and graph view
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return MathKeyboardViewInsets(
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: _buildAppBar(context),
        drawer: const NavigationDrawerWidget(),
        body: SafeArea(
          child: Row(
            children: [
              // Expression sidebar
              const ExpressionSidebar(),
              // Graph view
              Expanded(
                child: _buildGraphView(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.grey.shade800,
      title: Row(
        children: [
          // Graph title
          const Text(
            'Untitled Graph',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          // Save button
          TextButton(
            onPressed: () {
              // TODO: Implement save
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      centerTitle: false,
      actions: [
        // Help button
        IconButton(
          icon: const Icon(Icons.help_outline, color: Colors.white),
          onPressed: () => _showHelp(context),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildGraphView(BuildContext context) {
    return Consumer<GraphState>(
      builder: (context, state, child) {
        return Stack(
          children: [
            // Graph
            state.is3DMode ? const GraphView3D() : const GraphView2D(),
            // Graph controls overlay
            Positioned(
              right: 16,
              top: 16,
              child: _buildGraphControls(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGraphControls(BuildContext context) {
    return Column(
      children: [
        // Zoom controls
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
              ),
            ],
          ),
          child: Column(
            children: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  final state = context.read<GraphState>();
                  final factor = 0.8;
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
                },
                tooltip: 'Zoom in',
              ),
              const Divider(height: 1),
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  final state = context.read<GraphState>();
                  final factor = 1.25;
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
                },
                tooltip: 'Zoom out',
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Home button
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              context.read<GraphState>().setViewBounds(
                    xMin: -10,
                    xMax: 10,
                    yMin: -10,
                    yMax: 10,
                  );
            },
            tooltip: 'Reset view',
          ),
        ),
      ],
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Maffy - Graphing Calculator'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How to use:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Type expressions like x^2 or sin(x)'),
              Text('• Use the + button to add sliders or points'),
              Text('• Click the colored circle to toggle visibility'),
              Text('• Drag on the graph to pan'),
              Text('• Scroll or pinch to zoom'),
              Text('• Toggle between 2D and 3D modes'),
              SizedBox(height: 16),
              Text(
                'Supported functions:',
                style: TextStyle(fontWeight: FontWeight.bold),
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
