import 'package:flutter/material.dart';
import '../data/levels_data.dart';
import '../services/score_manager.dart';
import '../theme/themes.dart';
import '../widgets/how_to_play_dialog.dart';
import 'game_screen.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  void _startCurrentLevel() async {
    final currentLevelId = ScoreManager().currentLevelId;
    final level = LevelsData.getLevel(currentLevelId);

    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(level: level),
      ),
    );

    // Refresh score and level status upon returning
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final totalScore = ScoreManager().totalScore;
    final highScore = ScoreManager().highScore;
    final completedCount = ScoreManager().completedLevelIds.length;
    final wordsSolved = ScoreManager().totalWordsSolved;
    final totalTimeFormatted = ScoreManager().formattedTotalTime;

    final currentLevelId = ScoreManager().currentLevelId;
    final currentLevel = LevelsData.getLevel(currentLevelId);
    final currentLevelColor =
        AppColors.linePalette[(currentLevelId - 1) % AppColors.linePalette.length];

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.sort_by_alpha_outlined, color: AppColors.goldAccent, size: 22),
            SizedBox(width: 8),
            Text(
              'Letters in the Myst',
              style: AppTextStyles.headerTitle,
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const HowToPlayDialog(),
              );
            },
            icon: const Icon(Icons.help_outline_rounded, color: AppColors.purpleLight),
            tooltip: 'How to play',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Score & Stats Header Card
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: AppGradients.headerBanner,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.purpleAccent),
                boxShadow: AppShadows.bannerShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.goldAccent.withAlpha(50),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.goldAccent),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.workspace_premium,
                                color: AppColors.goldAccent, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'TOTAL SCORE: $totalScore',
                              style: AppTextStyles.totalScoreBanner,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.containerDark,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.purpleBorder),
                        ),
                        child: Text(
                          'BEST: $highScore',
                          style: AppTextStyles.bestScoreBanner,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildHeaderStat('Completed', '$completedCount Levels'),
                      _buildHeaderStat('Words Solved', '$wordsSolved Words'),
                      _buildHeaderStat('Total Time', totalTimeFormatted),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Current Level Progress Hero Card
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: currentLevelColor.withAlpha(200),
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: currentLevelColor.withAlpha(60),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: currentLevelColor.withAlpha(50),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: currentLevelColor),
                        ),
                        child: Text(
                          'LEVEL $currentLevelId',
                          style: TextStyle(
                            color: currentLevelColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.purpleBorder.withAlpha(100),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          currentLevel.category,
                          style: AppTextStyles.levelCardNumber
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentLevel.name,
                    style: AppTextStyles.levelCardTitle
                  ),
                  const SizedBox(height: 6),
                  Text(
                    currentLevel.description,
                    style: AppTextStyles.levelCardSubtitle
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _startCurrentLevel,
                      icon: const Icon(Icons.play_arrow_rounded, size: 26),
                      label: Text(
                        'START LEVEL $currentLevelId',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentLevelColor,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 6,
                        shadowColor: currentLevelColor.withAlpha(160),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.statLabel,
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
