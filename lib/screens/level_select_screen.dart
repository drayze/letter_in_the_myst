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
  String? _selectedCategoryOverride;

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
    final completedCount = ScoreManager().completedLevelIds.length;
    final wordsSolved = ScoreManager().totalWordsSolved;
    final totalTimeFormatted = ScoreManager().formattedTotalTime;

    final currentLevelId = ScoreManager().currentLevelId;
    final currentLevel = LevelsData.getLevel(currentLevelId);

    // Determine active theme (user selected or default to current level theme)
    final String activeCategoryName =
        _selectedCategoryOverride ?? currentLevel.category;
    final CategoryTheme activeTheme =
        CategoryThemeData.getTheme(activeCategoryName);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: activeTheme.appBarBackground.withAlpha(220),
        elevation: 0,
        title: Row(
          children: [
            Icon(activeTheme.icon, color: activeTheme.primaryAccent, size: 22),
            const SizedBox(width: 8),
            const Text(
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
            icon: Icon(Icons.help_outline_rounded,
                color: activeTheme.secondaryAccent),
            tooltip: 'How to play',
          ),
        ],
      ),
      body: ThemeBackgroundWidget(
        theme: activeTheme,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Score & Stats Header Card
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: activeTheme.cardBackground.withAlpha(220),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: activeTheme.tileBorderColor),
                  boxShadow: [
                    BoxShadow(
                      color: activeTheme.primaryAccent.withAlpha(50),
                      blurRadius: 16,
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
                            color: activeTheme.primaryAccent.withAlpha(40),
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: activeTheme.primaryAccent),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.workspace_premium,
                                  color: activeTheme.primaryAccent, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'TOTAL SCORE: $totalScore',
                                style: TextStyle(
                                  color: activeTheme.highlightColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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

              // Theme Selector Section
              const Text(
                'THEMES & WORLDS',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 52,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: CategoryThemeData.allThemes.length,
                  itemBuilder: (context, index) {
                    final themeItem = CategoryThemeData.allThemes[index];
                    final isSelected =
                        themeItem.categoryName == activeTheme.categoryName;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategoryOverride = themeItem.categoryName;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? themeItem.primaryAccent
                              : themeItem.cardBackground.withAlpha(200),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? themeItem.highlightColor
                                : themeItem.tileBorderColor.withAlpha(150),
                            width: isSelected ? 2.0 : 1.0,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color:
                                        themeItem.primaryAccent.withAlpha(120),
                                    blurRadius: 10,
                                  )
                                ]
                              : [],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              themeItem.icon,
                              size: 18,
                              color: isSelected
                                  ? Colors.black87
                                  : themeItem.primaryAccent,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              themeItem.displayName,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.black87
                                    : Colors.white,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Current Level Progress Hero Card
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: activeTheme.cardBackground.withAlpha(230),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: activeTheme.primaryAccent.withAlpha(200),
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: activeTheme.primaryAccent.withAlpha(70),
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
                            color: activeTheme.primaryAccent.withAlpha(50),
                            borderRadius: BorderRadius.circular(10),
                            border:
                                Border.all(color: activeTheme.primaryAccent),
                          ),
                          child: Text(
                            'LEVEL $currentLevelId',
                            style: TextStyle(
                              color: activeTheme.primaryAccent,
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
                            color: activeTheme.tileBorderColor.withAlpha(100),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            currentLevel.category,
                            style: TextStyle(
                              color: activeTheme.secondaryAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentLevel.name,
                      style: AppTextStyles.levelCardTitle,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      currentLevel.description,
                      style: AppTextStyles.levelCardSubtitle,
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
                          backgroundColor: activeTheme.primaryAccent,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 6,
                          shadowColor: activeTheme.primaryAccent.withAlpha(160),
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
