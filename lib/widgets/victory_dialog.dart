import 'package:flutter/material.dart';
import '../models/level.dart';

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
      backgroundColor: const Color(0xFF10002B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFF74C69D), width: 2),
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
                color: const Color(0xFF2D6A4F).withAlpha(100),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF74C69D), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF74C69D).withAlpha(150),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Color(0xFF74C69D),
                size: 36,
              ),
            ),
            const SizedBox(height: 12),

            const Text(
              'MYST SOLVED!',
              style: TextStyle(
                color: Color(0xFFD8F3DC),
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),

            Text(
              level.name,
              style: const TextStyle(
                color: Color(0xFFE0AAFF),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 14),

            // Summary box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF190933),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF3C096C)),
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
                  const Divider(color: Color(0xFF240046), height: 18),
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
                    backgroundColor: const Color(0xFF240046),
                    foregroundColor: const Color(0xFFE0AAFF),
                    padding: const EdgeInsets.all(10),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: onLevelSelect,
                  icon: const Icon(Icons.grid_view_rounded),
                  tooltip: 'Level Select',
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF240046),
                    foregroundColor: const Color(0xFFE0AAFF),
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
                      backgroundColor: const Color(0xFF74C69D),
                      foregroundColor: const Color(0xFF081C15),
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
            Icon(icon, size: 14, color: const Color(0xFFFFD700)),
            const SizedBox(width: 3),
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
