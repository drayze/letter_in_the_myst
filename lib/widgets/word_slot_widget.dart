import 'package:flutter/material.dart';
import '../models/level.dart';
import '../theme/themes.dart';

class WordSlotWidget extends StatelessWidget {
  final int wordIndex;
  final TargetWord targetWord;
  final Map<String, GlobalKey> slotKeys;

  const WordSlotWidget({
    super.key,
    required this.wordIndex,
    required this.targetWord,
    required this.slotKeys,
  });

  @override
  Widget build(BuildContext context) {
    final isSolved = targetWord.isSolved;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 3.0),
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
      decoration: BoxDecoration(
        color: isSolved
            ? AppColors.greenSolvedBg.withAlpha(200)
            : AppColors.scaffoldBackground.withAlpha(160),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSolved ? AppColors.greenSolved : AppColors.darkPurpleBorder,
          width: isSolved ? 1.5 : 1.0,
        ),
        boxShadow: [
          if (isSolved)
            BoxShadow(
              color: AppColors.greenSolved.withAlpha(100),
              blurRadius: 6,
              spreadRadius: 1,
            ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(targetWord.word.length, (index) {
              final char = targetWord.word[index];
              final key = slotKeys['${wordIndex}_$index'];

              String displayChar = '';
              Color boxBgColor = AppColors.containerDark;
              Color boxBorderColor = AppColors.purpleBorder;
              Color charColor = AppColors.purpleLight;
              double fontSize = 14;

              if (isSolved) {
                displayChar = char;
                boxBgColor = AppColors.greenSolvedDark;
                boxBorderColor = AppColors.mintAccent;
                charColor = AppColors.greenLightText;
                fontSize = 14;
              } else if (index == 0) {
                displayChar = char;
                boxBgColor = AppColors.containerDark;
                boxBorderColor = AppColors.purpleBorder;
                charColor = AppColors.purpleLight;
                fontSize = 14;
              } else {
                displayChar = '•';
                boxBgColor = AppColors.containerDark;
                boxBorderColor = AppColors.purpleBorder;
                charColor = AppColors.purpleAccent;
                fontSize = 11;
              }

              return Container(
                key: key,
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: boxBgColor,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: boxBorderColor),
                ),
                child: Center(
                  child: Text(
                    displayChar,
                    style: TextStyle(
                      color: charColor,
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),
            if (isSolved) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.mintAccent,
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
