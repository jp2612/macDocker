import 'package:flutter/material.dart';

/// A custom tooltip widget that displays a message with a triangular pointer.
class CustomTooltip extends StatelessWidget {
  final String message;
  final Color backgroundColor;

  const CustomTooltip({
    required this.message,
    this.backgroundColor = const Color(0xFF9F84F4),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The tooltip message container
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        // The triangular pointer
        CustomPaint(
          size: const Size(10, 6), // Width and height of the triangle
          painter: TrianglePainter(backgroundColor: backgroundColor),
        ),
      ],
    );
  }
}

/// A custom painter that draws a triangle pointer.
class TrianglePainter extends CustomPainter {
  final Color backgroundColor;

  TrianglePainter({required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    // Drawing the triangle
    final path = Path()
      ..moveTo(0, 0) // Start at the top-left corner
      ..lineTo(size.width / 2, size.height) // Draw to the bottom-center
      ..lineTo(size.width, 0) // Draw to the top-right corner
      ..close(); // Close the path

    // Paint the triangle onto the canvas
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
