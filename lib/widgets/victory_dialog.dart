import 'package:flutter/material.dart';
import '../models/level.dart';
import '../theme/themes.dart';

class VictoryDialog extends StatelessWidget {
  final Level level;
  final int levelScore;
  final int totalScore;
  final int timeInSeconds;
  final VoidCallback onNextLevel;
  final VoidCallback onReplay;
  final VoidCallback onLevelSelect;

  const VictoryDialog({
    super.key,
    required this.level,
    required this.levelScore,
    required this.totalScore,
    required this.timeInSeconds,
    required this.onNextLevel,
    required this.onReplay,
    required this.onLevelSelect,
  });

  @override
  Widget build(BuildContext context) {
    final String timeStr =
        '${(timeInSeconds ~/ 60).toString().padLeft(2, '0')}:${(timeInSeconds % 60).toString().padLeft(2, '0')}';

    return Dialog(
      backgroundColor: AppColors.scaffoldBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.mintAccent, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Victory Icon
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.greenSolvedDark.withAlpha(100),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.mintAccent, width: 2),
                boxShadow: AppShadows.glow(AppColors.mintAccent, blurRadius: 16),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AppColors.mintAccent,
                size: 36,
              ),
            ),
            const SizedBox(height: 12),

            const Text(
              'MYST SOLVED!',
              style: AppTextStyles.victoryTitle,
            ),
            const SizedBox(height: 4),

            Text(
              level.name,
              style: AppTextStyles.victoryLevelName,
            ),
            const SizedBox(height: 14),

            // Summary box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.darkPurpleBorder),
              ),
              child: Column(
                children: [
                  Text(
                    'All ${level.totalLetters} letters correctly solved into ${level.words.length} secret words!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                  const Divider(color: AppColors.containerDark, height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat('Time', timeStr, Icons.timer_outlined),
                      _buildStat('Level Score', '+$levelScore', Icons.stars_rounded),
                      _buildStat('Total Score', '$totalScore', Icons.workspace_premium),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Buttons
            Row(
              children: [
                IconButton.filledTonal(
                  onPressed: onReplay,
                  icon: const Icon(Icons.replay_rounded),
                  tooltip: 'Replay Level',
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.containerDark,
                    foregroundColor: AppColors.purpleLight,
                    padding: const EdgeInsets.all(10),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: onLevelSelect,
                  icon: const Icon(Icons.home),
                  tooltip: 'Return Home',
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.containerDark,
                    foregroundColor: AppColors.purpleLight,
                    padding: const EdgeInsets.all(10),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onNextLevel,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: const Text('NEXT LEVEL'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mintAccent,
                      foregroundColor: AppColors.greenDarkText,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.goldAccent),
            const SizedBox(width: 3),
            Text(
              label,
              style: AppTextStyles.statLabel,
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.statValue,
        ),
      ],
    );
  }
}
