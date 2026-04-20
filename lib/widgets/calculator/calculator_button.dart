import 'package:flutter/material.dart';

import '../../theme/geogebra_theme.dart';

/// Visual category for a [CalculatorButton].
enum CalculatorButtonType {
  number,
  operator,
  function,
  special,
  equals,
}

/// A GeoGebra-style calculator key.
///
/// Keys are flat, lightly-rounded rectangles with a 1 dp hairline
/// border; they invert to primary blue on tap / hover and animate a
/// tiny scale down when pressed. Colors depend on the [type]: numbers
/// are near-white, operators are faint grey-blue, functions are tinted
/// primary blue, and the equals key is solid primary.
class CalculatorButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final CalculatorButtonType type;
  final double? width;
  final double? height;
  final bool isMemoryActive;

  const CalculatorButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = CalculatorButtonType.number,
    this.width,
    this.height,
    this.isMemoryActive = false,
  });

  @override
  State<CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<CalculatorButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    duration: const Duration(milliseconds: 110),
    vsync: this,
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: 0.96,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  bool _hover = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  ({Color bg, Color fg, Color border}) _palette() {
    switch (widget.type) {
      case CalculatorButtonType.equals:
        return (bg: GG.primary, fg: Colors.white, border: GG.primary);
      case CalculatorButtonType.function:
        return (bg: GG.keyFunction, fg: GG.primary, border: GG.panelDivider);
      case CalculatorButtonType.operator:
        return (
          bg: GG.keyOperator,
          fg: GG.textPrimary,
          border: GG.panelDivider,
        );
      case CalculatorButtonType.special:
        return (
          bg: GG.keySpecial,
          fg: GG.textSecondary,
          border: GG.panelDivider,
        );
      case CalculatorButtonType.number:
        return (bg: GG.keyNumber, fg: GG.textPrimary, border: GG.panelDivider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _palette();
    final hoverBg = widget.type == CalculatorButtonType.equals
        ? GG.primaryDark
        : GG.primaryTint;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onPressed();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: ScaleTransition(
          scale: _scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: widget.width,
            height: widget.height ?? 58,
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _hover ? hoverBg : p.bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: p.border),
              boxShadow: widget.type == CalculatorButtonType.equals
                  ? [
                      BoxShadow(
                        color: GG.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      widget.text,
                      style: TextStyle(
                        fontSize: widget.text.length > 4 ? 13 : 19,
                        fontWeight: widget.type == CalculatorButtonType.equals
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: p.fg,
                      ),
                    ),
                  ),
                ),
                if (widget.isMemoryActive && widget.text.startsWith('M'))
                  Positioned(
                    top: 5,
                    right: 6,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: GG.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
