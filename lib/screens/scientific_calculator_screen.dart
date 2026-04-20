import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/calculator_state.dart';
import '../providers/calculator_provider.dart';
import '../theme/geogebra_theme.dart';
import '../widgets/calculator/calculator_display.dart';
import '../widgets/calculator/calculator_history_panel.dart';
import '../widgets/calculator/calculator_keyboard.dart';
import '../widgets/geogebra_app_bar.dart';

/// GeoGebra-style Scientific Calculator.
///
/// Layout (wide): two columns — left column is the calculator (display
/// docked to the top, keyboard filling the rest), right column is the
/// collapsible history panel.  The top bar keeps the same GeoGebra
/// wordmark used elsewhere in the app.
class ScientificCalculatorScreen extends StatefulWidget {
  const ScientificCalculatorScreen({super.key});

  @override
  State<ScientificCalculatorScreen> createState() =>
      _ScientificCalculatorScreenState();
}

class _ScientificCalculatorScreenState
    extends State<ScientificCalculatorScreen> {
  bool _showHistory = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CalculatorProvider(),
      child: Scaffold(
        backgroundColor: GG.appBg,
        body: SafeArea(
          child: Column(
            children: [
              GeoGebraAppBar(
                subtitle: 'Scientific Calculator',
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: GG.textPrimary),
                  tooltip: 'Back',
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  Consumer<CalculatorProvider>(
                    builder: (context, calc, _) => GeoGebraHeaderAction(
                      icon: _showHistory ? Icons.calculate : Icons.history,
                      label: _showHistory ? 'Keypad' : 'History',
                      onPressed: () => setState(
                        () => _showHistory = !_showHistory,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          _handleKeyPress(event.logicalKey.keyLabel);
        }
        return KeyEventResult.handled;
      },
      child: Consumer<CalculatorProvider>(
        builder: (context, calculator, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 760;
              if (isWide) {
                return Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildCalculator(calculator),
                    ),
                    if (_showHistory)
                      SizedBox(
                        width: 320,
                        child: _buildHistory(calculator),
                      ),
                  ],
                );
              }
              return Stack(
                children: [
                  _buildCalculator(calculator),
                  if (_showHistory)
                    Positioned.fill(child: _buildHistory(calculator)),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCalculator(CalculatorProvider calculator) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CalculatorDisplay(
            expression: calculator.state.displayExpression,
            result: calculator.state.result,
            errorMessage: calculator.state.errorMessage,
            angleMode: calculator.state.angleMode == AngleMode.degrees
                ? 'DEG'
                : 'RAD',
            hasMemory: calculator.state.memory != 0,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: CalculatorKeyboard(
              onInput: calculator.input,
              isMemoryActive: calculator.state.memory != 0,
              showScientific: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistory(CalculatorProvider calculator) {
    return CalculatorHistoryPanel(
      history: calculator.state.history,
      onHistoryItemTap: (h) {
        calculator.loadFromHistory(h);
        setState(() => _showHistory = false);
      },
      onClearHistory: calculator.clearHistory,
    );
  }

  void _handleKeyPress(String key) {
    final calculator = context.read<CalculatorProvider>();
    final keyMap = {
      '0': '0', '1': '1', '2': '2', '3': '3', '4': '4',
      '5': '5', '6': '6', '7': '7', '8': '8', '9': '9',
      '+': '+', '-': '-', '*': '×', '/': '÷', '.': '.',
      '(': '(', ')': ')',
      'Enter': '=', 'Backspace': 'DEL', 'Escape': 'AC',
      'p': 'π', 'e': 'e',
    };
    final input = keyMap[key];
    if (input != null) calculator.input(input);
  }
}
