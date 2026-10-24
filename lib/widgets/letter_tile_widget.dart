import 'package:flutter/material.dart';
import '../models/letter_tile.dart';

class LetterTileWidget extends StatelessWidget {
  final LetterTile tile;
  final double size;
  final Color activeColor;

  const LetterTileWidget({
    super.key,
    required this.tile,
    this.size = 54.0,
    this.activeColor = const Color(0xFF00F5D4),
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    Color textColor;
    List<BoxShadow> boxShadow;
    double scale = 1.0;

    if (tile.isUsed) {
      // Solved tile
      final tileColor = tile.solvedColor ?? const Color(0xFF52B788);
      bgColor = tileColor.withAlpha(80);
      borderColor = tileColor;
      textColor = Colors.white;
      boxShadow = [
        BoxShadow(
          color: tileColor.withAlpha(120),
          blurRadius: 10,
          spreadRadius: 1,
        ),
      ];
    } else if (tile.isSelected) {
      // Currently being highlighted by finger trace line!
      bgColor = activeColor.withAlpha(100);
      borderColor = activeColor;
      textColor = Colors.white;
      scale = 1.12;
      boxShadow = [
        BoxShadow(
          color: activeColor.withAlpha(180),
          blurRadius: 14,
          spreadRadius: 2,
        ),
      ];
    } else if (tile.isHinted) {
      // Hinted
      bgColor = const Color(0xFF5C4000);
      borderColor = const Color(0xFFFFD700);
      textColor = const Color(0xFFFFE57F);
      scale = 1.05;
      boxShadow = [
        BoxShadow(
          color: const Color(0xFFFFD700).withAlpha(180),
          blurRadius: 12,
          spreadRadius: 2,
        ),
      ];
    } else {
      // Idle Jumble tile
      bgColor = const Color(0xFF241442);
      borderColor = const Color(0xFF5E548E);
      textColor = const Color(0xFFE0AAFF);
      boxShadow = [
        BoxShadow(
          color: const Color(0xFF3C096C).withAlpha(100),
          blurRadius: 6,
          offset: const Offset(0, 3),
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
          color: bgColor,
          shape: BoxShape.circle, // Circular tile for jumble aesthetic
          border: Border.all(
            color: borderColor,
            width: tile.isSelected || tile.isHinted ? 2.5 : 1.5,
          ),
          boxShadow: boxShadow,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              bgColor,
              Color.alphaBlend(Colors.white.withAlpha(20), bgColor),
            ],
          ),
        ),
        child: Center(
          child: Text(
            tile.letter,
            style: TextStyle(
              color: textColor,
              fontSize: size * 0.46,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  color: borderColor.withAlpha(140),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
