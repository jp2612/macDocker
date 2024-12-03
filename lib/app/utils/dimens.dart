import 'package:flutter/material.dart';

class Dimens {
  // Padding values
  static const EdgeInsets horizontalPadding = EdgeInsets.symmetric(horizontal: 10);
  static const EdgeInsets verticalPadding = EdgeInsets.symmetric(vertical: 10);

  // Container decoration
  static BoxDecoration containerDecoration = BoxDecoration(
    color: const Color(0xFF7651F2),
    borderRadius: BorderRadius.circular(12),
    boxShadow: const [
      BoxShadow(
        color: Color(0xFF7651F2),
        offset: Offset(0, 4),
        blurRadius: 6,
      ),
    ],
  );

  // Spacing and layout values
  static const double itemHeight = 60;
  static const double itemSpacing = 20;
  static const double runSpacing = 0;

  // Tooltip positioning
  static const double tooltipOffset = 15;
  static const double tooltipTopOffset = 50;

  // Tooltip text style
  static const TextStyle tooltipTextStyle = TextStyle(color: Colors.black, fontSize: 12);
}
