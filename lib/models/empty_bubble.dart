import 'dart:math';
import 'package:flutter/material.dart';

class EmptyBubbleData {
  final double relX; // 0.1 to 0.9 inside cauldron
  final double relY; // 0.1 to 0.9 inside cauldron
  final double size; // 16.0 to 36.0
  final double opacity;
  final Color bubbleColor;

  EmptyBubbleData({
    required this.relX,
    required this.relY,
    required this.size,
    required this.opacity,
    required this.bubbleColor,
  });

  static List<EmptyBubbleData> generateRandomList(int count) {
    final rand = Random();
    final List<Color> colors = [
      const Color(0xFF00F5D4),
      const Color(0xFFE0AAFF),
      const Color(0xFF74C69D),
      const Color(0xFFFF9E00),
      const Color(0xFF9D4EDD),
    ];

    return List.generate(count, (i) {
      return EmptyBubbleData(
        relX: 0.12 + rand.nextDouble() * 0.76,
        relY: 0.12 + rand.nextDouble() * 0.76,
        size: 16.0 + rand.nextDouble() * 20.0,
        opacity: 0.3 + rand.nextDouble() * 0.45,
        bubbleColor: colors[rand.nextInt(colors.length)],
      );
    });
  }
}
