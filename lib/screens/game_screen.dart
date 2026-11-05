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

class QueuedWordEntry {
  final int wordIndex;
  final String word;
  final List<String> remainingLetters;

  QueuedWordEntry({
    required this.wordIndex,
    required this.word,
    required this.remainingLetters,
  });
}

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
  late List<QueuedWordEntry> _queuedWordEntries;
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

  Offset? _currentTouchPoint;
  int _score = 0;
  int _timeInSeconds = 0;
  Timer? _timer;
  Timer? _feedbackTimer;
  String? _feedbackMessage;
  bool _isLevelCompleted = false;

  Color get _activeLineColor {
    final theme = CategoryThemeData.getTheme(_currentLevel.category);
    return theme.activeLineColor;
  }

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
    _feedbackTimer?.cancel();
    _flightController.dispose();
    super.dispose();
  }

  void _setFeedbackMessage(String message) {
    _feedbackTimer?.cancel();
    setState(() {
      _feedbackMessage = message;
    });
    _feedbackTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _feedbackMessage = null;
        });
      }
    });
  }

  void _clearFeedbackMessage() {
    _feedbackTimer?.cancel();
    _feedbackTimer = null;
    if (_feedbackMessage != null) {
      setState(() {
        _feedbackMessage = null;
      });
    }
  }

  void _initLevel(Level level) {
    _timer?.cancel();
    _feedbackTimer?.cancel();
    _feedbackTimer = null;
    _currentLevel = level;
    _isLevelCompleted = false;
    _timeInSeconds = 0;
    _score = 0;
    _feedbackMessage = null;
    _selectedTiles.clear();
    _activeFlyingTiles.clear();
    _slotKeys.clear();

    // 1. Target Words setup
    _targetWords = level.words.map((w) => TargetWord(word: w)).toList();

    for (int wIdx = 0; wIdx < level.words.length; wIdx++) {
      final word = level.words[wIdx];
      for (int cIdx = 0; cIdx < word.length; cIdx++) {
        _slotKeys['${wIdx}_$cIdx'] = GlobalKey();
      }
    }

    // 2. Queue remaining letters for all target words
    _queuedWordEntries = [];
    for (int i = 0; i < level.words.length; i++) {
      final word = level.words[i];
      _queuedWordEntries.add(
        QueuedWordEntry(
          wordIndex: i,
          word: word,
          remainingLetters: word.split(''),
        ),
      );
    }

    // 3. Populate initial tiles on wheel up to capacity (max 14 letters)
    _allTiles = [];
    _replenishWheel();

    // Start Timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && !_isLevelCompleted) {
        setState(() {
          _timeInSeconds++;
        });
      }
    });
  }

  void _replenishWheel() {
    const int maxActiveBoardLetters = 14;
    final activeUnusedCount = _allTiles.where((t) => !t.isUsed).length;
    int availableSlots = maxActiveBoardLetters - activeUnusedCount;

    if (availableSlots <= 0) return;

    final List<String> newLetters = [];

    for (var entry in _queuedWordEntries) {
      if (availableSlots <= 0) break;
      if (entry.remainingLetters.isEmpty) continue;

      final int takeCount = min(availableSlots, entry.remainingLetters.length);
      for (int k = 0; k < takeCount; k++) {
        newLetters.add(entry.remainingLetters.removeAt(0));
      }
      availableSlots -= takeCount;
    }

    if (newLetters.isEmpty) return;

    final rand = Random();
    int tileCounter = _allTiles.length;
    for (var letter in newLetters) {
      _allTiles.add(
        LetterTile(
          id: 'tile_${tileCounter++}_$letter',
          letter: letter,
        ),
      );
    }

    // Intermix active unused tiles on the wheel
    final unusedTiles = _allTiles.where((t) => !t.isUsed).toList();
    unusedTiles.shuffle(rand);
    final usedTiles = _allTiles.where((t) => t.isUsed).toList();
    _allTiles = [...usedTiles, ...unusedTiles];

    _arrangeTilesOnCircle();
  }

  void _arrangeTilesOnCircle() {
    if (_boardWidth <= 0 || _boardHeight <= 0) return;

    final activeTiles = _allTiles.where((t) => !t.isUsed).toList();
    final int count = activeTiles.length;
    if (count == 0) return;

    final double size = min(_boardWidth, _boardHeight);
    final double centerX = _boardWidth / 2;
    final double centerY = _boardHeight / 2;
    final double radius = (size / 2) * 0.68;

    if (count > 1) {
      _currentTileSize = min(
        54.0,
        max(38.0, (2 * pi * radius / (count + 1.2))),
      );
    } else {
      _currentTileSize = 52.0;
    }

    final double step = (2 * pi) / count;
    final double startAngle = -pi / 2;

    for (int i = 0; i < count; i++) {
      final double angle = startAngle + i * step;
      final double x = centerX + radius * cos(angle);
      final double y = centerY + radius * sin(angle);
      activeTiles[i].centerPosition = Offset(x, y);
    }
  }

  void _shuffleWheel() {
    _clearFeedbackMessage();
    setState(() {
      for (var tile in _selectedTiles) {
        tile.isSelected = false;
      }
      _selectedTiles.clear();
      _currentTouchPoint = null;

      final unusedTiles = _allTiles.where((t) => !t.isUsed).toList();
      if (unusedTiles.length <= 1) return;

      unusedTiles.shuffle();
      final usedTiles = _allTiles.where((t) => t.isUsed).toList();
      _allTiles = [...usedTiles, ...unusedTiles];

      _arrangeTilesOnCircle();
    });
  }

  LetterTile? _getTileAtPosition(Offset localPos) {
    for (var tile in _allTiles) {
      if (tile.isUsed) continue;
      final tileCenter = tile.centerPosition;
      if (tileCenter == null) continue;

      final distance = (localPos - tileCenter).distance;
      if (distance <= _currentTileSize * 0.65) {
        return tile;
      }
    }
    return null;
  }

  void _onPanDown(DragDownDetails details) {
    _clearFeedbackMessage();
    final RenderBox? box =
        _wheelKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final localPos = box.globalToLocal(details.globalPosition);
    final tile = _getTileAtPosition(localPos);

    if (tile != null && !tile.isSelected) {
      setState(() {
        tile.isSelected = true;
        _selectedTiles.add(tile);
        _currentTouchPoint = localPos;
      });
    }
  }

  void _onPanStart(DragStartDetails details) {
    _onPanUpdate(DragUpdateDetails(
      globalPosition: details.globalPosition,
      localPosition: details.localPosition,
    ));
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final RenderBox? box =
        _wheelKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final localPos = box.globalToLocal(details.globalPosition);

    setState(() {
      _currentTouchPoint = localPos;

      final tile = _getTileAtPosition(localPos);
      if (tile != null) {
        if (!_selectedTiles.contains(tile)) {
          tile.isSelected = true;
          _selectedTiles.add(tile);
        } else if (_selectedTiles.length >= 2 &&
            _selectedTiles[_selectedTiles.length - 2] == tile) {
          final removed = _selectedTiles.removeLast();
          removed.isSelected = false;
        }
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_selectedTiles.isNotEmpty) {
      final formedWord = _selectedTiles.map((t) => t.letter).join();
      _checkFormedWord(formedWord);
    }

    setState(() {
      for (var tile in _selectedTiles) {
        tile.isSelected = false;
      }
      _selectedTiles.clear();
      _currentTouchPoint = null;
    });
  }

  void _checkFormedWord(String formedWord) {
    TargetWord? matchedTarget;
    int matchedIndex = -1;

    for (int i = 0; i < _targetWords.length; i++) {
      if (!_targetWords[i].isSolved && _targetWords[i].word == formedWord) {
        matchedTarget = _targetWords[i];
        matchedIndex = i;
        break;
      }
    }

    if (matchedTarget != null) {
      _clearFeedbackMessage();
      _triggerFlyingTilesAnimation(matchedIndex, formedWord, matchedTarget);
    } else {
      bool isAlreadySolved = false;
      for (var tw in _targetWords) {
        if (tw.isSolved && tw.word == formedWord) {
          isAlreadySolved = true;
          break;
        }
      }

      if (isAlreadySolved) {
        _setFeedbackMessage('"$formedWord" already solved!');
      } else if (formedWord.length >= 2) {
        _setFeedbackMessage('"$formedWord" is not a target word');
      }
    }
  }

  void _triggerFlyingTilesAnimation(
      int wordIndex, String word, TargetWord targetWord) {
    final List<FlyingTileData> newFlights = [];
    final RenderBox? stackBox =
        _screenStackKey.currentContext?.findRenderObject() as RenderBox?;
    final color = _activeLineColor;

    for (int i = 0; i < _selectedTiles.length; i++) {
      final tile = _selectedTiles[i];
      tile.isUsed = true;
      tile.solvedColor = color;

      final tileWheelCenter = tile.centerPosition ?? Offset.zero;
      final RenderBox? wheelBox =
          _wheelKey.currentContext?.findRenderObject() as RenderBox?;

      Offset globalWheelPos = tileWheelCenter;
      if (wheelBox != null) {
        globalWheelPos = wheelBox.localToGlobal(tileWheelCenter);
      }

      Offset startOffset = globalWheelPos;
      if (stackBox != null) {
        startOffset = stackBox.globalToLocal(globalWheelPos);
      }

      Offset targetOffset = startOffset;
      final slotKey = _slotKeys['${wordIndex}_$i'];
      if (slotKey != null && slotKey.currentContext != null) {
        final RenderBox? slotBox =
            slotKey.currentContext!.findRenderObject() as RenderBox?;
        if (slotBox != null) {
          final globalSlotPos = slotBox.localToGlobal(
            Offset(slotBox.size.width / 2, slotBox.size.height / 2),
          );
          if (stackBox != null) {
            targetOffset = stackBox.globalToLocal(globalSlotPos);
          }
        }
      }

      newFlights.add(
        FlyingTileData(
          letter: tile.letter,
          startPos: startOffset,
          endPos: targetOffset,
          color: color,
        ),
      );
    }

    setState(() {
      _activeFlyingTiles.clear();
      _activeFlyingTiles.addAll(newFlights);
    });

    _flightController.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() {
          targetWord.isSolved = true;
          _score += word.length * 15;
          _activeFlyingTiles.clear();
          _replenishWheel();
        });
        _checkLevelCompletion();
      }
    });
  }

  void _checkLevelCompletion() async {
    final allSolved = _targetWords.every((w) => w.isSolved);
    if (!allSolved || _isLevelCompleted) return;

    _isLevelCompleted = true;
    _timer?.cancel();
    _feedbackTimer?.cancel();

    await ScoreManager().recordLevelCompletion(
      levelId: _currentLevel.id,
      levelScore: _score,
      wordsSolvedCount: _targetWords.length,
      timeInSeconds: _timeInSeconds,
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
    final nextLevel = LevelsData.getLevel(_currentLevel.id + 1);
    setState(() {
      _initLevel(nextLevel);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = CategoryThemeData.getTheme(_currentLevel.category);
    final currentWordText = _selectedTiles.map((t) => t.letter).join();
    final accumulatedTotal = ScoreManager().totalScore + _score;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: currentTheme.appBarBackground.withAlpha(220),
        elevation: 0,
        title: Column(
          children: [
            Icon(currentTheme.icon, color: currentTheme.primaryAccent, size: 20),
            const SizedBox(width: 8),
            Text(
              'Level ${_currentLevel.id}: ${_currentLevel.name}',
              style: AppTextStyles.appBarTitle,
            ),
          ],
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: currentTheme.cardBackground.withAlpha(200),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: currentTheme.tileBorderColor.withAlpha(150)),
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
            icon: Icon(Icons.help_outline_rounded,
                color: currentTheme.secondaryAccent, size: 22),
          ),
        ],
      ),
      body: ThemeBackgroundWidget(
        theme: currentTheme,
        child: SafeArea(
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
                      decoration: BoxDecoration(
                        color: currentTheme.cardBackground.withAlpha(220),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        border: Border.all(
                            color: currentTheme.tileBorderColor.withAlpha(120)),
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
                              slotKeys: _slotKeys,
                            );
                          }),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Stats & Controls Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 10.0,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _shuffleWheel,
                              icon: const Icon(Icons.shuffle_rounded,
                                  color: Colors.white, size: 24),
                              label: const Text(
                                'Shuffle',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: currentTheme.primaryAccent,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    currentTheme.cardBackground,
                                disabledForegroundColor: Colors.white24,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 45.0, vertical: 6.0),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Level: $_score pts',
                              style: TextStyle(
                                color: currentTheme.highlightColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 52),
                            Text(
                              'Total: $accumulatedTotal pts',
                              style: TextStyle(
                                color: currentTheme.secondaryAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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
                          color: _activeLineColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _activeLineColor.withAlpha(140),
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

                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 100),
                    opacity:
                        (_feedbackMessage != null && _feedbackMessage!.isNotEmpty)
                            ? 1.0
                            : 0.0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Text(
                        _feedbackMessage ?? '',
                        style: AppTextStyles.warningMessage,
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Circular Game Board Wheel Area
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(11.0),
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: Container(
                            key: _wheelKey,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: currentTheme.boardBackground.withAlpha(220),
                              border: Border.all(
                                color: currentTheme.tileBorderColor.withAlpha(180),
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: currentTheme.cardBackground.withAlpha(140),
                                  blurRadius: 24,
                                  spreadRadius: 2,
                                ),
                                BoxShadow(
                                  color: _activeLineColor.withAlpha(30),
                                  blurRadius: 30,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  _boardWidth = constraints.maxWidth;
                                  _boardHeight = constraints.maxHeight;

                                  // Position active tiles evenly along the circle
                                  _arrangeTilesOnCircle();

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
                                        // Decorative Inner Circular Ring
                                        Center(
                                          child: Container(
                                            width: max(0.0,
                                                _boardWidth * 0.68 * 2 - _currentTileSize),
                                            height: max(0.0,
                                                _boardHeight * 0.68 * 2 - _currentTileSize),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: currentTheme.tileBorderColor
                                                    .withAlpha(70),
                                                width: 1.5,
                                              ),
                                            ),
                                          ),
                                        ),

                                        // Glowing Line Drag Painter
                                        Positioned.fill(
                                          child: CustomPaint(
                                            painter: WordLinePainter(
                                              currentDragPoints: dragPoints,
                                              currentTouchPoint: _currentTouchPoint,
                                              activeColor: _activeLineColor,
                                            ),
                                          ),
                                        ),

                                        // Circular Wheel Letter Bubbles
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
                                              activeColor: _activeLineColor,
                                              bubbleTileBorder:
                                                  currentTheme.bubbleTileBorder,
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
      ),
    );
  }
}
