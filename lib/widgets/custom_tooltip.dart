import 'package:flutter/material.dart';

/// A custom tooltip widget that displays a message with a triangular pointer.
///
/// This widget shows a [message] inside a styled container with a triangular pointer
/// beneath it. The tooltip is designed to appear as a small popup with a black background
/// and white text.
class CustomTooltip extends StatelessWidget {
  /// The message to be displayed inside the tooltip.
  final String message;

  /// Creates a [CustomTooltip] widget with the given [message].
  const CustomTooltip({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The container holding the message text.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        // The triangular pointer at the bottom of the tooltip.
        CustomPaint(
          size: const Size(10, 5),
          painter: TrianglePainter(),
        ),
      ],
    );
  }
}

/// A custom painter that draws a triangle.
///
/// This painter draws a black triangle which is used as a pointer beneath the tooltip's message.
class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Drawing the triangle
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    // Paint the triangle onto the canvas.
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}