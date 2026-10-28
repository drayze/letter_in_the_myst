import 'dart:ui';
import 'package:flutter/material.dart';

class FlyingTileData {
  final String letter;
  final Offset startPos;
  final Offset endPos;
  final Color color;

  FlyingTileData({
    required this.letter,
    required this.startPos,
    required this.endPos,
    required this.color,
  });
}

class FlyingTileWidget extends StatelessWidget {
  final FlyingTileData data;
  final double progress; // 0.0 -> 1.0
  final double initialSize;

  const FlyingTileWidget({
    super.key,
    required this.data,
    required this.progress,
    this.initialSize = 52.0,
  });

  @override
  Widget build(BuildContext context) {
    final currentPos = Offset.lerp(data.startPos, data.endPos, progress)!;
    final scale = lerpDouble(1.15, 0.65, progress)!;
    final size = initialSize * scale;

    return Positioned(
      left: currentPos.dx - (size / 2),
      top: currentPos.dy - (size / 2),
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: data.color.withAlpha((220 * (1.0 - progress * 0.2)).toInt()),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.0),
            boxShadow: [
              BoxShadow(
                color: data.color.withAlpha(200),
                blurRadius: 16 * (1.0 - progress * 0.3),
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              data.letter,
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.48,
                fontWeight: FontWeight.bold,
                shadows: const [
                  Shadow(
                    color: Colors.black87,
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}