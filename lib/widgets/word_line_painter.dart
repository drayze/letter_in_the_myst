import 'package:flutter/material.dart';
import '../models/letter_tile.dart';

class WordLinePainter extends CustomPainter {
  final List<SolvedWordLine> solvedLines;
  final List<Offset> currentDragPoints;
  final Offset? currentTouchPoint;
  final Color activeColor;

  WordLinePainter({
    required this.solvedLines,
    required this.currentDragPoints,
    this.currentTouchPoint,
    this.activeColor = const Color(0xFF00F5D4),
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Solved Word Lines
    for (var line in solvedLines) {
      if (line.points.length < 2) continue;
      _drawLinePath(
        canvas: canvas,
        points: line.points,
        touchPoint: null,
        mainColor: line.color,
        strokeWidth: 12.0,
      );
    }

    // 2. Draw Active Drag Line
    if (currentDragPoints.isNotEmpty) {
      _drawLinePath(
        canvas: canvas,
        points: currentDragPoints,
        touchPoint: currentTouchPoint,
        mainColor: activeColor,
        strokeWidth: 14.0,
      );
    }
  }

  void _drawLinePath({
    required Canvas canvas,
    required List<Offset> points,
    required Offset? touchPoint,
    required Color mainColor,
    required double strokeWidth,
  }) {
    final Path path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    if (touchPoint != null) {
      path.lineTo(touchPoint.dx, touchPoint.dy);
    }

    // Outer Glow
    final Paint glowPaint = Paint()
      ..color = mainColor.withAlpha(160)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 8);

    // Main Line Body
    final Paint bodyPaint = Paint()
      ..color = mainColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Inner White Core
    final Paint corePaint = Paint()
      ..color = Colors.white.withAlpha(220)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.35
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, bodyPaint);
    canvas.drawPath(path, corePaint);

    // Draw connection dots at node centers
    final Paint dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (var pt in points) {
      canvas.drawCircle(pt, strokeWidth * 0.3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant WordLinePainter oldDelegate) {
    return true; // Repaint continuously during touch dragging
  }
}
