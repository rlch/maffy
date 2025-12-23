import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/geometry_tools.dart';
import '../../providers/geometry_provider.dart';

class GeometryToolbar extends StatelessWidget {
  const GeometryToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Undo/Redo Group
            Consumer<GeometryProvider>(
              builder: (context, provider, _) => Row(
                children: [
                  IconButton(
                    icon: const Icon(CupertinoIcons.arrow_turn_up_left, size: 20),
                    onPressed: provider.canUndo ? provider.undo : null,
                    tooltip: 'Undo',
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.arrow_turn_up_right, size: 20),
                    onPressed: provider.canRedo ? provider.redo : null,
                    tooltip: 'Redo',
                  ),
                  Container(
                    height: 24,
                    width: 1,
                    color: Colors.grey.shade300,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ],
              ),
            ),
            // Tools
            ...GeometryTool.allTools.map((tool) {
              return _ToolButton(tool: tool);
            }),
          ],
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final GeometryTool tool;

  const _ToolButton({required this.tool});

  @override
  Widget build(BuildContext context) {
    final activeTool = context.select<GeometryProvider, GeometryToolType>(
      (p) => p.activeTool,
    );
    final isSelected = activeTool == tool.type;

    return Tooltip(
      message: tool.name,
      child: GestureDetector(
        onTap: () {
          context.read<GeometryProvider>().setTool(tool.type);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.transparent,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getIcon(tool.iconName),
                color: isSelected ? Colors.blue : Colors.black87,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                tool.name,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? Colors.blue : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'move':
        return CupertinoIcons.move;
      case 'point':
        return CupertinoIcons.circle_filled; // or dot_square
      case 'line':
        return CupertinoIcons.minus; // approximation
      case 'segment':
        return CupertinoIcons.minus_square;
      case 'ray':
        return CupertinoIcons.arrow_up_right;
      case 'vector':
        return CupertinoIcons.arrow_right;
      case 'circle':
        return CupertinoIcons.circle;
      case 'polygon':
        return CupertinoIcons.hexagon;
      case 'angle':
        return CupertinoIcons.compass; // Placeholder
      case 'ruler':
        return CupertinoIcons.slider_horizontal_3; // Placeholder
      default:
        return CupertinoIcons.question;
    }
  }
}
