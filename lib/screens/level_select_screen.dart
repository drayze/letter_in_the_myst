import 'package:flutter/material.dart';
import '../data/levels_data.dart';
import '../models/level.dart';
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
  void _openLevel(Level level) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(level: level),
      ),
    );

    // Refresh score and level status upon returning
    setState(() {});
  }

  void _openRandomLevel() async {
    final nextId = LevelsData.levels.length + ScoreManager().completedLevelIds.length + 1;
    final randomLevel = LevelsData.getRandomLevel(nextId);
    _openLevel(randomLevel);
  }

  @override
  Widget build(BuildContext context) {
    final totalScore = ScoreManager().totalScore;
    final highScore = ScoreManager().highScore;
    final completedCount = ScoreManager().completedLevelIds.length;

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
      body: CustomScrollView(
        slivers: [
          // Total Score Banner & Controls Header
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16.0),
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
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHeaderStat('Completed', '$completedCount Levels'),
                      _buildHeaderStat('Words Solved', '${ScoreManager().totalWordsSolved} Words'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openRandomLevel,
                      icon: const Icon(Icons.play_arrow_rounded, size: 22),
                      label: const Text(
                        'PLAY RANDOM MYST PUZZLE',
                        style: AppTextStyles.buttonBold,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mintAccent,
                        foregroundColor: AppColors.greenDarkText,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Section Title
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Text(
                'Story Chapters',
                style: AppTextStyles.sectionTitle,
              ),
            ),
          ),

          // Grid of Levels
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                mainAxisExtent: 140,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final level = LevelsData.levels[index];
                  final isCompleted = ScoreManager().completedLevelIds.contains(level.id);
                  final bestScore = ScoreManager().getLevelBestScore(level.id);

                  return GestureDetector(
                    onTap: () => _openLevel(level),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.greenSolvedBg
                            : AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isCompleted
                              ? AppColors.greenSolved
                              : AppColors.darkPurpleBorder,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isCompleted
                                ? AppColors.greenSolved.withAlpha(60)
                                : AppColors.containerDark.withAlpha(100),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.purpleBorder.withAlpha(100),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Level ${level.id}',
                                  style: AppTextStyles.levelCardNumber,
                                ),
                              ),
                              if (isCompleted)
                                const Icon(
                                  Icons.check_circle,
                                  color: AppColors.mintAccent,
                                  size: 20,
                                )
                              else
                                const Icon(
                                  Icons.lock_open_rounded,
                                  color: Colors.white30,
                                  size: 18,
                                ),
                            ],
                          ),
                          Text(
                            level.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.levelCardTitle,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${level.words.length} secret words',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.levelCardSubtitle,
                                ),
                              ),
                              if (bestScore > 0)
                                Text(
                                  '$bestScore pts',
                                  style: AppTextStyles.levelCardScore,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: LevelsData.levels.length,
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
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
