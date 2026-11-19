import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

class IslamicGeometricPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const IslamicGeometricPainter({required this.color, this.strokeWidth = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final center = Offset(size.width * 0.85, size.height * 0.45);
    final radius = size.height * 0.55;

    // Outer concentric circle
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(center, radius * 0.8, paint);
    canvas.drawCircle(center, radius * 0.5, paint);

    // 8-pointed star (Rub el Hizb)
    _drawStar(canvas, center, radius * 0.7, 8, paint);
    _drawStar(canvas, center, radius * 0.4, 8, paint);

    // Subtle decorative diagonal lines
    final linePaint = Paint()
      ..color = color.withValues(alpha: color.a * 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (double i = -size.height; i < size.width; i += 32) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height * 0.6, size.height),
        linePaint,
      );
    }
  }

  void _drawStar(
    Canvas canvas,
    Offset center,
    double radius,
    int points,
    Paint paint,
  ) {
    final path = Path();
    final double step = math.pi / points;

    for (int i = 0; i < 2 * points; i++) {
      final r = (i % 2 == 0) ? radius : radius * 0.6;
      final angle = i * step - math.pi / 2;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant IslamicGeometricPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
