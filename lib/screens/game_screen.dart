import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../data/levels_data.dart';
import '../models/letter_tile.dart';
import '../models/level.dart';
import '../services/score_manager.dart';
import '../widgets/bubble_tile_widget.dart';
import '../widgets/cauldron_frame_widget.dart';
import '../widgets/flying_tile_widget.dart';
import '../widgets/how_to_play_dialog.dart';
import '../widgets/victory_dialog.dart';
import '../widgets/word_line_painter.dart';
import '../widgets/word_slot_widget.dart';

class GameScreen extends StatefulWidget {
  final Level level;

  const GameScreen({super.key, required this.level});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late Level _currentLevel;
  late List<TargetWord> _targetWords;
  late List<LetterTile> _allTiles;

  final GlobalKey _screenStackKey = GlobalKey();
  final GlobalKey _wheelKey = GlobalKey();
  final Map<String, GlobalKey> _slotKeys = {};

  late AnimationController _flightController;
  final List<FlyingTileData> _activeFlyingTiles = [];

  double _boardWidth = 0.0;
  double _boardHeight = 0.0;
  double _currentTileSize = 52.0;

  final List<LetterTile> _selectedTiles = [];
  final List<SolvedWordLine> _solvedLines = [];
  final Map<int, Set<int>> _revealedIndices = {};

  Offset? _currentTouchPoint;
  int _hintsRemaining = 3;
  int _score = 0;
  int _timeInSeconds = 0;
  Timer? _timer;
  String? _feedbackMessage;
  bool _isLevelCompleted = false;

  final List<Color> _linePalette = const [
    Color(0xFF00F5D4), // Cyan
    Color(0xFFFF007F), // Neon Pink
    Color(0xFFFFB703), // Amber
    Color(0xFF9D4EDD), // Purple
    Color(0xFF74C69D), // Mint
    Color(0xFF3A86FF), // Blue
  ];

  @override
  void initState() {
    super.initState();
    _flightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _flightController.addListener(() {
      setState(() {});
    });

    _initLevel(widget.level);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _flightController.dispose();
    super.dispose();
  }

