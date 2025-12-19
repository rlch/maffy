import 'package:flutter/painting.dart';

/// Default color palette for graph expressions (matching Desmos)
class GraphColors {
  static const Color red = Color(0xFFC74440);
  static const Color blue = Color(0xFF2D70B3);
  static const Color green = Color(0xFF388C46);
  static const Color purple = Color(0xFF6042A6);
  static const Color orange = Color(0xFFFA7E19);
  static const Color black = Color(0xFF000000);

  static const List<Color> palette = [
    red,
    blue,
    green,
    purple,
    orange,
    black,
  ];

  /// Get the next color in the palette based on index
  static Color getColor(int index) => palette[index % palette.length];

  GraphColors._();
}
