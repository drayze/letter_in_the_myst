import 'package:flutter/material.dart';
import '../data/levels_data.dart';
import '../models/level.dart';
import '../theme/app_theme.dart';
import '../widgets/how_to_play_dialog.dart';
import 'game_screen.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  final Set<int> _completedLevelIds = {};

  void _openLevel(Level level) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(level: level),
      ),
    );

    if (result == true) {
      setState(() {
        _completedLevelIds.add(level.id);
      });
    }
  }

  void _openRandomLevel() async {
    final nextId = LevelsData.levels.length + _completedLevelIds.length + 1;
    final randomLevel = LevelsData.getRandomLevel(nextId);
    _openLevel(randomLevel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: AppColors.gold, size: 22),
            SizedBox(width: 8),
            Text(
              'Letters in the Myst',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
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
          // Banner / Endless mode header
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(20.0),
              decoration: AppTheme.bannerDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: AppTheme.badgeDecoration(color: AppColors.gold),
                        child: const Row(
                          children: [
                            Icon(Icons.all_inclusive,
                                color: AppColors.gold, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'ENDLESS MYST',
                              style: TextStyle(
                                color: AppColors.gold,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => const HowToPlayDialog(),
                          );
                        },
                        icon: const Icon(Icons.info_outline, color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Unscramble Hidden Puzzles',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Every single letter shown on screen is part of one of the secret words. Find them all to clear the myst!',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openRandomLevel,
                      icon: const Icon(Icons.play_arrow_rounded, size: 22),
                      label: const Text(
                        'PLAY RANDOM MYST PUZZLE',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: AppTheme.emeraldButtonStyle,
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
                style: TextStyle(
                  color: AppColors.purpleLight,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
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
                  final isCompleted = _completedLevelIds.contains(level.id);

                  return GestureDetector(
                    onTap: () => _openLevel(level),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.successBg
                            : AppColors.bgSurface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isCompleted
                              ? AppColors.successBorder
                              : AppColors.purpleDark,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isCompleted
                                ? AppColors.successBorder.withAlpha(60)
                                : AppColors.surfaceDark.withAlpha(100),
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
                                  color: AppColors.purplePrimary.withAlpha(100),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Level ${level.id}',
                                  style: const TextStyle(
                                    color: AppColors.purpleLight,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (isCompleted)
                                const Icon(
                                  Icons.check_circle,
                                  color: AppColors.emerald,
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.segment_rounded,
                                color: AppColors.amber,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${level.words.length} secret words',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 12,
                                  ),
                                ),
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
}
