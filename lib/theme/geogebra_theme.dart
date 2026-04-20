import 'package:flutter/material.dart';

/// GeoGebra-inspired theme tokens and helpers.
///
/// Colors and typography are chosen to match the look of the public
/// GeoGebra web suite (graphing calculator, scientific calculator, and
/// geometry apps) as closely as possible without using their assets.
class GG {
  GG._();

  // Brand palette -------------------------------------------------------------
  /// GeoGebra primary blue used in app-bar tabs, sliders and FABs.
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFF5E92F3);
  static const Color primaryTint = Color(0xFFE3F2FD);

  // Graph palette -------------------------------------------------------------
  /// Red used for first function on the graph view.
  static const Color red = Color(0xFFD03B3B);
  static const Color orange = Color(0xFFFA7E19);
  static const Color green = Color(0xFF388C46);
  static const Color purple = Color(0xFF6042A6);
  static const Color teal = Color(0xFF009688);

  // Surfaces ------------------------------------------------------------------
  static const Color appBg = Color(0xFFFAFAFA);
  static const Color sidebarBg = Color(0xFFFFFFFF);
  static const Color panelDivider = Color(0xFFE5E5E5);
  static const Color subtle = Color(0xFFF2F2F2);
  static const Color focusRow = Color(0xFFE8F1FB);

  // Text ----------------------------------------------------------------------
  static const Color textPrimary = Color(0xFF202124);
  static const Color textSecondary = Color(0xFF5F6368);
  static const Color textHint = Color(0xFF9AA0A6);

  // Calculator keypad ---------------------------------------------------------
  /// Key face color for numbers (near-white).
  static const Color keyNumber = Color(0xFFFFFFFF);
  static const Color keyOperator = Color(0xFFECEFF1);
  static const Color keyFunction = Color(0xFFE1EDFA);
  static const Color keySpecial = Color(0xFFE0E0E0);
  static const Color keyEquals = primary;

  // Elevation / borders ------------------------------------------------------
  static BorderRadius get rSm => BorderRadius.circular(6);
  static BorderRadius get rMd => BorderRadius.circular(10);
  static BorderRadius get rLg => BorderRadius.circular(16);

  static final BoxShadow softShadow = BoxShadow(
    color: Colors.black.withValues(alpha: 0.06),
    blurRadius: 8,
    offset: const Offset(0, 2),
  );

  static final BoxShadow rimShadow = BoxShadow(
    color: Colors.black.withValues(alpha: 0.04),
    blurRadius: 1,
    offset: const Offset(0, 1),
  );

  // ThemeData factory --------------------------------------------------------
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        primary: primary,
        surface: sidebarBg,
      ),
      scaffoldBackgroundColor: appBg,
      fontFamily: 'Roboto',
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
        iconTheme: IconThemeData(color: textPrimary),
        shape: Border(bottom: BorderSide(color: panelDivider, width: 1)),
      ),
      dividerTheme: const DividerThemeData(
        color: panelDivider,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: textSecondary, size: 20),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: const Color(0xFF424242),
          borderRadius: rSm,
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        thumbColor: primary,
        inactiveTrackColor: const Color(0xFFDDE3EA),
        trackHeight: 3,
        overlayColor: primary.withValues(alpha: 0.12),
        valueIndicatorColor: primary,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: rSm),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: subtle,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: rSm,
          borderSide: const BorderSide(color: panelDivider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: rSm,
          borderSide: const BorderSide(color: panelDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: rSm,
          borderSide: const BorderSide(color: primary, width: 1.4),
        ),
        hintStyle: const TextStyle(color: textHint, fontSize: 14),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: rMd),
        titleTextStyle: const TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 18,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
    );
  }
}
