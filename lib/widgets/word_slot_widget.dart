import 'package:flutter/material.dart';
import '../models/level.dart';

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
            ? const Color(0xFF1B4332).withAlpha(200)
            : const Color(0xFF10002B).withAlpha(160),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSolved ? const Color(0xFF52B788) : const Color(0xFF3C096C),
          width: isSolved ? 2.0 : 1.0,
        ),
        boxShadow: [
          if (isSolved)
            BoxShadow(
              color: const Color(0xFF52B788).withAlpha(100),
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
              displayChar = '•'; // Mystery bullet point
              charColor = const Color(0xFF7B2CBF);
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
              color: Color(0xFF74C69D),
              size: 20,
            ),
          ],
        ],
      ),
    );
  }
}
