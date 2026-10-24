import 'package:flutter/material.dart';

class HowToPlayDialog extends StatelessWidget {
  const HowToPlayDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF10002B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFF7B2CBF), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFFFFD700),
                  size: 28,
                ),
                const SizedBox(width: 10),
                const Text(
                  'How To Play',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white54),
                )
              ],
            ),
            const Divider(color: Color(0xFF3C096C), height: 24),
            _buildRuleItem(
              icon: Icons.grid_view_rounded,
              color: const Color(0xFFE0AAFF),
              title: 'Every Letter Counts!',
              description:
                  'All the letters displayed on screen belong to one of the secret words. There are no junk or filler letters!',
            ),
            const SizedBox(height: 16),
            _buildRuleItem(
              icon: Icons.spellcheck,
              color: const Color(0xFF74C69D),
              title: 'Form Hidden Words',
              description:
                  'Tap letters from the scramble pool to form a word, then press SUBMIT to uncover it.',
            ),
            const SizedBox(height: 16),
            _buildRuleItem(
              icon: Icons.lightbulb,
              color: const Color(0xFFFFD700),
              title: 'Use Hints & Shuffles',
              description:
                  'Stuck? Tap Shuffle to reorganize the letter pool or use a Hint to reveal a letter slot!',
            ),
            const SizedBox(height: 16),
            _buildRuleItem(
              icon: Icons.workspace_premium,
              color: const Color(0xFFFF9E00),
              title: 'Complete the Myst',
              description:
                  'When all target words are solved, 100% of the visible letter tiles will be consumed and the puzzle is solved!',
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B2CBF),
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
