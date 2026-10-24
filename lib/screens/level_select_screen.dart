import 'package:flutter/material.dart';
import '../data/levels_data.dart';
import '../models/level.dart';
import '../services/score_manager.dart';
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
      backgroundColor: const Color(0xFF10002B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF190933),
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Color(0xFFFFD700), size: 22),
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
            icon: const Icon(Icons.help_outline_rounded, color: Color(0xFFE0AAFF)),
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
                gradient: const LinearGradient(
                  colors: [Color(0xFF3C096C), Color(0xFF5A189A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF7B2CBF)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5A189A).withAlpha(120),
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
                          color: const Color(0xFFFFD700).withAlpha(50),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFD700)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.workspace_premium,
                                color: Color(0xFFFFD700), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'TOTAL SCORE: $totalScore',
                              style: const TextStyle(
                                color: Color(0xFFFFD700),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF240046),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF5A189A)),
                        ),
                        child: Text(
                          'BEST: $highScore',
                          style: const TextStyle(
                            color: Color(0xFFE0AAFF),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
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
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF74C69D),
                        foregroundColor: const Color(0xFF081C15),
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
                style: TextStyle(
                  color: Color(0xFFE0AAFF),
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
                  final isCompleted = ScoreManager().completedLevelIds.contains(level.id);
                  final bestScore = ScoreManager().getLevelBestScore(level.id);

                  return GestureDetector(
                    onTap: () => _openLevel(level),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? const Color(0xFF1B4332)
                            : const Color(0xFF190933),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isCompleted
                              ? const Color(0xFF52B788)
                              : const Color(0xFF3C096C),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isCompleted
                                ? const Color(0xFF52B788).withAlpha(60)
                                : const Color(0xFF240046).withAlpha(100),
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
                                  color: const Color(0xFF5A189A).withAlpha(100),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Level ${level.id}',
                                  style: const TextStyle(
                                    color: Color(0xFFE0AAFF),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (isCompleted)
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF74C69D),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
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
                              if (bestScore > 0)
                                Text(
                                  '$bestScore pts',
                                  style: const TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
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

  Widget _buildHeaderStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
