import 'package:flutter/material.dart';

/// Custom home icon with a minus/dash symbol inside
class CustomHomeIcon extends StatelessWidget {
  final bool isFilled;
  final Color? color;
  final double? size;

  const CustomHomeIcon({
    super.key,
    this.isFilled = false,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? IconTheme.of(context).color ?? Colors.black;
    final iconSize = size ?? 24.0;

    return CustomPaint(
      size: Size(iconSize, iconSize),
      painter: _HomeIconPainter(
        color: iconColor,
        isFilled: isFilled,
      ),
    );
  }
}

class _HomeIconPainter extends CustomPainter {
  final Color color;
  final bool isFilled;

  _HomeIconPainter({
    required this.color,
    required this.isFilled,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = isFilled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = size.width * 0.07
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    // Scale factors
    final width = size.width;
    final height = size.height;

    // Define the house shape (rounded house with flat bottom)
    final cornerRadius = width * 0.12;

    // Start from bottom left
    path.moveTo(width * 0.15, height * 0.9);

    // Left side going up
    path.lineTo(width * 0.15, height * 0.5);

    // Top-left curve to roof peak
    path.quadraticBezierTo(
      width * 0.15, height * 0.35,
      width * 0.25, height * 0.25,
    );

    // Left roof slope
    path.lineTo(width * 0.5, height * 0.1);

    // Right roof slope
    path.lineTo(width * 0.75, height * 0.25);

    // Top-right curve
    path.quadraticBezierTo(
      width * 0.85, height * 0.35,
      width * 0.85, height * 0.5,
    );

    // Right side going down
    path.lineTo(width * 0.85, height * 0.9);

    // Bottom-right corner
    path.quadraticBezierTo(
      width * 0.85, height * 0.95,
      width * 0.8, height * 0.95,
    );

    // Bottom side
    path.lineTo(width * 0.2, height * 0.95);

    // Bottom-left corner
    path.quadraticBezierTo(
      width * 0.15, height * 0.95,
      width * 0.15, height * 0.9,
    );

    path.close();

    canvas.drawPath(path, paint);

    // Draw the minus/dash symbol in the middle
    final dashPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.065
      ..strokeCap = StrokeCap.round;

    final dashY = height * 0.65;
    final dashLeft = width * 0.35;
    final dashRight = width * 0.65;

    canvas.drawLine(
      Offset(dashLeft, dashY),
      Offset(dashRight, dashY),
      dashPaint,
    );
  }

  @override
  bool shouldRepaint(_HomeIconPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isFilled != isFilled;
  }
}
