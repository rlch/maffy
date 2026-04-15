import 'package:flutter/material.dart';

/// Calculator display widget
class CalculatorDisplay extends StatelessWidget {
  final String expression;
  final String result;
  final String? errorMessage;
  final String angleMode;
  final bool hasMemory;

  const CalculatorDisplay({
    super.key,
    required this.expression,
    required this.result,
    this.errorMessage,
    required this.angleMode,
    this.hasMemory = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Memory indicator
              if (hasMemory)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'M',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                )
              else
                const SizedBox(),
              // Angle mode indicator
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  angleMode,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Expression display
          SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Text(
                expression.isEmpty ? '0' : expression,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurfaceVariant,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Result/Error display
          if (errorMessage != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                errorMessage!,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Text(
                  result,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                    color: colorScheme.onSurface,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
