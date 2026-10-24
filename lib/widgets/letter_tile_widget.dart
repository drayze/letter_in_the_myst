import 'package:flutter/material.dart';
import '../models/letter_tile.dart';

class LetterTileWidget extends StatelessWidget {
  final LetterTile tile;
  final VoidCallback? onTap;
  final double size;

  const LetterTileWidget({
    super.key,
    required this.tile,
    this.onTap,
    this.size = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    Color textColor;
    List<BoxShadow> boxShadow;

    if (tile.isUsed) {
      // Solved state
      bgColor = const Color(0xFF1E3A2B);
      borderColor = const Color(0xFF4CAF50);
      textColor = const Color(0xFF81C784);
      boxShadow = [
        BoxShadow(
          color: const Color(0xFF4CAF50).withAlpha(100),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ];
    } else if (tile.isSelected) {
      // Currently in guess tray / selected state
      bgColor = const Color(0xFF311B92);
      borderColor = const Color(0xFF7C4DFF);
      textColor = Colors.white70;
      boxShadow = [
        BoxShadow(
          color: const Color(0xFF7C4DFF).withAlpha(80),
          blurRadius: 6,
        ),
      ];
    } else if (tile.isHinted) {
      // Hinted state
      bgColor = const Color(0xFF4A3B00);
      borderColor = const Color(0xFFFFD700);
      textColor = const Color(0xFFFFE57F);
      boxShadow = [
        BoxShadow(
          color: const Color(0xFFFFD700).withAlpha(150),
          blurRadius: 12,
          spreadRadius: 2,
        ),
      ];
    } else {
      // Normal available state
      bgColor = const Color(0xFF231942);
      borderColor = const Color(0xFF5E548E);
      textColor = const Color(0xFFE0AAFF);
      boxShadow = [
        BoxShadow(
          color: const Color(0xFF5E548E).withAlpha(90),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ];
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: tile.isSelected ? 0.35 : (tile.isUsed ? 0.7 : 1.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (tile.isUsed || tile.isSelected) ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: const Color(0xFF9D4EDD).withAlpha(100),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: tile.isHinted ? 2.5 : 1.5),
              boxShadow: boxShadow,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  bgColor,
                  Color.alphaBlend(Colors.white.withAlpha(25), bgColor),
                ],
              ),
            ),
            child: Center(
              child: Text(
                tile.letter,
                style: TextStyle(
                  color: textColor,
                  fontSize: size * 0.48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  shadows: [
                    Shadow(
                      color: borderColor.withAlpha(120),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
