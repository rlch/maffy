import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/graph_state.dart';
import '../screens/geometry_screen.dart';
import '../screens/scientific_calculator_screen.dart';
import '../theme/geogebra_theme.dart';

/// App-switcher drawer, mirroring the "GeoGebra Calculator Suite"
/// chooser that the web app exposes from its hamburger menu.
class NavigationDrawerWidget extends StatelessWidget {
  const NavigationDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final graphState = context.watch<GraphState>();
    return Drawer(
      backgroundColor: Colors.white,
      elevation: 4,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(4)),
      ),
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const _DrawerHeader(),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 16, 8),
              child: Text(
                'Calculator Suite',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: GG.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            _AppTile(
              icon: Icons.show_chart,
              color: GG.primary,
              label: 'Graphing Calculator',
              subtitle: 'Plot functions, add sliders',
              selected: !graphState.is3DMode,
              onTap: () {
                graphState.setMode(is3D: false);
                Navigator.pop(context);
              },
            ),
            _AppTile(
              icon: Icons.view_in_ar,
              color: GG.purple,
              label: '3D Calculator',
              subtitle: 'Plot surfaces in 3D',
              selected: graphState.is3DMode,
              onTap: () {
                graphState.setMode(is3D: true);
                Navigator.pop(context);
              },
            ),
            _AppTile(
              icon: Icons.calculate_outlined,
              color: GG.teal,
              label: 'Scientific Calculator',
              subtitle: 'Fractions, trig, memory',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ScientificCalculatorScreen(),
                  ),
                );
              },
            ),
            _AppTile(
              icon: Icons.architecture,
              color: GG.orange,
              label: 'Geometry',
              subtitle: 'Construct points, lines, circles',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GeometryScreen(),
                  ),
                );
              },
            ),
            const Divider(height: 32),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 16, 8),
              child: Text(
                'About',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: GG.textSecondary,
                  letterSpacing: 1.2,
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
              title: const Text('About Maffy'),
              onTap: () {
                Navigator.pop(context);
                _showAbout(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Maffy Help'),
        content: const Text(
          'Use the left sidebar to enter expressions, sliders, or points. '
          'Drag to pan, scroll to zoom. Switch apps from the menu.',
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
      applicationIcon: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: GG.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: const Text(
          'M',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
      ),
      children: const [
        Text('A GeoGebra-style math suite built with Flutter.'),
      ],
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [GG.primary, GG.primaryDark],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Text(
              'M',
              style: TextStyle(
                color: GG.primary,
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Maffy',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Text(
            'Math made beautiful',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _AppTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.subtitle,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? GG.primaryTint : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: selected ? GG.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: selected ? GG.primary : GG.textPrimary,
                      fontSize: 14,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: GG.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check, color: GG.primary, size: 18),
          ],
        ),
      ),
    );
  }
}
