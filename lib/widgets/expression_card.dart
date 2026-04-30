import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:math_keyboard/math_keyboard.dart';
import 'package:provider/provider.dart';

import '../models/expression_entry.dart';
import '../models/graph_colors.dart';
import '../providers/editing_state.dart';
import '../providers/graph_state.dart';
import '../theme/geogebra_theme.dart';

/// Single row in the algebra sidebar, rendered GeoGebra-style:
/// a left color dot (click to toggle visibility), then the math
/// expression or slider / point controls, and a trailing delete
/// button that only appears on hover or when a valid entry exists.
class ExpressionCard extends StatefulWidget {
  final ExpressionEntry entry;
  final int index;

  const ExpressionCard({
    super.key,
    required this.entry,
    required this.index,
  });

  @override
  State<ExpressionCard> createState() => _ExpressionCardState();
}

class _ExpressionCardState extends State<ExpressionCard> {
  MathFieldEditingController? _controller;
  bool _isEditing = false;
  bool _hover = false;

  @override
  void initState() {
    super.initState();
    _controller = MathFieldEditingController();
    final entry = widget.entry;
    if (entry is FunctionExpression && entry.latex.isNotEmpty) {
      try {
        _controller?.updateValue(TeXParser(entry.latex).parse());
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: switch (widget.entry) {
        FunctionExpression e => _buildFunctionCard(e),
        SliderExpression e => _buildSliderCard(e),
        PointExpression e => _buildPointCard(e),
        EmptyExpression e => _buildEmptyCard(e),
      },
    );
  }

  Widget _buildFunctionCard(FunctionExpression entry) {
    final graphState = context.read<GraphState>();
    final undefinedVars = graphState.getUndefinedVariables(entry.latex);
    return _CardContainer(
      index: widget.index,
      color: entry.color,
      isVisible: entry.isVisible,
      hasError: entry.error != null,
      showDelete: _hover || !_isEditing,
      onToggleVisibility: () => graphState.toggleVisibility(entry.id),
      onDelete: () => graphState.removeExpression(entry.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _isEditing ? _buildMathField(entry) : _buildMathDisplay(entry),
          if (undefinedVars.isNotEmpty && !_isEditing)
            _buildUndefinedVarsPrompt(undefinedVars),
        ],
      ),
    );
  }

