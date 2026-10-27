import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../data/levels_data.dart';
import '../models/letter_tile.dart';
import '../models/level.dart';
import '../services/score_manager.dart';
import '../theme/themes.dart';
import '../widgets/bubble_tile_widget.dart';
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
  late List<TargetWord> _activeBoardWords;
  late List<TargetWord> _wordQueue;
  late List<LetterTile> _allTiles;
  late List<List<LetterTile?>> _grid;

  int _rows = 10;
  int _cols = 10;

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

  final List<Color> _linePalette = AppColors.linePalette;

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

    // 1. Target Words & Word Queue setup
    _targetWords = level.words.map((w) => TargetWord(word: w)).toList();

    for (int wIdx = 0; wIdx < level.words.length; wIdx++) {
      final word = level.words[wIdx];
      for (int cIdx = 0; cIdx < word.length; cIdx++) {
        _slotKeys['${wIdx}_$cIdx'] = GlobalKey();
      }
    }

    _activeBoardWords = [];
    _wordQueue = [];

    // Fit words up to ~16 total letters on board; queue remaining words for dynamic replenishment
    int accumulatedLetters = 0;
    const maxActiveBoardLetters = 22;

    for (var target in _targetWords) {
      if (accumulatedLetters + target.word.length <= maxActiveBoardLetters ||
          _activeBoardWords.isEmpty) {
        _activeBoardWords.add(target);
        accumulatedLetters += target.word.length;
      } else {
        _wordQueue.add(target);
      }
    }

    // 2. Build spacious 2D grid matrix for active board words
    _buildSpaciousGrid();

    // Start Timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && !_isLevelCompleted) {
        setState(() {
          _timeInSeconds++;
        });
      }
    });
  }

  void _buildSpaciousGrid() {
    final activeUnsolved = _activeBoardWords.where((w) => !w.isSolved).toList();
    final totalLettersNeeded =
        activeUnsolved.fold(0, (sum, w) => sum + w.word.length);

    if (totalLettersNeeded <= 12) {
      _rows = 4;
      _cols = 3;
    } else if (totalLettersNeeded <= 16) {
      _rows = 4;
      _cols = 4;
    } else if (totalLettersNeeded <= 20) {
      _rows = 5;
      _cols = 4;
    } else if (totalLettersNeeded <= 25) {
      _rows = 5;
      _cols = 5;
    } else {
      _rows = 6;
      _cols = 5;
    }

    _grid = List.generate(_rows, (_) => List.generate(_cols, (_) => null));
    _allTiles = [];

    int tileCounter = 0;
    final rand = Random();

    activeUnsolved.shuffle(rand);

    // Place target words along contiguous adjacent slots in grid
    for (var target in activeUnsolved) {
      final String word = target.word;
      bool placed = false;

      for (int attempt = 0; attempt < 100; attempt++) {
        final startR = rand.nextInt(_rows);
        final startC = rand.nextInt(_cols);

        if (_grid[startR][startC] != null) continue;

        final path = _findGridSnakePath(startR, startC, word.length);
        if (path != null && path.length == word.length) {
          final chars = rand.nextBool()
              ? word.split('')
              : word.split('').reversed.toList();

          for (int i = 0; i < chars.length; i++) {
            final pt = path[i];
            final tile = LetterTile(
              id: 'tile_${tileCounter++}_${chars[i]}',
              letter: chars[i],
              row: pt.item1,
              col: pt.item2,
            );
            _grid[pt.item1][pt.item2] = tile;
            _allTiles.add(tile);
          }
          placed = true;
          break;
        }
      }

      if (!placed) {
        // Fallback: Fill open adjacent grid slots
        for (int r = 0; r < _rows; r++) {
          for (int c = 0; c < _cols; c++) {
            if (_grid[r][c] == null) {
              final path = _findOpenGridSlots(r, c, word.length);
              for (int i = 0; i < path.length; i++) {
                final pt = path[i];
                if (i < word.length) {
                  final tile = LetterTile(
                    id: 'tile_${tileCounter++}_${word[i]}',
                    letter: word[i],
                    row: pt.item1,
                    col: pt.item2,
                  );
                  _grid[pt.item1][pt.item2] = tile;
                  _allTiles.add(tile);
                }
              }
              placed = true;
              break;
            }
          }
          if (placed) break;
        }
      }
    }
  }

  void _replenishWordFromQueue() {
    if (_wordQueue.isEmpty) return;

    final TargetWord nextTarget = _wordQueue.removeAt(0);
    _activeBoardWords.add(nextTarget);

    final String word = nextTarget.word;
    final rand = Random();

    List<Tuple2>? path;
    for (int attempt = 0; attempt < 50; attempt++) {
      final startR = rand.nextInt(_rows);
      final startC = rand.nextInt(_cols);
      if (_isSlotOpenForReplenishment(startR, startC)) {
        path = _findOpenReplenishmentPath(startR, startC, word.length);
        if (path != null && path.length == word.length) break;
      }
    }

    path ??= _findAllOpenReplenishmentSlots(word.length);

    final chars = rand.nextBool()
        ? word.split('')
        : word.split('').reversed.toList();

    int tileCounter = _allTiles.length;
    for (int i = 0; i < path.length && i < chars.length; i++) {
      final pt = path[i];
      final r = pt.item1;
      final c = pt.item2;

      final tile = LetterTile(
        id: 'tile_${tileCounter++}_${chars[i]}',
        letter: chars[i],
        row: r,
        col: c,
      );

      _grid[r][c] = tile;
      _allTiles.add(tile);
    }

    //_feedbackMessage = '✨ Summoned "${nextTarget.word}" into the grid!';
  }

  bool _isSlotOpenForReplenishment(int r, int c) {
    final existing = _grid[r][c];
    return existing == null || existing.isUsed;
  }

  List<Tuple2>? _findOpenReplenishmentPath(int startR, int startC, int length) {
    final List<Tuple2> path = [Tuple2(startR, startC)];
    final Set<String> visited = {'$startR,$startC'};
    final rand = Random();

    final dirs = [
      const Tuple2(-1, 0),
      const Tuple2(1, 0),
      const Tuple2(0, -1),
      const Tuple2(0, 1),
      const Tuple2(-1, -1),
      const Tuple2(-1, 1),
      const Tuple2(1, -1),
      const Tuple2(1, 1),
    ];

    bool dfs(int currR, int currC) {
      if (path.length == length) return true;

      dirs.shuffle(rand);
      for (var d in dirs) {
        final nr = currR + d.item1;
        final nc = currC + d.item2;

        if (nr >= 0 &&
            nr < _rows &&
            nc >= 0 &&
            nc < _cols &&
            _isSlotOpenForReplenishment(nr, nc) &&
            !visited.contains('$nr,$nc')) {
          visited.add('$nr,$nc');
          path.add(Tuple2(nr, nc));

          if (dfs(nr, nc)) return true;

          path.removeLast();
          visited.remove('$nr,$nc');
        }
      }
      return false;
    }

    if (dfs(startR, startC)) return path;
    return null;
  }

  List<Tuple2> _findAllOpenReplenishmentSlots(int count) {
    final List<Tuple2> result = [];
    for (int r = 0; r < _rows; r++) {
      for (int c = 0; c < _cols; c++) {
        if (_isSlotOpenForReplenishment(r, c)) {
          result.add(Tuple2(r, c));
          if (result.length == count) return result;
        }
      }
    }
    return result;
  }

  List<Tuple2>? _findGridSnakePath(int startR, int startC, int length) {
    final List<Tuple2> path = [Tuple2(startR, startC)];
    final Set<String> visited = {'$startR,$startC'};
    final rand = Random();

    final dirs = [
      const Tuple2(-1, 0),
      const Tuple2(1, 0),
      const Tuple2(0, -1),
      const Tuple2(0, 1),
      const Tuple2(-1, -1),
      const Tuple2(-1, 1),
      const Tuple2(1, -1),
      const Tuple2(1, 1),
    ];

    bool dfs(int currR, int currC) {
      if (path.length == length) return true;

      dirs.shuffle(rand);
      for (var d in dirs) {
        final nr = currR + d.item1;
        final nc = currC + d.item2;

        if (nr >= 0 &&
            nr < _rows &&
            nc >= 0 &&
            nc < _cols &&
            _grid[nr][nc] == null &&
            !visited.contains('$nr,$nc')) {
          visited.add('$nr,$nc');
          path.add(Tuple2(nr, nc));

          if (dfs(nr, nc)) return true;

          path.removeLast();
          visited.remove('$nr,$nc');
        }
      }
      return false;
    }

    if (dfs(startR, startC)) return path;
    return null;
  }

  List<Tuple2> _findOpenGridSlots(int startR, int startC, int count) {
    final List<Tuple2> result = [];
    for (int r = 0; r < _rows; r++) {
      for (int c = 0; c < _cols; c++) {
        if (_grid[r][c] == null) {
          result.add(Tuple2(r, c));
          if (result.length == count) return result;
        }
      }
    }
    return result;
  }

  void _shuffleWheel() {
    setState(() {
      for (var t in _selectedTiles) {
        t.isSelected = false;
      }
      _selectedTiles.clear();

      _buildSpaciousGrid();
      _feedbackMessage = 'Grid rearranged!';
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
      double minDistance = _currentTileSize * 0.85;

      for (var tile in _allTiles) {
        if (!tile.isUsed && tile.centerPosition != null) {
          final dist = (tile.centerPosition! - localPos).distance;
          if (dist < minDistance) {
            minDistance = dist;
            touchedTile = tile;
          }
        }
      }

      if (touchedTile != null && !touchedTile.isUsed) {
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
            // Check grid adjacency
            final last = _selectedTiles.last;
            final isAdjacent = (touchedTile.row - last.row).abs() <= 1 &&
                (touchedTile.col - last.col).abs() <= 1;

            if (isAdjacent) {
              _selectedTiles.add(touchedTile);
              touchedTile.isSelected = true;
            }
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

          // Replenish next word from queue if available!
          if (_wordQueue.isNotEmpty) {
            _replenishWordFromQueue();
          }

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
        _allTiles.where((t) => !t.isUsed).length;
    final currentWordText = _selectedTiles.map((t) => t.letter).join();
    final accumulatedTotal = ScoreManager().totalScore + _score;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        elevation: 0,
        title: Text(
          _currentLevel.name,
          style: AppTextStyles.appBarTitle,
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: AppColors.containerDark,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.purpleBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_outlined,
                    color: AppColors.goldAccent, size: 14),
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
                color: AppColors.purpleLight, size: 22),
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
                // Target Secret Words Panel (Answer Tray - MAX 28% of screen height)
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.28,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 6.0, horizontal: 6.0),
                    decoration: const BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
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
                  ),
                ),

                const SizedBox(height: 6),

                // Stats & Controls Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Unsolved: $remainingLetters',
                            style: const TextStyle(
                              color: AppColors.purpleLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_wordQueue.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.purpleBorder.withAlpha(150),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Queue: ${_wordQueue.length}',
                                style: const TextStyle(
                                  color: AppColors.goldAccent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _shuffleWheel,
                            icon: const Icon(Icons.shuffle_rounded,
                                color: AppColors.purpleLight, size: 20),
                            tooltip: 'Rearrange Grid',
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
                              backgroundColor: AppColors.purpleAccent,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: AppColors.containerDark,
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
                              color: AppColors.goldAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Total: $accumulatedTotal pts',
                            style: const TextStyle(
                              color: AppColors.mintAccent,
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
                        color: AppColors.activeCyan,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.activeCyan.withAlpha(140),
                            blurRadius: 10,
                          )
                        ],
                      ),
                      child: Text(
                        currentWordText,
                        style: AppTextStyles.activeWordBanner,
                      ),
                    ),
                  ),
                ),

                if (_feedbackMessage != null && _feedbackMessage!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text(
                      _feedbackMessage!,
                      style: AppTextStyles.warningMessage,
                    ),
                  ),

                const SizedBox(height: 4),

                // Spacious 2D Grid Board Area
                Expanded(
                  child: Container(
                    key: _wheelKey,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 14.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: AppColors.boardBackground.withAlpha(200),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                          color: AppColors.purpleBorder.withAlpha(120),
                          width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.darkPurpleBorder.withAlpha(100),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          _boardWidth = constraints.maxWidth;
                          _boardHeight = constraints.maxHeight;

                          final cellWidth = _boardWidth / _cols;
                          final cellHeight = _boardHeight / _rows;

                          // Tile size set to 68% of cell size so bubbles DO NOT touch each other!
                          _currentTileSize =
                              min(cellWidth, cellHeight) * 0.68;

                          // Position each bubble centered inside its grid cell
                          for (int r = 0; r < _rows; r++) {
                            for (int c = 0; c < _cols; c++) {
                              final tile = _grid[r][c];
                              if (tile != null) {
                                tile.centerPosition = Offset(
                                  (c + 0.5) * cellWidth,
                                  (r + 0.5) * cellHeight,
                                );
                              }
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
                                // Glowing Line Drag Painter
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: WordLinePainter(
                                      solvedLines: _solvedLines,
                                      currentDragPoints: dragPoints,
                                      currentTouchPoint: _currentTouchPoint,
                                      activeColor: AppColors.activeCyan,
                                    ),
                                  ),
                                ),

                                // Spacious Grid Bubbles (No Touching!)
                                ..._allTiles
                                    .where((t) => !t.isUsed)
                                    .map((tile) {
                                  final pos = tile.centerPosition ??
                                      Offset(_boardWidth / 2, _boardHeight / 2);
                                  final x = pos.dx - (_currentTileSize / 2);
                                  final y = pos.dy - (_currentTileSize / 2);

                                  return Positioned(
                                    left: x,
                                    top: y,
                                    child: LetterBubbleWidget(
                                      tile: tile,
                                      size: _currentTileSize,
                                      activeColor: AppColors.activeCyan,
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

class Tuple2 {
  final int item1;
  final int item2;
  const Tuple2(this.item1, this.item2);
}
