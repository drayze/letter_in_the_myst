import 'package:flutter/material.dart';
import '../models/level.dart';
import '../theme/app_theme.dart';

class WordSlotWidget extends StatelessWidget {
  final TargetWord targetWord;
  final Set<int> revealedIndices; // letter indices revealed by hint

  const WordSlotWidget({
    super.key,
    required this.targetWord,
    required this.revealedIndices,
  });

  @override
  Widget build(BuildContext context) {
    final isSolved = targetWord.isSolved;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: isSolved
            ? AppColors.successBg.withAlpha(200)
            : AppColors.bgDeep.withAlpha(160),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSolved ? AppColors.successBorder : AppColors.purpleDark,
          width: isSolved ? 2.0 : 1.0,
        ),
        boxShadow: [
          if (isSolved)
            BoxShadow(
              color: AppColors.successBorder.withAlpha(100),
              blurRadius: 10,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...List.generate(targetWord.word.length, (index) {
            final char = targetWord.word[index];
            final isRevealedByHint = revealedIndices.contains(index);

            String displayChar = '';
            Color boxBgColor = AppColors.surfaceDark;
            Color boxBorderColor = AppColors.purplePrimary;
            Color charColor = AppColors.purpleLight;

            if (isSolved) {
              displayChar = char;
              boxBgColor = AppColors.successContainer;
              boxBorderColor = AppColors.emerald;
              charColor = AppColors.successLight;
            } else if (isRevealedByHint) {
              displayChar = char;
              boxBgColor = AppColors.goldBgMedium;
              boxBorderColor = AppColors.gold;
              charColor = AppColors.goldLight;
            } else {
              displayChar = '•'; // Mystery bullet point
              charColor = AppColors.purpleAccent;
            }

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3.0),
              width: 34,
              height: 38,
              decoration: BoxDecoration(
                color: boxBgColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: boxBorderColor),
              ),
              child: Center(
                child: Text(
                  displayChar,
                  style: TextStyle(
                    color: charColor,
                    fontSize: isSolved || isRevealedByHint ? 18 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
          if (isSolved) ...[
            const SizedBox(width: 8),
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.emerald,
              size: 20,
            ),
          ],
        ],
      ),
    );
  }
}
