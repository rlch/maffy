import 'package:flutter/material.dart';

import '../theme/geogebra_theme.dart';
import '../widgets/geogebra_app_bar.dart';
import '../widgets/geometry/algebra_panel.dart';
import '../widgets/geometry/geometry_canvas.dart';
import '../widgets/geometry/geometry_toolbar.dart';

/// GeoGebra-style Geometry screen.
///
/// Top: branded app bar.  Below it, a horizontal tool ribbon with
/// grouped construction tools.  The rest of the screen is split into
/// a left algebra panel and the drawing canvas.
class GeometryScreen extends StatelessWidget {
  const GeometryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GG.appBg,
      body: SafeArea(
        child: Column(
          children: [
            GeoGebraAppBar(
              subtitle: 'Geometry',
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: GG.textPrimary),
                tooltip: 'Back',
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                GeoGebraHeaderAction(
                  icon: Icons.help_outline,
                  label: 'Help',
                  onPressed: () => _showHelp(context),
                ),
              ],
            ),
            const GeometryToolbar(),
            Expanded(
              child: Row(
                children: [
                  const AlgebraPanel(),
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: const GeometryCanvas(),
                    ),
                  ),
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
        title: const Text('Geometry'),
        content: const Text(
          'Pick a tool from the ribbon, then click on the canvas to '
          'build points, segments, lines, circles, or polygons. '
          'Switch to the Move tool to drag existing objects.',
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
