import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/graph_state.dart';
import '../screens/scientific_calculator_screen.dart';

/// Navigation drawer for switching between calculator modes
class NavigationDrawerWidget extends StatelessWidget {
  const NavigationDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final graphState = context.watch<GraphState>();
    
    return Drawer(
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.calculate,
                    size: 48,
                    color: Colors.blue.shade300,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Maffy',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Graphing Calculator',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            // Mode section header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'CALCULATOR MODE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            
            // 2D Graph option
            ListTile(
              leading: const Icon(Icons.show_chart),
              title: const Text('2D Graph'),
              selected: !graphState.is3DMode,
              selectedTileColor: Colors.blue.withValues(alpha: 0.1),
              selectedColor: Colors.blue,
              onTap: () {
                graphState.setMode(is3D: false);
                Navigator.pop(context);
              },
              trailing: !graphState.is3DMode 
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
            ),
            
            // 3D Graph option
            ListTile(
              leading: const Icon(Icons.scatter_plot),
              title: const Text('3D Graph'),
              selected: graphState.is3DMode,
              selectedTileColor: Colors.blue.withValues(alpha: 0.1),
              selectedColor: Colors.blue,
              onTap: () {
                graphState.setMode(is3D: true);
                Navigator.pop(context);
              },
              trailing: graphState.is3DMode 
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
            ),
            
            // Scientific Calculator option
            ListTile(
              leading: const Icon(Icons.calculate_outlined),
              title: const Text('Scientific Calculator'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScientificCalculatorScreen(),
                  ),
                );
              },
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
            
            const Divider(height: 32),
            
            // Additional options
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'SETTINGS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help'),
              onTap: () {
                Navigator.pop(context);
                _showHelp(context);
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                _showAbout(context);
              },
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

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Maffy',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.calculate,
        size: 48,
        color: Colors.blue.shade300,
      ),
      children: [
        const Text('A powerful graphing calculator with 2D, 3D, and scientific modes.'),
        const SizedBox(height: 8),
        const Text('Built with Flutter'),
      ],
    );
  }
}
