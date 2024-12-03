import 'package:flutter/material.dart';

/// A class that holds all dimension values for padding, spacing, decoration,
/// and other layout-related properties used throughout the application.
class Dimens {
  // Padding values
  /// Horizontal padding value used for spacing elements.
  static const EdgeInsets horizontalPadding = EdgeInsets.symmetric(horizontal: 10);

  /// Vertical padding value used for spacing elements.
  static const EdgeInsets verticalPadding = EdgeInsets.symmetric(vertical: 10);

  // Container decoration
  /// Decoration used for containers, including background color, border radius,
  /// and box shadow for elevation.
  static BoxDecoration containerDecoration = BoxDecoration(
    color: const Color(0xFF7651F2),  // Background color
    borderRadius: BorderRadius.circular(12),  // Rounded corners
    boxShadow: const [
      BoxShadow(
        color: Color(0xFF7651F2),  // Shadow color
        offset: Offset(0, 4),  // Shadow offset
        blurRadius: 6,  // Shadow blur radius
      ),
    ],
  );

  // Spacing and layout values
  /// Height used for items within containers (e.g., app icons).
  static const double itemHeight = 60;

  /// Horizontal spacing between items in a layout.
  static const double itemSpacing = 20;

  /// Vertical spacing between items in a layout (usually no spacing).
  static const double runSpacing = 0;

  // Tooltip positioning
  /// Offset for positioning the tooltip.
  static const double tooltipOffset = 12;

  /// Top offset for positioning the tooltip.
  static const double tooltipTopOffset = 50;

  /// Horizontal padding inside the tooltip for text.
  static const double tooltipPaddingHorizontal = 8.0;

  /// Vertical padding inside the tooltip for text.
  static const double tooltipPaddingVertical = 4.0;

  /// Font size for the text inside the tooltip.
  static const double tooltipFontSize = 12.0;

  /// Width of the triangle for the tooltip.
  static const double triangleWidth = 10.0;

  /// Height of the triangle for the tooltip.
  static const double triangleHeight = 6.0;

  // Tooltip text style
  /// Style used for the text inside the tooltip.
  static const TextStyle tooltipTextStyle = TextStyle(color: Colors.black, fontSize: 12);

  // Size for the icon
  /// Size of icons within the application (e.g., app icons).
  static const double iconSize = 40.0;

  // Padding for elements (optional)
  /// Vertical padding used for spacing elements.
  static const double paddingVertical = 8.0;

  /// Horizontal padding used for spacing elements.
  static const double paddingHorizontal = 12.0;
}
