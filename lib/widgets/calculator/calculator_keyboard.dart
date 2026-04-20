import 'package:flutter/material.dart';

import 'calculator_button.dart';

/// Calculator keypad laid out like the GeoGebra Scientific app.
///
/// Scientific layout is an 8-row x 5-column grid with the top rows
/// dedicated to mode toggles and trig/log functions, numbers 7-0
/// stacked in the middle three columns, memory & operators in the
/// right-most columns, and a full-width primary "=" at the bottom.
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
    return showScientific
        ? _buildScientificKeyboard()
        : _buildBasicKeyboard();
  }

  Widget _buildScientificKeyboard() {
    // 8 rows of 5 buttons each.
    final rows = <List<_K>>[
      [
        _K('DEG/RAD', CalculatorButtonType.special),
        _K('(', CalculatorButtonType.operator),
        _K(')', CalculatorButtonType.operator),
        _K('MC', CalculatorButtonType.special),
        _K('AC', CalculatorButtonType.special),
      ],
      [
        _K('sin', CalculatorButtonType.function),
        _K('cos', CalculatorButtonType.function),
        _K('tan', CalculatorButtonType.function),
        _K('MR', CalculatorButtonType.special),
        _K('DEL', CalculatorButtonType.special),
      ],
      [
        _K('asin', CalculatorButtonType.function),
        _K('acos', CalculatorButtonType.function),
        _K('atan', CalculatorButtonType.function),
        _K('M+', CalculatorButtonType.special),
        _K('÷', CalculatorButtonType.operator),
      ],
      [
        _K('ln', CalculatorButtonType.function),
        _K('log10', CalculatorButtonType.function),
        _K('exp', CalculatorButtonType.function),
        _K('M-', CalculatorButtonType.special),
        _K('×', CalculatorButtonType.operator),
      ],
      [
        _K('7', CalculatorButtonType.number),
        _K('8', CalculatorButtonType.number),
        _K('9', CalculatorButtonType.number),
        _K('sqrt', CalculatorButtonType.function),
        _K('-', CalculatorButtonType.operator),
      ],
      [
        _K('4', CalculatorButtonType.number),
        _K('5', CalculatorButtonType.number),
        _K('6', CalculatorButtonType.number),
        _K('^', CalculatorButtonType.operator),
        _K('+', CalculatorButtonType.operator),
      ],
      [
        _K('1', CalculatorButtonType.number),
        _K('2', CalculatorButtonType.number),
        _K('3', CalculatorButtonType.number),
        _K('!', CalculatorButtonType.operator),
        _K('π', CalculatorButtonType.number),
      ],
      [
        _K('0', CalculatorButtonType.number),
        _K('.', CalculatorButtonType.number),
        _K('+/-', CalculatorButtonType.operator),
        _K('e', CalculatorButtonType.number),
        _K('=', CalculatorButtonType.equals),
      ],
    ];
    return _grid(rows);
  }

  Widget _buildBasicKeyboard() {
    final rows = <List<_K>>[
      [
        _K('AC', CalculatorButtonType.special),
        _K('(', CalculatorButtonType.operator),
        _K(')', CalculatorButtonType.operator),
        _K('÷', CalculatorButtonType.operator),
      ],
      [
        _K('7', CalculatorButtonType.number),
        _K('8', CalculatorButtonType.number),
        _K('9', CalculatorButtonType.number),
        _K('×', CalculatorButtonType.operator),
      ],
      [
        _K('4', CalculatorButtonType.number),
        _K('5', CalculatorButtonType.number),
        _K('6', CalculatorButtonType.number),
        _K('-', CalculatorButtonType.operator),
      ],
      [
        _K('1', CalculatorButtonType.number),
        _K('2', CalculatorButtonType.number),
        _K('3', CalculatorButtonType.number),
        _K('+', CalculatorButtonType.operator),
      ],
      [
        _K('0', CalculatorButtonType.number),
        _K('.', CalculatorButtonType.number),
        _K('DEL', CalculatorButtonType.special),
        _K('=', CalculatorButtonType.equals),
      ],
    ];
    return _grid(rows);
  }

  Widget _grid(List<List<_K>> rows) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            for (final row in rows)
              Expanded(
                child: Row(
                  children: [
                    for (final k in row)
                      Expanded(
                        child: CalculatorButton(
                          text: k.text,
                          type: k.type,
                          isMemoryActive: isMemoryActive &&
                              (k.text == 'MR' ||
                                  k.text == 'M+' ||
                                  k.text == 'M-'),
                          onPressed: () => onInput(k.text),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _K {
  final String text;
  final CalculatorButtonType type;
  const _K(this.text, this.type);
}
