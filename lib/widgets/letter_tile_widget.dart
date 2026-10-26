import 'package:flutter/material.dart';
import '../models/letter_tile.dart';
import '../theme/themes.dart';

class LetterTileWidget extends StatelessWidget {
  final LetterTile tile;
  final double size;
  final Color activeColor;

  const LetterTileWidget({
    super.key,
    required this.tile,
    this.size = 54.0,
    this.activeColor = AppColors.activeCyan,
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
      final tileColor = tile.solvedColor ?? AppColors.greenSolved;
      bgColor = tileColor.withAlpha(80);
      borderColor = tileColor;
      textColor = Colors.white;
      boxShadow = AppShadows.glow(tileColor, blurRadius: 10, spreadRadius: 1);
    } else if (tile.isSelected) {
      // Currently being highlighted by finger trace line!
      bgColor = activeColor.withAlpha(100);
      borderColor = activeColor;
      textColor = Colors.white;
      scale = 1.12;
      boxShadow = AppShadows.glow(activeColor, blurRadius: 14, spreadRadius: 2);
    } else if (tile.isHinted) {
      // Hinted
      bgColor = AppColors.goldDarkBg;
      borderColor = AppColors.goldAccent;
      textColor = AppColors.goldLight;
      scale = 1.05;
      boxShadow = AppShadows.glow(AppColors.goldAccent, blurRadius: 12, spreadRadius: 2);
    } else {
      // Idle Jumble tile
      bgColor = AppColors.idleTileBackground;
      borderColor = AppColors.idleTileBorder;
      textColor = AppColors.purpleLight;
      boxShadow = [
        BoxShadow(
          color: AppColors.darkPurpleBorder.withAlpha(100),
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
          gradient: AppGradients.tileGradient(bgColor),
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
