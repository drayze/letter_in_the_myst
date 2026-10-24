import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../data/levels_data.dart';
import '../models/letter_tile.dart';
import '../models/level.dart';
import '../widgets/how_to_play_dialog.dart';
import '../widgets/letter_tile_widget.dart';
import '../widgets/victory_dialog.dart';
import '../widgets/word_line_painter.dart';
import '../widgets/word_slot_widget.dart';

class GameScreen extends StatefulWidget {
  final Level level;

  const GameScreen({super.key, required this.level});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Level _currentLevel;
  late List<TargetWord> _targetWords;
  late List<LetterTile> _allTiles;
  late List<List<LetterTile?>> _grid;
  int _rows = 4;
  int _cols = 4;

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
    _initLevel(widget.level);
  }

  @override
  void dispose() {
    _timer?.cancel();
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

    // 1. Target Words
    _targetWords = level.words.map((w) => TargetWord(word: w)).toList();

    // 2. Determine grid size
    final totalChars = level.totalLetters;
    if (totalChars <= 16) {
      _rows = 4;
      _cols = 4;
    } else if (totalChars <= 20) {
      _rows = 5;
      _cols = 4;
    } else if (totalChars <= 25) {
      _rows = 5;
      _cols = 5;
    } else {
      _rows = 6;
      _cols = 5;
    }

    _grid = List.generate(_rows, (_) => List.generate(_cols, (_) => null));
    _allTiles = [];

    // 3. Place target words in a jumble matrix with snake paths
    final rand = Random();
    int tileCounter = 0;

    for (int wordIdx = 0; wordIdx < level.words.length; wordIdx++) {
      final word = level.words[wordIdx];
      bool placed = false;

      for (int attempt = 0; attempt < 100; attempt++) {
        final startR = rand.nextInt(_rows);
        final startC = rand.nextInt(_cols);

        if (_grid[startR][startC] != null) continue;

        final path = _findSnakePath(startR, startC, word.length);
        if (path != null && path.length == word.length) {
          // Place word along path
          for (int i = 0; i < word.length; i++) {
            final pt = path[i];
            final tile = LetterTile(
              id: 'tile_${tileCounter++}_${word[i]}',
              letter: word[i],
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

      // Fallback placement if random snake failed
      if (!placed) {
        for (int r = 0; r < _rows; r++) {
          for (int c = 0; c < _cols; c++) {
            if (_grid[r][c] == null && word.isNotEmpty) {
              final path = _findSnakePath(r, c, word.length);
              final actualPath = path ?? _findAnyOpenCells(r, c, word.length);
              for (int i = 0; i < actualPath.length; i++) {
                final pt = actualPath[i];
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

    // Fill remaining empty cells with fallback letters if needed
    for (int r = 0; r < _rows; r++) {
      for (int c = 0; c < _cols; c++) {
        if (_grid[r][c] == null) {
          final fallbackChar =
              level.words[rand.nextInt(level.words.length)][0];
          final tile = LetterTile(
            id: 'tile_${tileCounter++}_$fallbackChar',
            letter: fallbackChar,
            row: r,
            col: c,
          );
          _grid[r][c] = tile;
          _allTiles.add(tile);
        }
      }
    }

    // Start Timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && !_isLevelCompleted) {
        setState(() {
          _timeInSeconds++;
        });
      }
    });
  }

  List<Tuple2>? _findSnakePath(int startR, int startC, int length) {
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

  List<Tuple2> _findAnyOpenCells(int startR, int startC, int count) {
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

  // Touch Gesture Handling
  void _onPanStart(DragStartDetails details) {
    _updateTouchPosition(details.localPosition);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _updateTouchPosition(details.localPosition);
  }

  void _updateTouchPosition(Offset localPos) {
    setState(() {
      _currentTouchPoint = localPos;

      // Find tile near touch position
      LetterTile? touchedTile;
      double minDistance = 32.0; // Hit threshold radius

      for (var tile in _allTiles) {
        if (tile.centerPosition != null) {
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
          // Check for backtracking
          if (_selectedTiles.length > 1 &&
              _selectedTiles[_selectedTiles.length - 2] == touchedTile) {
            final removed = _selectedTiles.removeLast();
            removed.isSelected = false;
          } else if (!_selectedTiles.contains(touchedTile)) {
            // Check if touched tile is adjacent to last selected tile
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

    // Check if guess matches any unsolved target word
    TargetWord? matchedWord;
    for (var target in _targetWords) {
      if (!target.isSolved && target.word == guess) {
        matchedWord = target;
        break;
      }
    }

    setState(() {
      if (matchedWord != null) {
        // MATCH FOUND!
        matchedWord.isSolved = true;
        final color = _linePalette[_solvedLines.length % _linePalette.length];

        final linePoints = _selectedTiles
            .map((t) => t.centerPosition ?? Offset.zero)
            .toList();

        _solvedLines.add(
          SolvedWordLine(
            word: matchedWord.word,
            points: linePoints,
            color: color,
          ),
        );

        for (var tile in _selectedTiles) {
          tile.isUsed = true;
          tile.isSelected = false;
          tile.solvedColor = color;
        }

        _score += guess.length * 100;
        _feedbackMessage = '✨ Unscrambled "${matchedWord.word}"!';

        if (_targetWords.every((w) => w.isSolved)) {
          _handleLevelCompleted();
        }
      } else {
        final bool alreadySolved =
            _targetWords.any((w) => w.isSolved && w.word == guess);

        if (alreadySolved) {
          _feedbackMessage = 'Already found "$guess"!';
        } else if (guess.length >= 2) {
          _feedbackMessage = '"$guess" is not a secret word.';
        }

        for (var tile in _selectedTiles) {
          tile.isSelected = false;
        }
      }

      _selectedTiles.clear();
      _currentTouchPoint = null;
    });
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

    setState(() {
      _revealedIndices[unsolvedWordIdx]!.add(unrevealedCharIdx);
      if (hintTile != null) {
        hintTile.isHinted = true;
      }
      _hintsRemaining--;
      _feedbackMessage =
          'Hint: Word #${unsolvedWordIdx + 1} contains "$neededLetter"!';
    });
  }

  void _handleLevelCompleted() {
    _isLevelCompleted = true;
    _timer?.cancel();

    final timeBonus = (300 - _timeInSeconds).clamp(0, 300);
    final hintBonus = _hintsRemaining * 50;
    _score += timeBonus + hintBonus;

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => VictoryDialog(
          level: _currentLevel,
          score: _score,
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
    final int remainingLetters = _allTiles.where((t) => !t.isUsed).length;
    final currentWordText = _selectedTiles.map((t) => t.letter).join();

    return Scaffold(
      backgroundColor: const Color(0xFF10002B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF190933),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentLevel.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Draw a line across letters to solve',
              style: const TextStyle(
                color: Color(0xFFE0AAFF),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF240046),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF5A189A)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined,
                      color: Color(0xFFFFD700), size: 16),
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
                color: Color(0xFFE0AAFF)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Target Words Panel
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
              decoration: const BoxDecoration(
                color: Color(0xFF190933),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 4.0,
                runSpacing: 4.0,
                children: List.generate(_targetWords.length, (index) {
                  return WordSlotWidget(
                    targetWord: _targetWords[index],
                    revealedIndices: _revealedIndices[index] ?? {},
                  );
                }),
              ),
            ),

            const SizedBox(height: 8),

            // Level Stats & Hint Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Unsolved: $remainingLetters / ${_currentLevel.totalLetters}',
                    style: const TextStyle(
                      color: Color(0xFFE0AAFF),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _hintsRemaining > 0 ? _onHint : null,
                    icon: const Icon(Icons.lightbulb_outline_rounded, size: 16),
                    label: Text('Hint ($_hintsRemaining)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B2CBF),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF240046),
                      disabledForegroundColor: Colors.white24,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 6.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Text(
                    'Score: $_score',
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Active Traced Word Pill
            Container(
              height: 42,
              alignment: Alignment.center,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: currentWordText.isNotEmpty ? 1.0 : 0.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00F5D4),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00F5D4).withAlpha(160),
                        blurRadius: 12,
                      )
                    ],
                  ),
                  child: Text(
                    currentWordText,
                    style: const TextStyle(
                      color: Color(0xFF081C15),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
            ),

            if (_feedbackMessage != null && _feedbackMessage!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  _feedbackMessage!,
                  style: const TextStyle(
                    color: Color(0xFFFF9E00),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(height: 8),

            // Interactive Jumble Board with Drag & Line Drawing
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF140032).withAlpha(200),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF3C096C), width: 1.5),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final cellWidth = constraints.maxWidth / _cols;
                    final cellHeight = constraints.maxHeight / _rows;

                    // Calculate center position for each tile
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
                      onPanStart: _onPanStart,
                      onPanUpdate: _onPanUpdate,
                      onPanEnd: _onPanEnd,
                      child: Stack(
                        children: [
                          // Custom Painter rendering the glowing lines!
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

                          // Letter Tile Widgets positioned on the jumble grid
                          ..._allTiles.map((tile) {
                            final x = (tile.col + 0.5) * cellWidth - 27;
                            final y = (tile.row + 0.5) * cellHeight - 27;

                            return Positioned(
                              left: x,
                              top: y,
                              child: LetterTileWidget(
                                tile: tile,
                                size: 54.0,
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
