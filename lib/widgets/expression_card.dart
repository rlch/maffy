import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:math_keyboard/math_keyboard.dart';
import 'package:provider/provider.dart';

import '../models/expression_entry.dart';
import '../models/graph_colors.dart';
import '../providers/editing_state.dart';
import '../providers/graph_state.dart';

/// A card in the expression sidebar (like Desmos)
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

  @override
  void initState() {
    super.initState();
    _createController();
  }

  void _createController() {
    _controller = MathFieldEditingController();
    _initializeControllerValue();
  }

  void _initializeControllerValue() {
    final entry = widget.entry;
    if (entry is FunctionExpression && entry.latex.isNotEmpty) {
      try {
        _controller?.updateValue(TeXParser(entry.latex).parse());
      } catch (_) {
        // If parsing fails, leave empty
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return switch (widget.entry) {
      FunctionExpression entry => _buildFunctionCard(entry),
      SliderExpression entry => _buildSliderCard(entry),
      PointExpression entry => _buildPointCard(entry),
      EmptyExpression entry => _buildEmptyCard(entry),
    };
  }

  Widget _buildFunctionCard(FunctionExpression entry) {
    final graphState = context.read<GraphState>();
    final undefinedVars = graphState.getUndefinedVariables(entry.latex);

    return _CardContainer(
      index: widget.index,
      color: entry.color,
      isVisible: entry.isVisible,
      hasError: entry.error != null,
      onToggleVisibility: () {
        graphState.toggleVisibility(entry.id);
      },
      onDelete: () {
        graphState.removeExpression(entry.id);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _isEditing ? _buildMathField(entry) : _buildMathDisplay(entry),
          // Show undefined variables prompt
          if (undefinedVars.isNotEmpty && !_isEditing)
            _buildUndefinedVarsPrompt(undefinedVars),
        ],
      ),
    );
  }

  Widget _buildUndefinedVarsPrompt(Set<String> undefinedVars) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: undefinedVars.map((varName) {
          return ActionChip(
            avatar: const Icon(Icons.add, size: 16),
            label: Text('add slider for $varName'),
            labelStyle: const TextStyle(fontSize: 12),
            visualDensity: VisualDensity.compact,
            onPressed: () {
              context.read<GraphState>().addSlider(varName);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMathDisplay(FunctionExpression entry) {
    return GestureDetector(
      onTap: () => setState(() => _isEditing = true),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        alignment: Alignment.centerLeft,
        child: entry.latex.isEmpty
            ? Text(
                'Enter expression...',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontStyle: FontStyle.italic,
                ),
              )
            : Math.tex(
                entry.latex,
                textStyle: const TextStyle(fontSize: 18),
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
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          _commitEdit(entry.id);
          setState(() => _isEditing = false);
        }
      },
      child: MathField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        onChanged: (value) {
          // Update EditingState for live graph updates (doesn't rebuild sidebar)
          final tex = _controller?.currentEditingValue() ?? '';
          context.read<EditingState>().updateLiveValue(entry.id, tex);
        },
        onSubmitted: (value) {
          _commitEdit(entry.id);
          setState(() => _isEditing = false);
        },
      ),
    );
  }

  Widget _buildSliderCard(SliderExpression entry) {
    return _CardContainer(
      index: widget.index,
      isVisible: entry.isVisible,
      onToggleVisibility: () {
        context.read<GraphState>().toggleVisibility(entry.id);
      },
      onDelete: () {
        context.read<GraphState>().removeExpression(entry.id);
      },
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Variable name and value
            Row(
              children: [
                // Play/pause button
                IconButton(
                  icon: Icon(
                    entry.isAnimating ? Icons.pause : Icons.play_arrow,
                    size: 20,
                  ),
                  onPressed: () {
                    context.read<GraphState>().toggleSliderAnimation(entry.id);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                const SizedBox(width: 4),
                // Variable display
                Math.tex(
                  '${entry.name} = ${entry.value.toStringAsFixed(1)}',
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Slider
            Row(
              children: [
                Text(
                  entry.min.toInt().toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: entry.value,
                    min: entry.min,
                    max: entry.max,
                    onChanged: (value) {
                      context.read<GraphState>().updateSliderValue(entry.id, value);
                    },
                  ),
                ),
                Text(
                  entry.max.toInt().toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
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
      onToggleVisibility: () {
        context.read<GraphState>().toggleVisibility(entry.id);
      },
      onDelete: () {
        context.read<GraphState>().removeExpression(entry.id);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Math.tex(
          entry.latex,
          textStyle: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildEmptyCard(EmptyExpression entry) {
    return _CardContainer(
      index: widget.index,
      child: Focus(
        onFocusChange: (hasFocus) {
          if (!hasFocus) {
            _commitEdit(entry.id);
          }
        },
        child: MathField(
          controller: _controller,
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            hintText: 'Enter expression...',
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontStyle: FontStyle.italic,
            ),
          ),
          onChanged: (value) {
            // Update EditingState for live graph updates (doesn't rebuild sidebar)
            final tex = _controller?.currentEditingValue() ?? '';
            if (tex.isNotEmpty) {
              context.read<EditingState>().updateLiveValue(entry.id, tex);
            }
          },
          onSubmitted: (value) {
            _commitEdit(entry.id);
          },
        ),
      ),
    );
  }

  /// Commit the current edit to GraphState
  void _commitEdit(String id) {
    final tex = _controller?.currentEditingValue() ?? '';
    final graphState = context.read<GraphState>();
    final editingState = context.read<EditingState>();

    // Clear live editing value
    editingState.clearLiveValue(id);

    // Commit to graph state if there's content
    if (tex.isNotEmpty) {
      graphState.updateExpression(id, tex);
    }

    // Ensure there's an empty slot for next expression
    graphState.ensureEmptySlot();
  }
}

/// Container widget for expression cards
class _CardContainer extends StatelessWidget {
  final int index;
  final Color? color;
  final bool isVisible;
  final bool hasError;
  final VoidCallback? onToggleVisibility;
  final VoidCallback? onDelete;
  final Widget child;

  const _CardContainer({
    required this.index,
    this.color,
    this.isVisible = true,
    this.hasError = false,
    this.onToggleVisibility,
    this.onDelete,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          // Color indicator / line number
          GestureDetector(
            onTap: onToggleVisibility,
            child: Container(
              width: 32,
              alignment: Alignment.center,
              child: color != null
                  ? Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isVisible ? color : Colors.transparent,
                        border: Border.all(
                          color: color!,
                          width: 2,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: hasError
                          ? const Icon(
                              Icons.error_outline,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    )
                  : Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                    ),
            ),
          ),
          // Content
          Expanded(child: child),
          // Delete button
          if (onDelete != null)
            IconButton(
              icon: Icon(
                Icons.close,
                size: 18,
                color: Colors.grey.shade400,
              ),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}

/// Color picker for expressions
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
        decoration: BoxDecoration(
          color: currentColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
