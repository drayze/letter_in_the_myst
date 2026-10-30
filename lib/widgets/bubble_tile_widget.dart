import 'package:flutter/material.dart';
import '../models/letter_tile.dart';
import '../theme/themes.dart';

/// Renders a Bubble floating in the cauldron
class LetterBubbleWidget extends StatelessWidget {
  final LetterTile tile;
  final double size;
  final Color activeColor;

  const LetterBubbleWidget({
    super.key,
    required this.tile,
    this.size = 52.0,
    this.activeColor = AppColors.activeCyan,
  });

  @override
  Widget build(BuildContext context) {
    Color bubbleColor;
    Color borderColor;
    Color textColor;
    List<BoxShadow> boxShadow;
    double scale = 1.0;

    if (tile.isUsed) {
      final color = tile.solvedColor ?? AppColors.greenSolved;
      bubbleColor = color.withAlpha(90);
      borderColor = color;
      textColor = Colors.white;
      boxShadow = AppShadows.glow(color, blurRadius: 10, spreadRadius: 1);
    } else if (tile.isSelected) {
      bubbleColor = activeColor.withAlpha(140);
      borderColor = activeColor;
      textColor = Colors.white;
      scale = 1.15;
      boxShadow = AppShadows.glow(activeColor, blurRadius: 16, spreadRadius: 3);
    } else if (tile.isHinted) {
      bubbleColor = AppColors.bubbleGoldBg;
      borderColor = AppColors.goldAccent;
      textColor = AppColors.goldLight;
      scale = 1.08;
      boxShadow = AppShadows.glow(AppColors.goldAccent, blurRadius: 14, spreadRadius: 2);
    } else {
      bubbleColor = AppColors.usedTileBackground.withAlpha(190);
      borderColor = AppColors.bubbleTileBorder;
      textColor = AppColors.purpleLight;
      boxShadow = AppShadows.glow(AppColors.bubbleTileBorder, blurRadius: 8, spreadRadius: 1);
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
          gradient: AppGradients.bubbleTile(bubbleColor),
        ),
        child: Stack(
          children: [
            // Letter Text (only rendered if tile has a letter)
            if (tile.letter.isNotEmpty)
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