  void _initLevel(Level level) {
    _timer?.cancel();
    _currentLevel = level;
    _isLevelCompleted = false;
    _timeInSeconds = 0;
    _score = 0;
    _hintsRemaining = 3;
    _feedbackMessage = null;
    _selectedTiles.clear();
    _solvedLines.clear();
    _revealedIndices.clear();
    _activeFlyingTiles.clear();
    _slotKeys.clear();

    // 1. Target Words
    _targetWords = level.words.map((w) => TargetWord(word: w)).toList();

    for (int wIdx = 0; wIdx < level.words.length; wIdx++) {
      final word = level.words[wIdx];
      for (int cIdx = 0; cIdx < word.length; cIdx++) {
        _slotKeys['${wIdx}_$cIdx'] = GlobalKey();
      }
    }

    // 2. Build letter tiles keeping letters of each word strictly contiguous
    _allTiles = _buildContiguousWordTiles(_targetWords);

    // Start Timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && !_isLevelCompleted) {
        setState(() {
          _timeInSeconds++;
        });
      }
    });
  }

  List<LetterTile> _buildContiguousWordTiles(List<TargetWord> targetWords) {
    final List<LetterTile> result = [];
    int tileCounter = 0;

    final unsolved = targetWords.where((w) => !w.isSolved).toList();
    unsolved.shuffle(Random());

    final rand = Random();

    for (int i = 0; i < unsolved.length; i++) {
      final target = unsolved[i];
      final String word = target.word;

      // 50% chance to reverse letter flow direction
      final chars = rand.nextBool()
          ? word.split('')
          : word.split('').reversed.toList();

      // Add all letters of this word sequentially (strictly contiguous!)
      for (int charIdx = 0; charIdx < chars.length; charIdx++) {
        result.add(
          LetterTile(
            id: 'tile_${tileCounter++}_${chars[charIdx]}',
            letter: chars[charIdx],
          ),
        );
      }

      // Intersperse 1 empty bubble between words
      result.add(
        LetterTile(
          id: 'empty_bubble_${tileCounter++}',
          letter: '', // Empty letter bubble!
        ),
      );
    }

    return result;
  }

  void _shuffleWheel() {
    setState(() {
      for (var t in _selectedTiles) {
        t.isSelected = false;
      }
      _selectedTiles.clear();

      final reorderedTiles = _buildContiguousWordTiles(_targetWords);

      int newIdx = 0;
      for (int i = 0; i < _allTiles.length; i++) {
        if (!_allTiles[i].isUsed && newIdx < reorderedTiles.length) {
          _allTiles[i] = reorderedTiles[newIdx++];
        }
      }

      _feedbackMessage = 'Cauldron stirred!';
    });
  }

  // Touch & Gesture Line Drawing
  void _onPanStart(DragStartDetails details) {
    if (_flightController.isAnimating) return;
    _updateTouchPosition(details.localPosition);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_flightController.isAnimating) return;
    _updateTouchPosition(details.localPosition);
  }

  void _updateTouchPosition(Offset localPos) {
    setState(() {
      _currentTouchPoint = localPos;

      LetterTile? touchedTile;
      double minDistance = 38.0;

      for (var tile in _allTiles) {
        if (!tile.isUsed && tile.centerPosition != null) {
          final dist = (tile.centerPosition! - localPos).distance;
          if (dist < minDistance) {
            minDistance = dist;
            touchedTile = tile;
          }
        }
      }

      // Ignore empty bubbles when building words
      if (touchedTile != null &&
          !touchedTile.isUsed &&
          touchedTile.letter.isNotEmpty) {
        if (_selectedTiles.isEmpty) {
          _selectedTiles.add(touchedTile);
          touchedTile.isSelected = true;
          _feedbackMessage = null;
        } else {
          if (_selectedTiles.length > 1 &&
              _selectedTiles[_selectedTiles.length - 2] == touchedTile) {
            final removed = _selectedTiles.removeLast();
            removed.isSelected = false;
          } else if (!_selectedTiles.contains(touchedTile)) {
            _selectedTiles.add(touchedTile);
            touchedTile.isSelected = true;
          }
        }
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_selectedTiles.isEmpty) return;

    final guess = _selectedTiles.map((t) => t.letter).join();

    int matchedWordIdx = -1;
    for (int i = 0; i < _targetWords.length; i++) {
      if (!_targetWords[i].isSolved && _targetWords[i].word == guess) {
        matchedWordIdx = i;
        break;
      }
    }

    if (matchedWordIdx != -1) {
      final matchedWord = _targetWords[matchedWordIdx];
      final color = _linePalette[_solvedLines.length % _linePalette.length];

      _activeFlyingTiles.clear();

      for (int i = 0; i < _selectedTiles.length; i++) {
        final tile = _selectedTiles[i];
        final startPos = _getWheelTileCenterInScreen(tile) ?? Offset.zero;
        final targetPos = _getSlotBoxCenterInScreen(matchedWordIdx, i) ?? startPos;

        _activeFlyingTiles.add(
          FlyingTileData(
            letter: tile.letter,
            startPos: startPos,
            endPos: targetPos,
            color: color,
          ),
        );

        tile.isUsed = true;
        tile.isSelected = false;
        tile.solvedColor = color;
      }

      _score += guess.length * 100;
      _feedbackMessage = '✨ Solved "${matchedWord.word}"!';
      _selectedTiles.clear();
      _currentTouchPoint = null;

      _flightController.forward(from: 0.0).then((_) {
        setState(() {
          matchedWord.isSolved = true;
          _activeFlyingTiles.clear();

          if (_targetWords.every((w) => w.isSolved)) {
            _handleLevelCompleted();
          }
        });
      });
    } else {
      final bool alreadySolved =
          _targetWords.any((w) => w.isSolved && w.word == guess);

      setState(() {
        if (alreadySolved) {
          _feedbackMessage = 'Already found "$guess"!';
        } else if (guess.length >= 2) {
          _feedbackMessage = '"$guess" is not a secret word.';
        }

        for (var tile in _selectedTiles) {
          tile.isSelected = false;
        }

        _selectedTiles.clear();
        _currentTouchPoint = null;
      });
    }
  }

  Offset? _getWheelTileCenterInScreen(LetterTile tile) {
    final wheelContext = _wheelKey.currentContext;
    final screenContext = _screenStackKey.currentContext;

    if (wheelContext != null && screenContext != null && tile.centerPosition != null) {
      final RenderBox wheelBox = wheelContext.findRenderObject() as RenderBox;
      final RenderBox screenBox = screenContext.findRenderObject() as RenderBox;
      final Offset wheelPosInScreen =
          wheelBox.localToGlobal(Offset.zero, ancestor: screenBox);
      return wheelPosInScreen + tile.centerPosition!;
    }
    return tile.centerPosition;
  }

  Offset? _getSlotBoxCenterInScreen(int wordIdx, int charIdx) {
    final key = _slotKeys['${wordIdx}_$charIdx'];
    final context = key?.currentContext;
    final screenContext = _screenStackKey.currentContext;

    if (context != null && screenContext != null) {
      final RenderBox box = context.findRenderObject() as RenderBox;
      final RenderBox screenBox = screenContext.findRenderObject() as RenderBox;
      final Offset globalBoxPos =
          box.localToGlobal(Offset.zero, ancestor: screenBox);
      return globalBoxPos + Offset(box.size.width / 2, box.size.height / 2);
    }
    return null;
  }

  void _onHint() {
    if (_hintsRemaining <= 0 || _flightController.isAnimating) return;

    int unsolvedWordIdx = -1;
    for (int i = 0; i < _targetWords.length; i++) {
      if (!_targetWords[i].isSolved) {
        unsolvedWordIdx = i;
        break;
      }
    }

    if (unsolvedWordIdx == -1) return;

    final target = _targetWords[unsolvedWordIdx];
    _revealedIndices.putIfAbsent(unsolvedWordIdx, () => {});

    int unrevealedCharIdx = -1;
    for (int c = 0; c < target.length; c++) {
      if (!_revealedIndices[unsolvedWordIdx]!.contains(c)) {
        unrevealedCharIdx = c;
        break;
      }
    }

    if (unrevealedCharIdx == -1) return;

    final neededLetter = target.word[unrevealedCharIdx];

    LetterTile? hintTile;
    for (var tile in _allTiles) {
      if (!tile.isUsed && tile.letter == neededLetter) {
        hintTile = tile;
        break;
      }
    }

    const int hintCost = 25;

    setState(() {
      _revealedIndices[unsolvedWordIdx]!.add(unrevealedCharIdx);
      if (hintTile != null) {
        hintTile.isHinted = true;
      }
      _hintsRemaining--;
      _score = (_score - hintCost).clamp(0, 999999);
      _feedbackMessage =
          'Hint (-$hintCost pts): Word #${unsolvedWordIdx + 1} contains "$neededLetter"!';
    });
  }

  void _handleLevelCompleted() async {
    _isLevelCompleted = true;
    _timer?.cancel();

    final timeBonus = (300 - _timeInSeconds).clamp(0, 300);
    final hintBonus = _hintsRemaining * 50;
    _score += timeBonus + hintBonus;

    await ScoreManager().recordLevelCompletion(
      levelId: _currentLevel.id,
      levelScore: _score,
      wordsSolvedCount: _targetWords.length,
    );

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => VictoryDialog(
          level: _currentLevel,
          levelScore: _score,
          totalScore: ScoreManager().totalScore,
          timeInSeconds: _timeInSeconds,
          onNextLevel: () {
            Navigator.pop(context);
            _loadNextLevel();
          },
          onReplay: () {
            Navigator.pop(context);
            setState(() {
              _initLevel(_currentLevel);
            });
          },
          onLevelSelect: () {
            Navigator.pop(context);
            Navigator.pop(context, true);
          },
        ),
      );
    });
  }

  void _loadNextLevel() {
    Level nextLevel;
    if (_currentLevel.id < LevelsData.levels.length) {
      nextLevel = LevelsData.levels[_currentLevel.id];
    } else {
      nextLevel = LevelsData.getRandomLevel(_currentLevel.id + 1);
    }

    setState(() {
      _initLevel(nextLevel);
    });
  }

  @override
  Widget build(BuildContext context) {
    final int remainingLetters =
        _allTiles.where((t) => !t.isUsed && t.letter.isNotEmpty).length;
    final currentWordText = _selectedTiles.map((t) => t.letter).join();
    final accumulatedTotal = ScoreManager().totalScore + _score;

    return Scaffold(
      backgroundColor: const Color(0xFF10002B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF190933),
        elevation: 0,
        title: Text(
          _currentLevel.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF240046),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF5A189A)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_outlined,
                    color: Color(0xFFFFD700), size: 14),
                const SizedBox(width: 4),
                Text(
                  '${(_timeInSeconds ~/ 60).toString().padLeft(2, '0')}:${(_timeInSeconds % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const HowToPlayDialog(),
              );
            },
            icon: const Icon(Icons.help_outline_rounded,
                color: Color(0xFFE0AAFF), size: 22),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          key: _screenStackKey,
          clipBehavior: Clip.none,
          children: [
            // Layer 1: Main Game UI Column
            Column(
              children: [
                // Target Secret Words Panel
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 6.0),
                  decoration: const BoxDecoration(
                    color: Color(0xFF190933),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 2.0,
                    runSpacing: 2.0,
                    children: List.generate(_targetWords.length, (index) {
                      return WordSlotWidget(
                        wordIndex: index,
                        targetWord: _targetWords[index],
                        revealedIndices: _revealedIndices[index] ?? {},
                        slotKeys: _slotKeys,
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 6),

                // Stats & Controls Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Unsolved: $remainingLetters',
                        style: const TextStyle(
                          color: Color(0xFFE0AAFF),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _shuffleWheel,
                            icon: const Icon(Icons.rotate_right_rounded,
                                color: Color(0xFFE0AAFF), size: 20),
                            tooltip: 'Stir Cauldron',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: _hintsRemaining > 0 ? _onHint : null,
                            icon: const Icon(Icons.lightbulb_outline_rounded,
                                size: 14),
                            label: Text('Hint ($_hintsRemaining)'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7B2CBF),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color(0xFF240046),
                              disabledForegroundColor: Colors.white24,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 4.0),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Level: $_score pts',
                            style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Total: $accumulatedTotal pts',
                            style: const TextStyle(
                              color: Color(0xFF74C69D),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                // Active Traced Word Floating Banner
                SizedBox(
                  height: 38,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: currentWordText.isNotEmpty ? 1.0 : 0.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00F5D4),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00F5D4).withAlpha(140),
                            blurRadius: 10,
                          )
                        ],
                      ),
                      child: Text(
                        currentWordText,
                        style: const TextStyle(
                          color: Color(0xFF081C15),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),

                if (_feedbackMessage != null && _feedbackMessage!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text(
                      _feedbackMessage!,
                      style: const TextStyle(
                        color: Color(0xFFFF9E00),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                const SizedBox(height: 4),

                // Cauldron Board Area
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 14.0, vertical: 8.0),
                    child: CauldronFrameWidget(
                      child: Container(
                        key: _wheelKey,
                        padding: const EdgeInsets.all(8.0),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            _boardWidth = constraints.maxWidth;
                            _boardHeight = constraints.maxHeight;

                            final center =
                                Offset(_boardWidth / 2, _boardHeight / 2);
                            final minDim = min(_boardWidth, _boardHeight);

                            _currentTileSize =
                                (minDim * 0.16).clamp(42.0, 58.0);

                            final activeTiles =
                                _allTiles.where((t) => !t.isUsed).toList();
                            final totalActive = activeTiles.length;

                            if (totalActive <= 12) {
                              final double radius = minDim * 0.36;
                              for (int i = 0; i < totalActive; i++) {
                                final angle =
                                    (2 * pi * i / totalActive) - (pi / 2);
                                activeTiles[i].centerPosition = Offset(
                                  center.dx + radius * cos(angle),
                                  center.dy + radius * sin(angle),
                                );
                              }
                            } else {
                              final int outerCount =
                                  (totalActive * 0.65).ceil();
                              final int innerCount = totalActive - outerCount;

                              final double outerRadius = minDim * 0.38;
                              final double innerRadius = minDim * 0.22;

                              for (int i = 0; i < outerCount; i++) {
                                final angle =
                                    (2 * pi * i / outerCount) - (pi / 2);
                                activeTiles[i].centerPosition = Offset(
                                  center.dx + outerRadius * cos(angle),
                                  center.dy + outerRadius * sin(angle),
                                );
                              }

                              for (int i = 0; i < innerCount; i++) {
                                final angle = (2 * pi * i / innerCount) -
                                    (pi / 2) +
                                    (pi / innerCount);
                                activeTiles[outerCount + i].centerPosition =
                                    Offset(
                                  center.dx + innerRadius * cos(angle),
                                  center.dy + innerRadius * sin(angle),
                                );
                              }
                            }

                            final dragPoints = _selectedTiles
                                .map((t) => t.centerPosition ?? Offset.zero)
                                .toList();

                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onPanStart: _onPanStart,
                              onPanUpdate: _onPanUpdate,
                              onPanEnd: _onPanEnd,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  // Orbit Ring Line Background
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: OrbitRingPainter(
                                        center: center,
                                        radius: minDim * 0.36,
                                      ),
                                    ),
                                  ),

                                  // Glowing Drag Line Painter
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: WordLinePainter(
                                        solvedLines: _solvedLines,
                                        currentDragPoints: dragPoints,
                                        currentTouchPoint: _currentTouchPoint,
                                        activeColor: const Color(0xFF00F5D4),
                                      ),
                                    ),
                                  ),

                                  // Bubbles (Letter Bubbles & Empty Bubbles!)
                                  ..._allTiles
                                      .where((t) => !t.isUsed)
                                      .map((tile) {
                                    final pos = tile.centerPosition ?? center;
                                    final x = pos.dx - (_currentTileSize / 2);
                                    final y = pos.dy - (_currentTileSize / 2);

                                    return Positioned(
                                      left: x,
                                      top: y,
                                      child: LetterBubbleWidget(
                                        tile: tile,
                                        size: _currentTileSize,
                                        activeColor: const Color(0xFF00F5D4),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Layer 2: Topmost Screen Overlay for Flying Tile Animations!
            ..._activeFlyingTiles.map((fTile) {
              return FlyingTileWidget(
                data: fTile,
                progress: Curves.easeInOutCubic
                    .transform(_flightController.value),
                initialSize: _currentTileSize,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class OrbitRingPainter extends CustomPainter {
  final Offset center;
  final double radius;

  OrbitRingPainter({required this.center, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3C096C).withAlpha(120)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant OrbitRingPainter oldDelegate) {
    return oldDelegate.center != center || oldDelegate.radius != radius;
  }
}
