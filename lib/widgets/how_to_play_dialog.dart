import 'package:flutter/material.dart';
import '../theme/themes.dart';

class HowToPlayDialog extends StatelessWidget {
  const HowToPlayDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.scaffoldBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.purpleAccent, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                 Icon( Icons.play_arrow_outlined,
                  color: AppColors.goldAccent,
                  size: 28,
                ),
                const SizedBox(width: 10),
                const Text(
                  'How To Play',
                  style: AppTextStyles.dialogTitle,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white54),
                )
              ],
            ),
            const Divider(color: AppColors.darkPurpleBorder, height: 24),
            _buildRuleItem(
              icon: Icons.gesture,
              color: AppColors.activeCyan,
              title: 'Trace Circular Wheel',
              description:
                  'Drag your finger across letters on the circular wheel. A glowing colored line will trace your word!',
            ),
            const SizedBox(height: 16),
            _buildRuleItem(
              icon: Icons.all_inclusive,
              color: AppColors.purpleLight,
              title: '100% Target Letters',
              description:
                  'Every single letter on the wheel belongs to one of the secret words needed to solve the puzzle.',
            ),
            const SizedBox(height: 16),
            _buildRuleItem(
              icon: Icons.lightbulb,
              color: AppColors.goldAccent,
              title: 'Need a Hint?',
              description:
                  'Tap the Hint button to reveal a letter slot in one of the hidden words.',
            ),
            const SizedBox(height: 16),
            _buildRuleItem(
              icon: Icons.workspace_premium,
              color: AppColors.mintAccent,
              title: 'Complete the Myst',
              description:
                  'Solve all secret words to unlock the power of your mind and deep relaxation.',
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purpleAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'GOT IT! LET\'S PLAY',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleItem({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(40),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withAlpha(100)),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
