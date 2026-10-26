import 'package:flutter/material.dart';
import '../models/letter_tile.dart';
import '../theme/themes.dart';

class GuessTray extends StatelessWidget {
  final List<LetterTile> selectedTiles;
  final Function(LetterTile) onTileTap;
  final VoidCallback onSubmit;
  final VoidCallback onClear;
  final VoidCallback onShuffle;
  final VoidCallback onHint;
  final int hintsRemaining;
  final String? message;

  const GuessTray({
    super.key,
    required this.selectedTiles,
    required this.onTileTap,
    required this.onSubmit,
    required this.onClear,
    required this.onShuffle,
    required this.onHint,
    required this.hintsRemaining,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final bool canSubmit = selectedTiles.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withAlpha(220),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: canSubmit ? AppColors.purpleBright : AppColors.darkPurpleBorder,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.containerDark.withAlpha(150),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Feedback message or instructions
          if (message != null && message!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: AppTextStyles.hintMessage,
                child: Text(message!, textAlign: TextAlign.center),
              ),
            ),

          // Guess Tiles Area
          Container(
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: AppColors.scaffoldBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.containerDark),
            ),
            child: selectedTiles.isEmpty
                ? const Center(
                    child: Text(
                      'Tap letters below to unscramble a word',
                      style: AppTextStyles.emptyTrayPlaceholder,
                    ),
                  )
                : Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 6.0,
                    runSpacing: 6.0,
                    children: selectedTiles.map((tile) {
                      return GestureDetector(
                        onTap: () => onTileTap(tile),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            color: AppColors.purpleBorder,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.purpleBright),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.purpleBright.withAlpha(100),
                                blurRadius: 6,
                              )
                            ],
                          ),
                          child: Text(
                            tile.letter,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),

          const SizedBox(height: 12),

          // Action Buttons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Clear Button
              IconButton.filledTonal(
                onPressed: selectedTiles.isEmpty ? null : onClear,
                icon: const Icon(Icons.backspace_outlined),
                tooltip: 'Clear selection',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.containerDark,
                  foregroundColor: AppColors.purpleLight,
                  disabledBackgroundColor: AppColors.scaffoldBackground,
                  disabledForegroundColor: Colors.white24,
                ),
              ),

              // Shuffle Button
              IconButton.filledTonal(
                onPressed: onShuffle,
                icon: const Icon(Icons.shuffle_rounded),
                tooltip: 'Shuffle board',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.containerDark,
                  foregroundColor: AppColors.purpleLight,
                ),
              ),

              // Hint Button
              ElevatedButton.icon(
                onPressed: hintsRemaining > 0 ? onHint : null,
                icon: const Icon(Icons.lightbulb_outline_rounded, size: 18),
                label: Text('Hint ($hintsRemaining)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purpleAccent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.containerDark,
                  disabledForegroundColor: Colors.white24,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Submit Button
              ElevatedButton.icon(
                onPressed: canSubmit ? onSubmit : null,
                icon: const Icon(Icons.check_rounded, size: 20),
                label: const Text('SUBMIT'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mintAccent,
                  foregroundColor: AppColors.greenDarkText,
                  disabledBackgroundColor: AppColors.containerDark,
                  disabledForegroundColor: Colors.white24,
                  elevation: canSubmit ? 6 : 0,
                  shadowColor: AppColors.mintAccent.withAlpha(150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
