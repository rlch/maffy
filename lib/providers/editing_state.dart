import 'package:flutter/foundation.dart';

/// Tracks live editing values separately from the committed expression list.
/// This allows the graph to update in real-time without rebuilding the sidebar.
class EditingState extends ChangeNotifier {
  /// Map of expression ID -> current latex being edited
  final Map<String, String> _liveValues = {};

  /// Get the live value for an expression (or null if not being edited)
  String? getLiveValue(String id) => _liveValues[id];

  /// Update the live value for an expression (called on every keystroke)
  void updateLiveValue(String id, String latex) {
    _liveValues[id] = latex;
    notifyListeners();
  }

  /// Clear the live value when editing is complete
  void clearLiveValue(String id) {
    _liveValues.remove(id);
    notifyListeners();
  }

  /// Check if an expression has a live value
  bool hasLiveValue(String id) => _liveValues.containsKey(id);
}
