import 'package:flutter/material.dart';
import 'calculator_button.dart';

/// Calculator keyboard layout
class CalculatorKeyboard extends StatelessWidget {
  final Function(String) onInput;
  final bool isMemoryActive;
  final bool showScientific;

  const CalculatorKeyboard({
    super.key,
    required this.onInput,
    this.isMemoryActive = false,
    this.showScientific = true,
  });

  @override
  Widget build(BuildContext context) {
    if (showScientific) {
      return _buildScientificKeyboard(context);
    } else {
      return _buildBasicKeyboard(context);
    }
  }

  Widget _buildScientificKeyboard(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate button size based on available space
        final width = constraints.maxWidth;
        final buttonWidth = (width - 48) / 5; // 5 columns with margins

        return Column(
          children: [
            // Row 1: Scientific functions
            _buildRow([
              _ButtonConfig('DEG/RAD', CalculatorButtonType.special),
              _ButtonConfig('(', CalculatorButtonType.operator),
              _ButtonConfig(')', CalculatorButtonType.operator),
              _ButtonConfig('MC', CalculatorButtonType.special),
              _ButtonConfig('AC', CalculatorButtonType.special),
            ], buttonWidth),

            // Row 2: Trigonometric functions
            _buildRow([
              _ButtonConfig('sin', CalculatorButtonType.function),
              _ButtonConfig('cos', CalculatorButtonType.function),
              _ButtonConfig('tan', CalculatorButtonType.function),
              _ButtonConfig('MR', CalculatorButtonType.special),
              _ButtonConfig('DEL', CalculatorButtonType.special),
            ], buttonWidth),

            // Row 3: Inverse trig functions
            _buildRow([
              _ButtonConfig('asin', CalculatorButtonType.function),
              _ButtonConfig('acos', CalculatorButtonType.function),
              _ButtonConfig('atan', CalculatorButtonType.function),
              _ButtonConfig('M+', CalculatorButtonType.special),
              _ButtonConfig('÷', CalculatorButtonType.operator),
            ], buttonWidth),

            // Row 4: Log, exp, power
            _buildRow([
              _ButtonConfig('ln', CalculatorButtonType.function),
              _ButtonConfig('log10', CalculatorButtonType.function),
              _ButtonConfig('exp', CalculatorButtonType.function),
              _ButtonConfig('M-', CalculatorButtonType.special),
              _ButtonConfig('×', CalculatorButtonType.operator),
            ], buttonWidth),

            // Row 5: Numbers 7-9, sqrt, minus
            _buildRow([
              _ButtonConfig('7', CalculatorButtonType.number),
              _ButtonConfig('8', CalculatorButtonType.number),
              _ButtonConfig('9', CalculatorButtonType.number),
              _ButtonConfig('sqrt', CalculatorButtonType.function),
              _ButtonConfig('-', CalculatorButtonType.operator),
            ], buttonWidth),

            // Row 6: Numbers 4-6, power, plus
            _buildRow([
              _ButtonConfig('4', CalculatorButtonType.number),
              _ButtonConfig('5', CalculatorButtonType.number),
              _ButtonConfig('6', CalculatorButtonType.number),
              _ButtonConfig('^', CalculatorButtonType.operator),
              _ButtonConfig('+', CalculatorButtonType.operator),
            ], buttonWidth),

            // Row 7: Numbers 1-3, factorial, pi
            _buildRow([
              _ButtonConfig('1', CalculatorButtonType.number),
              _ButtonConfig('2', CalculatorButtonType.number),
              _ButtonConfig('3', CalculatorButtonType.number),
              _ButtonConfig('!', CalculatorButtonType.operator),
              _ButtonConfig('π', CalculatorButtonType.number),
            ], buttonWidth),

            // Row 8: 0, ., +/-, e, equals
            _buildRow([
              _ButtonConfig('0', CalculatorButtonType.number),
              _ButtonConfig('.', CalculatorButtonType.number),
              _ButtonConfig('+/-', CalculatorButtonType.operator),
              _ButtonConfig('e', CalculatorButtonType.number),
              _ButtonConfig('=', CalculatorButtonType.equals),
            ], buttonWidth),
          ],
        );
      },
    );
  }

  Widget _buildBasicKeyboard(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final buttonWidth = (width - 32) / 4; // 4 columns

        return Column(
          children: [
            _buildRow([
              _ButtonConfig('AC', CalculatorButtonType.special),
              _ButtonConfig('(', CalculatorButtonType.operator),
              _ButtonConfig(')', CalculatorButtonType.operator),
              _ButtonConfig('÷', CalculatorButtonType.operator),
            ], buttonWidth),
            _buildRow([
              _ButtonConfig('7', CalculatorButtonType.number),
              _ButtonConfig('8', CalculatorButtonType.number),
              _ButtonConfig('9', CalculatorButtonType.number),
              _ButtonConfig('×', CalculatorButtonType.operator),
            ], buttonWidth),
            _buildRow([
              _ButtonConfig('4', CalculatorButtonType.number),
              _ButtonConfig('5', CalculatorButtonType.number),
              _ButtonConfig('6', CalculatorButtonType.number),
              _ButtonConfig('-', CalculatorButtonType.operator),
            ], buttonWidth),
            _buildRow([
              _ButtonConfig('1', CalculatorButtonType.number),
              _ButtonConfig('2', CalculatorButtonType.number),
              _ButtonConfig('3', CalculatorButtonType.number),
              _ButtonConfig('+', CalculatorButtonType.operator),
            ], buttonWidth),
            _buildRow([
              _ButtonConfig('0', CalculatorButtonType.number),
              _ButtonConfig('.', CalculatorButtonType.number),
              _ButtonConfig('DEL', CalculatorButtonType.special),
              _ButtonConfig('=', CalculatorButtonType.equals),
            ], buttonWidth),
          ],
        );
      },
    );
  }

  Widget _buildRow(List<_ButtonConfig> buttons, double buttonWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: buttons.map((config) {
        return CalculatorButton(
          text: config.text,
          type: config.type,
          width: buttonWidth,
          onPressed: () => onInput(config.text),
          isMemoryActive: isMemoryActive &&
              (config.text == 'MR' ||
                  config.text == 'M+' ||
                  config.text == 'M-'),
        );
      }).toList(),
    );
  }
}

class _ButtonConfig {
  final String text;
  final CalculatorButtonType type;

  _ButtonConfig(this.text, this.type);
}
