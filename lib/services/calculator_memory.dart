/// Memory manager for calculator
class CalculatorMemory {
  double _memory = 0;

  /// Get current memory value
  double get value => _memory;

  /// Add value to memory
  void add(double value) {
    _memory += value;
  }

  /// Subtract value from memory
  void subtract(double value) {
    _memory -= value;
  }

  /// Clear memory
  void clear() {
    _memory = 0;
  }

  /// Set memory to a specific value
  void set(double value) {
    _memory = value;
  }

  /// Check if memory has a value
  bool get hasValue => _memory != 0;
}
