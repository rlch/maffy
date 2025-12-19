import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expression_entry.dart';
import '../providers/graph_state.dart';
import 'expression_card.dart';

/// The sidebar containing all expression entries (like Desmos left panel)
class ExpressionSidebar extends StatelessWidget {
  const ExpressionSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(context),
          // Expression list
          Expanded(
            child: _buildExpressionList(context),
          ),
          // Footer with keyboard toggle
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          // Add button
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddMenu(context),
            tooltip: 'Add expression',
          ),
          const Spacer(),
          // Undo/redo buttons
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: null, // TODO: Implement undo
            tooltip: 'Undo',
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: null, // TODO: Implement redo
            tooltip: 'Redo',
          ),
          const Spacer(),
          // Settings
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context),
            tooltip: 'Settings',
          ),
          // Toggle sidebar collapse
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              // TODO: Implement sidebar collapse
            },
            tooltip: 'Collapse sidebar',
          ),
        ],
      ),
    );
  }

  Widget _buildExpressionList(BuildContext context) {
    // Use Selector to only rebuild when entries list reference changes
    // (not when individual entry values change)
    return Selector<GraphState, List<ExpressionEntry>>(
      selector: (_, state) => state.entries,
      shouldRebuild: (previous, next) {
        // Only rebuild if the list length or IDs changed
        if (previous.length != next.length) return true;
        for (int i = 0; i < previous.length; i++) {
          if (previous[i].id != next[i].id) return true;
          // Also rebuild if entry type changed (e.g., Empty -> Function)
          if (previous[i].runtimeType != next[i].runtimeType) return true;
        }
        return false;
      },
      builder: (context, entries, child) {
        return ListView.builder(
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

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          // Keyboard toggle
          IconButton(
            icon: const Icon(Icons.keyboard),
            onPressed: () {
              // Math keyboard is shown automatically when focusing MathField
            },
            tooltip: 'Show keyboard',
          ),
          const Spacer(),
          // Attribution
          Text(
            'powered by maffy',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.functions),
              title: const Text('Expression'),
              subtitle: const Text('y = f(x)'),
              onTap: () {
                Navigator.pop(context);
                // Focus will be on the empty expression at the bottom
              },
            ),
            ListTile(
              leading: const Icon(Icons.tune),
              title: const Text('Slider'),
              subtitle: const Text('Variable with adjustable value'),
              onTap: () {
                Navigator.pop(context);
                _showSliderDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.place),
              title: const Text('Point'),
              subtitle: const Text('(x, y) coordinate'),
              onTap: () {
                Navigator.pop(context);
                _showPointDialog(context);
              },
            ),
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
                hintText: 'e.g., a, b, L',
              ),
              maxLength: 1,
            ),
            TextField(
              controller: valueController,
              decoration: const InputDecoration(
                labelText: 'Initial value',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
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
    final xController = TextEditingController(text: '0');
    final yController = TextEditingController(text: '0');

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
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: yController,
                decoration: const InputDecoration(labelText: 'y'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final x = double.tryParse(xController.text) ?? 0;
              final y = double.tryParse(yController.text) ?? 0;
              context.read<GraphState>().addPoint(x, y);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Consumer<GraphState>(
          builder: (context, state, child) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text('Graph Mode'),
              ),
              ListTile(
                leading: Icon(
                  state.is3DMode ? Icons.radio_button_off : Icons.radio_button_checked,
                  color: state.is3DMode ? null : Theme.of(context).primaryColor,
                ),
                title: const Text('2D'),
                onTap: () => state.setMode(is3D: false),
              ),
              ListTile(
                leading: Icon(
                  state.is3DMode ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: state.is3DMode ? Theme.of(context).primaryColor : null,
                ),
                title: const Text('3D'),
                onTap: () => state.setMode(is3D: true),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.zoom_in),
                title: const Text('Zoom to fit'),
                onTap: () {
                  // TODO: Implement zoom to fit
                  Navigator.pop(context);
                },
              ),
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
