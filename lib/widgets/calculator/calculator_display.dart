import 'package:flutter/material.dart';

import '../../theme/geogebra_theme.dart';

/// Top display of the scientific calculator, styled after GeoGebra's.
///
/// The display card is a rounded white panel that sits just above the
/// keypad. The current expression appears in small grey type on the
/// left, while the right side shows the evaluated result — or an
/// error chip when the input cannot be parsed.  Small "DEG / RAD" and
/// optional "M" chips hover at the top corners.
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GG.panelDivider),
        boxShadow: [GG.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (hasMemory) _Chip(label: 'M', color: GG.primary),
              const Spacer(),
              _Chip(label: angleMode, color: GG.textSecondary),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Text(
                expression.isEmpty ? '0' : expression,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: GG.textSecondary,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (errorMessage != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFDECEA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                errorMessage!,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFFC62828),
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
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w300,
                    color: GG.textPrimary,
                    height: 1.1,
                    fontFeatures: [FontFeature.tabularFigures()],
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

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
