import 'package:flutter/material.dart';
import '../models/empty_bubble.dart';
import '../models/letter_tile.dart';

/// Renders a Letter Bubble floating in the cauldron
class LetterBubbleWidget extends StatelessWidget {
  final LetterTile tile;
  final double size;
  final Color activeColor;

  const LetterBubbleWidget({
    super.key,
    required this.tile,
    this.size = 52.0,
    this.activeColor = const Color(0xFF00F5D4),
  });

  @override
  Widget build(BuildContext context) {
    Color bubbleColor;
    Color borderColor;
    Color textColor;
    List<BoxShadow> boxShadow;
    double scale = 1.0;

    if (tile.isUsed) {
      final color = tile.solvedColor ?? const Color(0xFF52B788);
      bubbleColor = color.withAlpha(90);
      borderColor = color;
      textColor = Colors.white;
      boxShadow = [
        BoxShadow(
          color: color.withAlpha(140),
          blurRadius: 10,
          spreadRadius: 1,
        ),
      ];
    } else if (tile.isSelected) {
      bubbleColor = activeColor.withAlpha(140);
      borderColor = activeColor;
      textColor = Colors.white;
      scale = 1.15;
      boxShadow = [
        BoxShadow(
          color: activeColor.withAlpha(200),
          blurRadius: 16,
          spreadRadius: 3,
        ),
      ];
    } else if (tile.isHinted) {
      bubbleColor = const Color(0xFF7A5C00);
      borderColor = const Color(0xFFFFD700);
      textColor = const Color(0xFFFFE57F);
      scale = 1.08;
      boxShadow = [
        BoxShadow(
          color: const Color(0xFFFFD700).withAlpha(200),
          blurRadius: 14,
          spreadRadius: 2,
        ),
      ];
    } else {
      bubbleColor = const Color(0xFF381460).withAlpha(190);
      borderColor = const Color(0xFF8A50C0);
      textColor = const Color(0xFFE0AAFF);
      boxShadow = [
        BoxShadow(
          color: const Color(0xFF8A50C0).withAlpha(110),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ];
    }

    return AnimatedScale(
      duration: const Duration(milliseconds: 150),
      scale: scale,
      curve: Curves.easeOutBack,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bubbleColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor,
            width: tile.isSelected || tile.isHinted ? 2.5 : 1.6,
          ),
          boxShadow: boxShadow,
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.4),
            radius: 0.85,
            colors: [
              Color.alphaBlend(Colors.white.withAlpha(120), bubbleColor),
              bubbleColor,
              Color.alphaBlend(Colors.black.withAlpha(80), bubbleColor),
            ],
            stops: const [0.0, 0.65, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Top-Left Bubble Specular Highlight Dot
            Positioned(
              top: size * 0.14,
              left: size * 0.16,
              child: Container(
                width: size * 0.22,
                height: size * 0.14,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(180),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // Letter Text
            Center(
              child: Text(
                tile.letter,
                style: TextStyle(
                  color: textColor,
                  fontSize: size * 0.46,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: borderColor.withAlpha(160),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Renders an Empty Bubble floating in the cauldron
class EmptyBubbleWidget extends StatelessWidget {
  final EmptyBubbleData data;

  const EmptyBubbleWidget({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: data.size,
      height: data.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: data.bubbleColor.withAlpha((data.opacity * 100).toInt()),
        border: Border.all(
          color: data.bubbleColor.withAlpha((data.opacity * 200).toInt()),
          width: 1.0,
        ),
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.4),
          radius: 0.85,
          colors: [
            Colors.white.withAlpha((data.opacity * 180).toInt()),
            data.bubbleColor.withAlpha((data.opacity * 80).toInt()),
            Colors.transparent,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Specular Reflection Highlight
          Positioned(
            top: data.size * 0.14,
            left: data.size * 0.16,
            child: Container(
              width: data.size * 0.25,
              height: data.size * 0.15,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((data.opacity * 220).toInt()),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
