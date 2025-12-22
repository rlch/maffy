import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../widgets/calculator/calculator_display.dart';
import '../widgets/calculator/calculator_keyboard.dart';
import '../widgets/calculator/calculator_history_panel.dart';
import '../models/calculator_state.dart';

/// Scientific Calculator Screen
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
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      child: ChangeNotifierProvider(
        create: (_) => CalculatorProvider(),
        child: Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            backgroundColor: Colors.grey.shade800,
            foregroundColor: Colors.white,
            title: const Text('Scientific Calculator'),
            actions: [
            Consumer<CalculatorProvider>(
              builder: (context, calculator, _) {
                return IconButton(
                  icon: Icon(
                    _showHistory ? Icons.calculate : Icons.history,
                  ),
                  tooltip: _showHistory ? 'Show Calculator' : 'Show History',
                  onPressed: () {
                    setState(() {
                      _showHistory = !_showHistory;
                    });
                  },
                );
              },
            ),
          ],
        ),
        body: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    // Support keyboard shortcuts
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
              // Responsive layout
              final isWide = constraints.maxWidth > 600;

              if (isWide) {
                // Wide layout: calculator and history side by side
                return Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildCalculator(calculator),
                    ),
                    if (_showHistory)
                      SizedBox(
                        width: 300,
                        child: _buildHistory(calculator),
                      ),
                  ],
                );
              } else {
                // Narrow layout: stack calculator and history
                return Stack(
                  children: [
                    _buildCalculator(calculator),
                    if (_showHistory)
                      Positioned.fill(
                        child: _buildHistory(calculator),
                      ),
                  ],
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildCalculator(CalculatorProvider calculator) {
    return Column(
      children: [
        // Display
        CalculatorDisplay(
          expression: calculator.state.displayExpression,
          result: calculator.state.result,
          errorMessage: calculator.state.errorMessage,
          angleMode: calculator.state.angleMode == AngleMode.degrees
              ? 'DEG'
              : 'RAD',
          hasMemory: calculator.state.memory != 0,
        ),

        const SizedBox(height: 16),

        // Keyboard
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: CalculatorKeyboard(
                onInput: calculator.input,
                isMemoryActive: calculator.state.memory != 0,
                showScientific: true,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildHistory(CalculatorProvider calculator) {
    return CalculatorHistoryPanel(
      history: calculator.state.history,
      onHistoryItemTap: (history) {
        calculator.loadFromHistory(history);
        setState(() {
          _showHistory = false;
        });
      },
      onClearHistory: () {
        calculator.clearHistory();
      },
    );
  }

  void _handleKeyPress(String key) {
    final calculator = context.read<CalculatorProvider>();

    // Map keyboard keys to calculator inputs
    final keyMap = {
      '0': '0',
      '1': '1',
      '2': '2',
      '3': '3',
      '4': '4',
      '5': '5',
      '6': '6',
      '7': '7',
      '8': '8',
      '9': '9',
      '+': '+',
      '-': '-',
      '*': '×',
      '/': '÷',
      '.': '.',
      '(': '(',
      ')': ')',
      'Enter': '=',
      'Backspace': 'DEL',
      'Escape': 'AC',
      'p': 'π',
      'e': 'e',
    };

    final input = keyMap[key];
    if (input != null) {
      calculator.input(input);
    }
  }
}