  Widget _buildUndefinedVarsPrompt(Set<String> undefinedVars) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: undefinedVars.map((varName) {
          return ActionChip(
            avatar: const Icon(Icons.add, size: 14, color: GG.primary),
            label: Text('slider $varName'),
            labelStyle: const TextStyle(fontSize: 12, color: GG.primary),
            backgroundColor: GG.primaryTint,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: GG.primary.withValues(alpha: 0.4)),
            ),
            visualDensity: VisualDensity.compact,
            onPressed: () =>
                context.read<GraphState>().addSlider(varName),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMathDisplay(FunctionExpression entry) {
    return GestureDetector(
      onTap: () => setState(() => _isEditing = true),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        alignment: Alignment.centerLeft,
        child: entry.latex.isEmpty
            ? const Text(
                'Input…',
                style: TextStyle(
                  color: GG.textHint,
                  fontSize: 15,
                ),
              )
            : Math.tex(
                entry.latex,
                textStyle: const TextStyle(fontSize: 18, color: GG.textPrimary),
                onErrorFallback: (err) => Text(
                  entry.latex,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.red,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildMathField(FunctionExpression entry) {
    final is3D = context.read<GraphState>().is3DMode;
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          _commitEdit(entry.id);
          setState(() => _isEditing = false);
        }
      },
      onKeyEvent: _handleEqualsKey,
      child: MathField(
        controller: _controller,
        autofocus: true,
        variables: _allowedVariables(is3D: is3D),
        decoration: const InputDecoration(
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        onChanged: (_) {
          final tex = _controller?.currentEditingValue() ?? '';
          context.read<EditingState>().updateLiveValue(entry.id, tex);
        },
        onSubmitted: (_) {
          _commitEdit(entry.id);
          setState(() => _isEditing = false);
        },
      ),
    );
  }

  /// MathField's built-in keyboard has no `=` button; it returns
  /// `ignored` for unmapped characters, so `=` bubbles up to this parent
  /// Focus. Insert it as a TeX leaf so equations like `x^2+y^2=9` and
  /// `y=sin(x)` can be typed.
  /// Letters the user can type in the MathField. Expanded beyond `x/y/z`
  /// so shorthand slider assignments (`a=5`, `k=2`, `m=-3`) work and so
  /// multi-letter expressions (`ax+b`) can be composed. `e` and `p` are
  /// intentionally excluded because the math keyboard reserves them for
  /// `e` and `\pi`.
  List<String> _allowedVariables({required bool is3D}) {
    const blocked = {'e', 'p'};
    final letters = <String>[];
    for (var c = 'a'.codeUnitAt(0); c <= 'z'.codeUnitAt(0); c++) {
      final ch = String.fromCharCode(c);
      if (blocked.contains(ch)) continue;
      letters.add(ch);
    }
    if (!is3D) letters.remove('z');
    return letters;
  }

  KeyEventResult _handleEqualsKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.character == '=') {
      _controller?.addLeaf('=');
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Widget _buildSliderCard(SliderExpression entry) {
    return _CardContainer(
      index: widget.index,
      isVisible: entry.isVisible,
      showDelete: _hover,
      onToggleVisibility: () =>
          context.read<GraphState>().toggleVisibility(entry.id),
      onDelete: () =>
          context.read<GraphState>().removeExpression(entry.id),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 8, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  splashRadius: 18,
                  iconSize: 20,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    entry.isAnimating
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                    color: GG.primary,
                  ),
                  onPressed: () => context
                      .read<GraphState>()
                      .toggleSliderAnimation(entry.id),
                ),
                const SizedBox(width: 2),
                Math.tex(
                  '${entry.name} = ${entry.value.toStringAsFixed(1)}',
                  textStyle: const TextStyle(
                    fontSize: 16,
                    color: GG.textPrimary,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                children: [
                  Text(
                    entry.min.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 11,
                      color: GG.textSecondary,
                    ),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 7,
                        ),
                      ),
                      child: Slider(
                        value: entry.value,
                        min: entry.min,
                        max: entry.max,
                        onChanged: (v) => context
                            .read<GraphState>()
                            .updateSliderValue(entry.id, v),
                      ),
                    ),
                  ),
                  Text(
                    entry.max.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 11,
                      color: GG.textSecondary,
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

  Widget _buildPointCard(PointExpression entry) {
    return _CardContainer(
      index: widget.index,
      color: entry.color,
      isVisible: entry.isVisible,
      hasError: entry.error != null,
      showDelete: _hover,
      onToggleVisibility: () =>
          context.read<GraphState>().toggleVisibility(entry.id),
      onDelete: () =>
          context.read<GraphState>().removeExpression(entry.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Math.tex(
          entry.latex,
          textStyle: const TextStyle(fontSize: 18, color: GG.textPrimary),
        ),
      ),
    );
  }

  Widget _buildEmptyCard(EmptyExpression entry) {
    final is3D = context.read<GraphState>().is3DMode;
    return _CardContainer(
      index: widget.index,
      showDelete: false,
      child: Focus(
        onFocusChange: (hasFocus) {
          if (!hasFocus) _commitEdit(entry.id);
        },
        onKeyEvent: _handleEqualsKey,
        child: MathField(
          controller: _controller,
          variables: _allowedVariables(is3D: is3D),
          decoration: const InputDecoration(
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            hintText: 'Input…',
            hintStyle: TextStyle(color: GG.textHint, fontSize: 15),
          ),
          onChanged: (_) {
            final tex = _controller?.currentEditingValue() ?? '';
            if (tex.isNotEmpty) {
              context.read<EditingState>().updateLiveValue(entry.id, tex);
            }
          },
          onSubmitted: (_) => _commitEdit(entry.id),
        ),
      ),
    );
  }

  void _commitEdit(String id) {
    final tex = _controller?.currentEditingValue() ?? '';
    final graphState = context.read<GraphState>();
    final editingState = context.read<EditingState>();
    editingState.clearLiveValue(id);
    if (tex.isNotEmpty) {
      graphState.updateExpression(id, tex);
    }
    graphState.ensureEmptySlot();
  }
}

class _CardContainer extends StatelessWidget {
  final int index;
  final Color? color;
  final bool isVisible;
  final bool hasError;
  final bool showDelete;
  final VoidCallback? onToggleVisibility;
  final VoidCallback? onDelete;
  final Widget child;

  const _CardContainer({
    required this.index,
    this.color,
    this.isVisible = true,
    this.hasError = false,
    this.showDelete = true,
    this.onToggleVisibility,
    this.onDelete,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: GG.panelDivider)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 40,
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(top: 16),
              child: GestureDetector(
                onTap: onToggleVisibility,
                child: color != null
                    ? _ColorDot(
                        color: color!,
                        visible: isVisible,
                        error: hasError,
                      )
                    : Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: GG.textHint,
                          fontSize: 12,
                        ),
                      ),
              ),
            ),
            Expanded(child: child),
            SizedBox(
              width: 36,
              child: (onDelete != null && showDelete)
                  ? IconButton(
                      splashRadius: 16,
                      iconSize: 18,
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.close, color: GG.textHint),
                      onPressed: onDelete,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final bool visible;
  final bool error;
  const _ColorDot({
    required this.color,
    required this.visible,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: visible ? color : Colors.transparent,
        border: Border.all(color: color, width: 2),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: error
          ? const Icon(Icons.error_outline, size: 12, color: Colors.white)
          : null,
    );
  }
}

/// Popup for choosing a graph color. Kept for compatibility with existing
/// callers; visually updated for the GeoGebra theme.
class ColorPickerPopup extends StatelessWidget {
  final Color currentColor;
  final ValueChanged<Color> onColorSelected;

  const ColorPickerPopup({
    super.key,
    required this.currentColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Color>(
      initialValue: currentColor,
      onSelected: onColorSelected,
      itemBuilder: (context) => GraphColors.palette
          .map(
            (color) => PopupMenuItem(
              value: color,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: color == currentColor
                      ? Border.all(color: Colors.black, width: 2)
                      : null,
                ),
              ),
            ),
          )
          .toList(),
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(color: currentColor, shape: BoxShape.circle),
      ),
    );
  }
}
