import 'package:flutter/material.dart';

/// Button type for styling
enum CalculatorButtonType {
  number,
  operator,
  function,
  special,
  equals,
}

/// Calculator button widget with press animation
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
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  Color _getBackgroundColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (widget.type) {
      case CalculatorButtonType.number:
        return colorScheme.surface;
      case CalculatorButtonType.operator:
        return colorScheme.surfaceContainerHigh;
      case CalculatorButtonType.function:
        return colorScheme.surfaceContainerHighest;
      case CalculatorButtonType.special:
        return colorScheme.surfaceContainer;
      case CalculatorButtonType.equals:
        return colorScheme.primary;
    }
  }

  Color _getTextColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (widget.type) {
      case CalculatorButtonType.equals:
        return colorScheme.onPrimary;
      case CalculatorButtonType.operator:
      case CalculatorButtonType.function:
        return colorScheme.primary;
      default:
        return colorScheme.onSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width,
          height: widget.height ?? 60,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _getBackgroundColor(context),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: widget.text.length > 4 ? 14 : 20,
                      fontWeight: FontWeight.w500,
                      color: _getTextColor(context),
                    ),
                  ),
                ),
              ),
              if (widget.isMemoryActive && widget.text.startsWith('M'))
                Positioned(
                  top: 4,
                  right: 8,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
