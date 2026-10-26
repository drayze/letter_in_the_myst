import 'package:flutter/material.dart';
import '../models/level.dart';

class WordSlotWidget extends StatelessWidget {
  final int wordIndex;
  final TargetWord targetWord;
  final Set<int> revealedIndices;
  final Map<String, GlobalKey> slotKeys;

  const WordSlotWidget({
    super.key,
    required this.wordIndex,
    required this.targetWord,
    required this.revealedIndices,
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
            ? const Color(0xFF1B4332).withAlpha(200)
            : const Color(0xFF10002B).withAlpha(160),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSolved ? const Color(0xFF52B788) : const Color(0xFF3C096C),
          width: isSolved ? 1.5 : 1.0,
        ),
        boxShadow: [
          if (isSolved)
            BoxShadow(
              color: const Color(0xFF52B788).withAlpha(100),
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
              final isRevealedByHint = revealedIndices.contains(index);
              final key = slotKeys['${wordIndex}_$index'];

              String displayChar = '';
              Color boxBgColor = const Color(0xFF240046);
              Color boxBorderColor = const Color(0xFF5A189A);
              Color charColor = const Color(0xFFE0AAFF);

              if (isSolved) {
                displayChar = char;
                boxBgColor = const Color(0xFF2D6A4F);
                boxBorderColor = const Color(0xFF74C69D);
                charColor = const Color(0xFFD8F3DC);
              } else if (isRevealedByHint) {
                displayChar = char;
                boxBgColor = const Color(0xFF5C4000);
                boxBorderColor = const Color(0xFFFFD700);
                charColor = const Color(0xFFFFE57F);
              } else {
                displayChar = '•';
                charColor = const Color(0xFF7B2CBF);
              }

              return Container(
                key: key,
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                width: 26,
                height: 28,
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
                      fontSize: isSolved || isRevealedByHint ? 14 : 11,
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
                color: Color(0xFF74C69D),
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
