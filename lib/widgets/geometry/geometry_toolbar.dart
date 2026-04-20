import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/geometry_tools.dart';
import '../../providers/geometry_provider.dart';
import '../../theme/geogebra_theme.dart';

/// Tool ribbon above the geometry canvas.
///
/// Mirrors the top bar in the GeoGebra Geometry web app: undo / redo
/// on the left, then a group of tool buttons with an icon and a
/// selected-state blue tint, then overflow actions on the right.
class GeometryToolbar extends StatelessWidget {
  const GeometryToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: GG.panelDivider)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Consumer<GeometryProvider>(
              builder: (context, provider, _) => Row(
                children: [
                  _HeaderIcon(
                    icon: CupertinoIcons.arrow_turn_up_left,
                    tooltip: 'Undo',
                    onTap: provider.canUndo ? provider.undo : null,
                  ),
                  _HeaderIcon(
                    icon: CupertinoIcons.arrow_turn_up_right,
                    tooltip: 'Redo',
                    onTap: provider.canRedo ? provider.redo : null,
                  ),
                  const _Separator(),
                ],
              ),
            ),
            ...GeometryTool.allTools.map((t) => _ToolButton(tool: t)),
          ],
        ),
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      width: 1,
      color: GG.panelDivider,
      margin: const EdgeInsets.symmetric(horizontal: 10),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _HeaderIcon({
    required this.icon,
    required this.tooltip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        visualDensity: VisualDensity.compact,
        splashRadius: 22,
        icon: Icon(
          icon,
          size: 20,
          color: onTap == null ? GG.textHint : GG.textSecondary,
        ),
        onPressed: onTap,
      ),
    );
  }
}

class _ToolButton extends StatefulWidget {
  final GeometryTool tool;
  const _ToolButton({required this.tool});

  @override
  State<_ToolButton> createState() => _ToolButtonState();
}

class _ToolButtonState extends State<_ToolButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = context.select<GeometryProvider, GeometryToolType>(
      (p) => p.activeTool,
    );
    final isSelected = active == widget.tool.type;
    final bg = isSelected
        ? GG.primaryTint
        : (_hover ? GG.subtle : Colors.transparent);
    final fg = isSelected ? GG.primary : GG.textPrimary;

    return Tooltip(
      message: widget.tool.name,
      waitDuration: const Duration(milliseconds: 300),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: () =>
              context.read<GeometryProvider>().setTool(widget.tool.type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 64,
            margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? GG.primary : Colors.transparent,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _iconFor(widget.tool.iconName),
                  color: fg,
                  size: 22,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.tool.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: fg,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconFor(String name) {
    switch (name) {
      case 'move':
        return CupertinoIcons.hand_draw;
      case 'point':
        return CupertinoIcons.circle_filled;
      case 'line':
        return CupertinoIcons.minus;
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
        return CupertinoIcons.compass;
      case 'ruler':
        return CupertinoIcons.slider_horizontal_3;
      default:
        return CupertinoIcons.question;
    }
  }
}
