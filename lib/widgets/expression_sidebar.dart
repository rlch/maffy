import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expression_entry.dart';
import '../providers/graph_state.dart';
import '../theme/geogebra_theme.dart';
import 'expression_card.dart';

/// The "Algebra" sidebar on the left of the graphing calculator, styled
/// after the panel in GeoGebra's web app.
///
/// Top section: tools (undo/redo, settings). Middle: list of expressions
/// rendered as [ExpressionCard]s. Bottom: the floating rounded "+" button
/// in primary blue plus a small keyboard toggle — matching the FAB that
/// GeoGebra places at the bottom of its algebra view.
class ExpressionSidebar extends StatelessWidget {
  const ExpressionSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      decoration: const BoxDecoration(
        color: GG.sidebarBg,
        border: Border(right: BorderSide(color: GG.panelDivider)),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              _Header(),
              const Divider(height: 1),
              Expanded(child: _ExpressionList()),
            ],
          ),
          // Floating "+" FAB pinned to the bottom-center, GeoGebra-style.
          Positioned(
            right: 16,
            bottom: 16,
            child: _AddFab(onPressed: () => _showAddMenu(context)),
          ),
        ],
      ),
    );
  }

  void _showAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: GG.panelDivider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.functions, color: GG.primary),
              title: const Text('Expression'),
              subtitle: const Text('y = f(x)'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.tune, color: GG.primary),
              title: const Text('Slider'),
              subtitle: const Text('Variable with adjustable value'),
              onTap: () {
                Navigator.pop(context);
                _showSliderDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.place, color: GG.primary),
              title: const Text('Point'),
              subtitle: Text(context.read<GraphState>().is3DMode
                  ? '(x, y, z) coordinate'
                  : '(x, y) coordinate'),
              onTap: () {
                Navigator.pop(context);
                _showPointDialog(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showSliderDialog(BuildContext context) {
    final nameController = TextEditingController(text: 'a');
    final valueController = TextEditingController(text: '0');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Slider'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Variable name',
                hintText: 'a, b, L',
              ),
              maxLength: 1,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: valueController,
              decoration: const InputDecoration(labelText: 'Initial value'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              final value = double.tryParse(valueController.text) ?? 0;
              if (name.isNotEmpty) {
                context.read<GraphState>().addSlider(name, value: value);
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showPointDialog(BuildContext context) {
    final graphState = context.read<GraphState>();
    final is3D = graphState.is3DMode;
    final xController = TextEditingController(text: '0');
    final yController = TextEditingController(text: '0');
    final zController = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Point'),
        content: Row(
          children: [
            Expanded(
              child: TextField(
                controller: xController,
                decoration: const InputDecoration(labelText: 'x'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: yController,
                decoration: const InputDecoration(labelText: 'y'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
              ),
            ),
            if (is3D) ...[
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: zController,
                  decoration: const InputDecoration(labelText: 'z'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final x = double.tryParse(xController.text) ?? 0;
              final y = double.tryParse(yController.text) ?? 0;
              if (is3D) {
                final z = double.tryParse(zController.text) ?? 0;
                graphState.addPoint(x, y, z: z);
              } else {
                graphState.addPoint(x, y);
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      color: Colors.white,
      child: Row(
        children: [
          const SizedBox(width: 6),
          const Text(
            'Algebra',
            style: TextStyle(
              color: GG.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const Spacer(),
          _IconBtn(
            icon: Icons.undo,
            tooltip: 'Undo',
            onTap: null,
          ),
          _IconBtn(
            icon: Icons.redo,
            tooltip: 'Redo',
            onTap: null,
          ),
          _IconBtn(
            icon: Icons.more_vert,
            tooltip: 'Settings',
            onTap: () => _showSettings(context),
          ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) => SafeArea(
        child: Consumer<GraphState>(
          builder: (context, state, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text(
                  'Graph Mode',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                dense: true,
              ),
              RadioListTile<bool>(
                value: false,
                groupValue: state.is3DMode,
                onChanged: (_) => state.setMode(is3D: false),
                title: const Text('2D Graphing'),
              ),
              RadioListTile<bool>(
                value: true,
                groupValue: state.is3DMode,
                onChanged: (_) => state.setMode(is3D: true),
                title: const Text('3D Graphing'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Reset view'),
                onTap: () {
                  state.setViewBounds(
                    xMin: -10,
                    xMax: 10,
                    yMin: -10,
                    yMax: 10,
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpressionList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<GraphState, List<ExpressionEntry>>(
      selector: (_, state) => state.entries,
      shouldRebuild: (previous, next) {
        if (previous.length != next.length) return true;
        for (int i = 0; i < previous.length; i++) {
          if (previous[i].id != next[i].id) return true;
          if (previous[i].runtimeType != next[i].runtimeType) return true;
        }
        return false;
      },
      builder: (context, entries, _) {
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80, top: 4),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return ExpressionCard(
              key: ValueKey(entry.id),
              entry: entry,
              index: index,
            );
          },
        );
      },
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _IconBtn({required this.icon, required this.tooltip, this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      splashRadius: 20,
      visualDensity: VisualDensity.compact,
      icon: Icon(icon,
          size: 20, color: onTap == null ? GG.textHint : GG.textSecondary),
      tooltip: tooltip,
      onPressed: onTap,
    );
  }
}

class _AddFab extends StatelessWidget {
  final VoidCallback onPressed;
  const _AddFab({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: GG.primary,
      elevation: 4,
      shadowColor: GG.primary.withValues(alpha: 0.4),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const SizedBox(
          width: 52,
          height: 52,
          child: Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
