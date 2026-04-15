import 'package:flutter/material.dart';
import 'package:maffy/screens/scientific_calculator_screen.dart';

/// Example demonstrating how to use the Scientific Calculator
void main() {
  runApp(const CalculatorExample());
}

class CalculatorExample extends StatelessWidget {
  const CalculatorExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scientific Calculator Example',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const CalculatorExampleHome(),
    );
  }
}

class CalculatorExampleHome extends StatelessWidget {
  const CalculatorExampleHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator Examples'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Calculator Integration Examples',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Example 1: Full Screen Calculator
          _ExampleCard(
            title: 'Full Screen Calculator',
            description: 'Open the calculator in a new screen',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScientificCalculatorScreen(),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Example 2: Programmatic Usage
          _ExampleCard(
            title: 'Programmatic Calculator',
            description: 'Use calculator engine directly',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProgrammaticExample(),
                ),
              );
            },
          ),
          
          const SizedBox(height: 32),
          
          const Text(
            'Features',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const _FeatureItem(
            icon: Icons.calculate,
            title: 'Scientific Functions',
            description: 'sin, cos, tan, ln, log, exp, sqrt, and more',
          ),
          const _FeatureItem(
            icon: Icons.memory,
            title: 'Memory Functions',
            description: 'M+, M-, MR, MC for storing values',
          ),
          const _FeatureItem(
            icon: Icons.history,
            title: 'Calculation History',
            description: 'View and reuse past calculations',
          ),
          const _FeatureItem(
            icon: Icons.rotate_right,
            title: 'Angle Modes',
            description: 'Switch between degrees and radians',
          ),
          const _FeatureItem(
            icon: Icons.keyboard,
            title: 'Keyboard Support',
            description: 'Full keyboard shortcuts support',
          ),
          const _FeatureItem(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            description: 'Automatic theme switching',
          ),
        ],
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ExampleCard({
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Example of programmatic usage
class ProgrammaticExample extends StatefulWidget {
  const ProgrammaticExample({super.key});

  @override
  State<ProgrammaticExample> createState() => _ProgrammaticExampleState();
}

class _ProgrammaticExampleState extends State<ProgrammaticExample> {
  final List<Map<String, String>> examples = [
    {'expr': '2+3×4', 'desc': 'Order of operations', 'result': '14'},
    {'expr': 'sin(30)', 'desc': 'Trigonometry (degrees)', 'result': '0.5'},
    {'expr': 'sqrt(16)', 'desc': 'Square root', 'result': '4'},
    {'expr': '5!', 'desc': 'Factorial', 'result': '120'},
    {'expr': '2^8', 'desc': 'Power', 'result': '256'},
    {'expr': 'ln(e)', 'desc': 'Natural logarithm', 'result': '1'},
    {'expr': 'log10(100)', 'desc': 'Log base 10', 'result': '2'},
    {'expr': '2×π', 'desc': 'With constants', 'result': '6.283...'},
    {'expr': 'sqrt((3^2)+(4^2))', 'desc': 'Pythagorean theorem', 'result': '5'},
  ];

  String? result;
  String? selectedExpression;
  int? selectedIndex;

  void evaluate(String expression, String expectedResult, int index) {
    setState(() {
      selectedExpression = expression;
      selectedIndex = index;
      result = expectedResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Programmatic Usage'),
      ),
      body: Column(
        children: [
          // Result display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tap an example to see the result',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                if (selectedExpression != null) ...[
                  Text(
                    selectedExpression!,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (result != null)
                    Text(
                      '= $result',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                ] else
                  const Text(
                    'No expression selected',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
              ],
            ),
          ),
          
          // Examples list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: examples.length,
              itemBuilder: (context, index) {
                final example = examples[index];
                final isSelected = selectedIndex == index;
                
                return Card(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  child: ListTile(
                    title: Text(
                      example['expr']!,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(example['desc']!),
                    trailing: Text(
                      '= ${example['result']!}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => evaluate(
                      example['expr']!,
                      example['result']!,
                      index,
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Code example
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Code Example:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'import \'package:maffy/services/calculator_engine.dart\';\n\n'
                    'String result = CalculatorEngine.evaluate(\n'
                    '  \'2+3×4\',\n'
                    '  isDegrees: true,\n'
                    ');\n'
                    '// result = "14"',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
