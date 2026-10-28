import 'package:flutter/material.dart';
import '../models/level.dart';
import '../theme/app_theme.dart';

class VictoryDialog extends StatelessWidget {
  final Level level;
  final int score;
  final int timeInSeconds;
  final VoidCallback onNextLevel;
  final VoidCallback onReplay;
  final VoidCallback onLevelSelect;

  const VictoryDialog({
    super.key,
    required this.level,
    required this.score,
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
      backgroundColor: AppColors.bgDeep,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.emerald, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Victory Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.successContainer.withAlpha(100),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.emerald, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.emerald.withAlpha(150),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AppColors.emerald,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'MYST SOLVED!',
              style: TextStyle(
                color: AppColors.successLight,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 6),

            Text(
              level.name,
              style: const TextStyle(
                color: AppColors.purpleLight,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            // Summary box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.purpleDark),
              ),
              child: Column(
                children: [
                  Text(
                    'All ${level.totalLetters} letters correctly unscrambled into ${level.words.length} secret words!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                  const Divider(color: AppColors.surfaceDark, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat('Time', timeStr, Icons.timer_outlined),
                      _buildStat('Score', '$score', Icons.stars_rounded),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                IconButton.filledTonal(
                  onPressed: onReplay,
                  icon: const Icon(Icons.replay_rounded),
                  tooltip: 'Replay Level',
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surfaceDark,
                    foregroundColor: AppColors.purpleLight,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: onLevelSelect,
                  icon: const Icon(Icons.grid_view_rounded),
                  tooltip: 'Level Select',
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surfaceDark,
                    foregroundColor: AppColors.purpleLight,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onNextLevel,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text('NEXT LEVEL'),
                    style: AppTheme.emeraldButtonStyle,
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
            Icon(icon, size: 16, color: AppColors.gold),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
