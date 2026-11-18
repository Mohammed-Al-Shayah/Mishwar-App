import 'package:flutter/material.dart';

class EarningsBarPainter extends CustomPainter {
  const EarningsBarPainter({
    required this.fraction,
    required this.color,
    required this.minimumHeight,
  });
  final double fraction;
  final Color color;
  final double minimumHeight;
  @override
  void paint(Canvas canvas, Size size) {
    final height = (size.height * fraction).clamp(minimumHeight, size.height);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - height, size.width, height),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(EarningsBarPainter oldDelegate) =>
      oldDelegate.fraction != fraction ||
      oldDelegate.color != color ||
      oldDelegate.minimumHeight != minimumHeight;
}
