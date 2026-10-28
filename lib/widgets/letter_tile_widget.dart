import 'package:flutter/material.dart';
import '../models/letter_tile.dart';
import '../theme/app_theme.dart';

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
      bgColor = AppColors.tileSolvedBg;
      borderColor = AppColors.tileSolvedBorder;
      textColor = AppColors.tileSolvedText;
      boxShadow = [
        BoxShadow(
          color: AppColors.tileSolvedBorder.withAlpha(100),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ];
    } else if (tile.isSelected) {
      // Currently in guess tray / selected state
      bgColor = AppColors.tileSelectedBg;
      borderColor = AppColors.tileSelectedBorder;
      textColor = Colors.white70;
      boxShadow = [
        BoxShadow(
          color: AppColors.tileSelectedBorder.withAlpha(80),
          blurRadius: 6,
        ),
      ];
    } else if (tile.isHinted) {
      // Hinted state
      bgColor = AppColors.goldBgDark;
      borderColor = AppColors.gold;
      textColor = AppColors.goldLight;
      boxShadow = [
        BoxShadow(
          color: AppColors.gold.withAlpha(150),
          blurRadius: 12,
          spreadRadius: 2,
        ),
      ];
    } else {
      // Normal available state
      bgColor = AppColors.tileNormalBg;
      borderColor = AppColors.tileNormalBorder;
      textColor = AppColors.purpleLight;
      boxShadow = [
        BoxShadow(
          color: AppColors.tileNormalBorder.withAlpha(90),
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
          splashColor: AppColors.purpleBright.withAlpha(100),
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
