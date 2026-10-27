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
  final GlobalKey _statsAreaKey = GlobalKey();

  late AnimationController _flightController;
  final List<FlyingTileData> _activeFlyingTiles = [];

  String? _displayedSolvedWord;
  Timer? _displayTimer;

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
      duration: const Duration(milliseconds: 500),
    );
    _flightController.addListener(() {
      setState(() {});
    });

    _initLevel(widget.level);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _displayTimer?.cancel();
    _flightController.dispose();
    super.dispose();
  }

  void _initLevel(Level level) {
    _timer?.cancel();
    _displayTimer?.cancel();
    _flightController.reset();
    _activeFlyingTiles.clear();
    _displayedSolvedWord = null;

    _currentLevel = level;
    _isLevelCompleted = false;
    _timeInSeconds = 0;
    _score = 0;
    _hintsRemaining = 3;
    _feedbackMessage = null;
    _selectedTiles.clear();
    _solvedLines.clear();
    _revealedIndices.clear();

    // 1. Target Words & Word Queue setup
    _targetWords = level.words.map((w) => TargetWord(word: w)).toList();

    _activeBoardWords = [];
    _wordQueue = [];

    // Fit words up to max total letters on board; queue remaining words for dynamic replenishment
    int accumulatedLetters = 0;
    const maxActiveBoardLetters = 45;

    for (var target in _targetWords) {
      if (accumulatedLetters + target.word.length <= maxActiveBoardLetters ||
          _activeBoardWords.isEmpty) {
        _activeBoardWords.add(target);
        accumulatedLetters += target.word.length;
      } else {
        _wordQueue.add(target);
      }
    }

    // 2. Build 2D grid matrix for active board words
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
        // Fallback: Fill open grid slots
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

      if (_boardWidth > 0 && _boardHeight > 0) {
        final cellW = _boardWidth / _cols;
        final cellH = _boardHeight / _rows;
        tile.centerPosition = Offset(
          (c + 0.5) * cellW,
          (r + 0.5) * cellH,
        );
      }

      _grid[r][c] = tile;
      _allTiles.add(tile);
    }
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

  // Touch & Gesture Handling
  void _onPanDown(DragDownDetails details) {
    _updateTouchPosition(details.localPosition);
  }

  void _onPanStart(DragStartDetails details) {
    _updateTouchPosition(details.localPosition);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _updateTouchPosition(details.localPosition);
  }

  void _updateTouchPosition(Offset localPos) {
    setState(() {
      _currentTouchPoint = localPos;

      if (_boardWidth > 0 && _boardHeight > 0) {
        final cellW = _boardWidth / _cols;
        final cellH = _boardHeight / _rows;
        for (var tile in _allTiles) {
          tile.centerPosition ??= Offset(
            (tile.col + 0.5) * cellW,
            (tile.row + 0.5) * cellH,
          );
        }
      }

      LetterTile? touchedTile;
      double minDistance = max(_currentTileSize * 0.95, 36.0);

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
      final statsCenter = _getStatsAreaCenterInScreen();
      final double spacing = min(32.0, _boardWidth / (guess.length + 2));
      final double startX = statsCenter.dx - ((guess.length - 1) * spacing / 2);

      for (int i = 0; i < _selectedTiles.length; i++) {
        final tile = _selectedTiles[i];
        final startPos = _getWheelTileCenterInScreen(tile) ?? Offset.zero;
        final targetPos = Offset(startX + (i * spacing), statsCenter.dy);

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
        _displayTimer?.cancel();
        setState(() {
          matchedWord.isSolved = true;
          _activeFlyingTiles.clear();
          _displayedSolvedWord = matchedWord.word;

          _displayTimer = Timer(const Duration(milliseconds: 1500), () {
            if (mounted) {
              setState(() {
                _displayedSolvedWord = null;
              });
            }
          });

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

    if (wheelContext != null &&
        screenContext != null &&
        tile.centerPosition != null) {
      final RenderBox wheelBox = wheelContext.findRenderObject() as RenderBox;
      final RenderBox screenBox =
          screenContext.findRenderObject() as RenderBox;
      final Offset wheelPosInScreen =
          wheelBox.localToGlobal(Offset.zero, ancestor: screenBox);
      return wheelPosInScreen + tile.centerPosition!;
    }
    return tile.centerPosition;
  }

  Offset _getStatsAreaCenterInScreen() {
    final statsContext = _statsAreaKey.currentContext;
    final screenContext = _screenStackKey.currentContext;

    if (statsContext != null && screenContext != null) {
      final RenderBox statsBox = statsContext.findRenderObject() as RenderBox;
      final RenderBox screenBox =
          screenContext.findRenderObject() as RenderBox;
      final Offset statsPos =
          statsBox.localToGlobal(Offset.zero, ancestor: screenBox);
      return statsPos +
          Offset(statsBox.size.width / 2, statsBox.size.height / 2);
    }
    return const Offset(200, 80);
  }

  void _onHint() {
    if (_hintsRemaining <= 0) return;

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
    for (int c = 0; c < target.word.length; c++) {
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
          'Hint (-$hintCost pts): Secret word contains "$neededLetter"!';
    });
  }

  void _handleLevelCompleted() async {
    _timer?.cancel();
    _isLevelCompleted = true;

    await ScoreManager().recordLevelCompletion(
      levelId: _currentLevel.id,
      levelScore: _score,
      wordsSolvedCount: _targetWords.length,
    );

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => VictoryDialog(
        level: _currentLevel,
        levelScore: _score,
        totalScore: ScoreManager().totalScore,
        timeInSeconds: _timeInSeconds,
        onNextLevel: () {
          Navigator.pop(dialogContext);
          _loadNextLevel();
        },
        onReplay: () {
          Navigator.pop(dialogContext);
          _initLevel(_currentLevel);
        },
        onLevelSelect: () {
          Navigator.pop(dialogContext);
          Navigator.pop(context);
        },
      ),
    );
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
    final currentWordText = _selectedTiles.map((t) => t.letter).join();
    final solvedCount = _targetWords.where((w) => w.isSolved).length;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Stack(
          key: _screenStackKey,
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                // 25% TOP STATUS & CONTROL BAR
                Expanded(
                  flex: 25,
                  child: Container(
                    key: _statsAreaKey,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.purpleBorder.withAlpha(150),
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Row 1: Level, Timer, Score, Help
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.purpleAccent.withAlpha(80),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color:
                                          AppColors.purpleAccent.withAlpha(120),
                                    ),
                                  ),
                                  child: Text(
                                    'Lvl ${_currentLevel.id}: ${_currentLevel.name}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                Row(
                                  children: [
                                    const Icon(
                                      Icons.timer_outlined,
                                      color: AppColors.goldAccent,
                                      size: 15,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${(_timeInSeconds ~/ 60).toString().padLeft(2, '0')}:${(_timeInSeconds % 60).toString().padLeft(2, '0')}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),

                                Text(
                                  'Score: $_score',
                                  style: const TextStyle(
                                    color: AppColors.goldAccent,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          const HowToPlayDialog(),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.help_outline_rounded,
                                    color: AppColors.purpleLight,
                                    size: 20,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),

                            // Row 2: Words to find, Solved, Queued, Shuffle, Hint
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'To Find: ${_targetWords.length}',
                                      style: const TextStyle(
                                        color: AppColors.purpleLight,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Solved: $solvedCount',
                                      style: const TextStyle(
                                        color: AppColors.mintAccent,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.purpleBorder
                                            .withAlpha(150),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Queued: ${_wordQueue.length}',
                                        style: const TextStyle(
                                          color: AppColors.goldAccent,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: _shuffleWheel,
                                      icon: const Icon(
                                        Icons.shuffle_rounded,
                                        color: AppColors.activeCyan,
                                        size: 19,
                                      ),
                                      tooltip: 'Shuffle Grid',
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 10),
                                    ElevatedButton.icon(
                                      onPressed:
                                          _hintsRemaining > 0 ? _onHint : null,
                                      icon: const Icon(
                                        Icons.lightbulb_outline_rounded,
                                        size: 13,
                                      ),
                                      label: Text(
                                        'Hint ($_hintsRemaining)',
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.purpleAccent,
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor:
                                            AppColors.containerDark,
                                        disabledForegroundColor: Colors.white24,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 3.0),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Solved Word Popup Banner in Stats Panel
                        if (_displayedSolvedWord != null)
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _displayedSolvedWord != null ? 1.0 : 0.0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.greenSolved
                                    .withAlpha(240),
                                borderRadius: BorderRadius.circular(16),
                                border:
                                    Border.all(color: AppColors.greenLightText, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.activeCyan
                                        .withAlpha(200),
                                    blurRadius: 18,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.stars_rounded,
                                      color: AppColors.greenLightText, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    '✨ $_displayedSolvedWord ✨',
                                    style: const TextStyle(
                                      color: AppColors.greenLightText,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2.0,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black54,
                                          blurRadius: 4,
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // 75% MAIN GAME BOARD AREA
                Expanded(
                  flex: 75,
                  child: Column(
                    children: [
                      // Active Traced Word Banner / Feedback Message
                      if (currentWordText.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18.0, vertical: 6.0),
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
                      ],

                      if (_feedbackMessage != null &&
                          _feedbackMessage!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          _feedbackMessage!,
                          style: AppTextStyles.warningMessage,
                        ),
                      ],

                      const SizedBox(height: 4),

                      // Full 2D Grid Board
                      Expanded(
                        child: Container(
                          key: _wheelKey,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 6.0),
                          decoration: BoxDecoration(
                            color: AppColors.boardBackground.withAlpha(200),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.purpleBorder.withAlpha(120),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.darkPurpleBorder.withAlpha(100),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                _boardWidth = constraints.maxWidth;
                                _boardHeight = constraints.maxHeight;

                                final cellWidth = _boardWidth / _cols;
                                final cellHeight = _boardHeight / _rows;

                                _currentTileSize =
                                    min(cellWidth, cellHeight) * 0.72;

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
                                  onPanDown: _onPanDown,
                                  onPanStart: _onPanStart,
                                  onPanUpdate: _onPanUpdate,
                                  onPanEnd: _onPanEnd,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned.fill(
                                        child: CustomPaint(
                                          painter: WordLinePainter(
                                            solvedLines: _solvedLines,
                                            currentDragPoints: dragPoints,
                                            currentTouchPoint:
                                                _currentTouchPoint,
                                            activeColor: AppColors.activeCyan,
                                          ),
                                        ),
                                      ),
                                      ..._allTiles
                                          .where((t) => !t.isUsed)
                                          .map((tile) {
                                        final pos = tile.centerPosition ??
                                            Offset(_boardWidth / 2,
                                                _boardHeight / 2);
                                        final x =
                                            pos.dx - (_currentTileSize / 2);
                                        final y =
                                            pos.dy - (_currentTileSize / 2);

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
                ),
              ],
            ),

            // Layer 2: Flying Tile Animations Overlay
            ..._activeFlyingTiles.map((fTile) {
              return FlyingTileWidget(
                data: fTile,
                progress:
                    Curves.easeInOutCubic.transform(_flightController.value),
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
