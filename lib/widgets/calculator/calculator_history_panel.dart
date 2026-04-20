import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/calculator_state.dart';
import '../../theme/geogebra_theme.dart';

/// Slide-out history panel for the scientific calculator.
///
/// Styled after the "History" drawer on GeoGebra's scientific app: a
/// white column with a sticky header, a thin 1 dp leading border
/// (left shadow on small screens), and per-entry rows that bubble up
/// the result in a larger font beneath the expression.
class CalculatorHistoryPanel extends StatelessWidget {
  final List<CalculationHistory> history;
  final Function(CalculationHistory) onHistoryItemTap;
  final VoidCallback onClearHistory;

  const CalculatorHistoryPanel({
    super.key,
    required this.history,
    required this.onHistoryItemTap,
    required this.onClearHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: GG.panelDivider)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: GG.panelDivider)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'History',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: GG.textPrimary,
                  ),
                ),
                if (history.isNotEmpty)
                  TextButton.icon(
                    onPressed: onClearHistory,
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Clear'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: history.isEmpty
                ? _EmptyState()
                : ListView.builder(
                    itemCount: history.length,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemBuilder: (context, index) => _HistoryItem(
                      history: history[index],
                      onTap: () => onHistoryItemTap(history[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.history, size: 48, color: GG.textHint),
          SizedBox(height: 12),
          Text(
            'No history yet',
            style: TextStyle(
              fontSize: 14,
              color: GG.textSecondary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Past calculations will appear here',
            style: TextStyle(fontSize: 12, color: GG.textHint),
          ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final CalculationHistory history;
  final VoidCallback onTap;

  const _HistoryItem({required this.history, required this.onTap});

  String _format(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'Just now';
    if (d.inHours < 1) return '${d.inMinutes}m ago';
    if (d.inDays < 1) return '${d.inHours}h ago';
    if (d.inDays == 1) return 'Yesterday';
    if (d.inDays < 7) return '${d.inDays}d ago';
    return DateFormat('MMM d').format(t);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: GG.panelDivider)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _format(history.timestamp),
              style: const TextStyle(
                fontSize: 11,
                color: GG.textHint,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              history.expression,
              style: const TextStyle(
                fontSize: 15,
                color: GG.textSecondary,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            const SizedBox(height: 2),
            Text(
              '= ${history.result}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: GG.textPrimary,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
