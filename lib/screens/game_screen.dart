import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../data/levels_data.dart';
import '../models/letter_tile.dart';
import '../models/level.dart';
import '../theme/app_theme.dart';
import '../widgets/flying_word_widget.dart';
import '../widgets/guess_tray.dart';
import '../widgets/how_to_play_dialog.dart';
import '../widgets/letter_tile_widget.dart';
import '../widgets/victory_dialog.dart';
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
  late List<LetterTile> _scrambleTiles;
  final List<LetterTile> _selectedTiles = [];
  final Map<int, Set<int>> _revealedIndices = {};

  final GlobalKey _guessTrayKey = GlobalKey();
  final Map<int, GlobalKey> _wordSlotKeys = {};

  int _hintsRemaining = 5;
  int _score = 0;
  int _timeInSeconds = 0;
  Timer? _timer;
  String? _feedbackMessage;
  bool _isLevelCompleted = false;

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
    _hintsRemaining = 5;
    _feedbackMessage = null;
    _selectedTiles.clear();
    _revealedIndices.clear();
    _wordSlotKeys.clear();

    // 1. Initialize Target Words
    _targetWords = level.words.map((w) => TargetWord(word: w)).toList();

    // 2. Build Scramble Tile Pool using ALL letters from target words
    final List<LetterTile> tiles = [];
    int tileIdCounter = 0;

    for (int wordIndex = 0; wordIndex < level.words.length; wordIndex++) {
      final word = level.words[wordIndex];
      for (int charIndex = 0; charIndex < word.length; charIndex++) {
        tiles.add(
          LetterTile(
            id: 'tile_${tileIdCounter++}_${word[charIndex]}',
            letter: word[charIndex],
          ),
        );
      }
    }

    // Shuffle the tiles so they are scrambled
    tiles.shuffle(Random());
    _scrambleTiles = tiles;

    // Start Timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && !_isLevelCompleted) {
        setState(() {
          _timeInSeconds++;
        });
      }
    });
  }

  void _onTileTap(LetterTile tile) {
    if (tile.isUsed || tile.isSelected) return;

    setState(() {
      tile.isSelected = true;
      _selectedTiles.add(tile);
      _feedbackMessage = null;
    });
  }

  void _onSelectedTileTap(LetterTile tile) {
    setState(() {
      tile.isSelected = false;
      _selectedTiles.remove(tile);
      _feedbackMessage = null;
    });
  }

  void _onClearSelection() {
    setState(() {
      for (var tile in _selectedTiles) {
        tile.isSelected = false;
      }
      _selectedTiles.clear();
      _feedbackMessage = null;
    });
  }

  void _onShuffle() {
    setState(() {
      for (var tile in _selectedTiles) {
        tile.isSelected = false;
      }
      _selectedTiles.clear();
      _scrambleTiles.shuffle(Random());
      _feedbackMessage = 'Letters shuffled!';
    });
  }

  void _onHint() {
    if (_hintsRemaining <= 0) return;

    // Find first unsolved target word
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

    // Find first unrevealed letter index in target word
    int unrevealedCharIdx = -1;
    for (int c = 0; c < target.length; c++) {
      if (!_revealedIndices[unsolvedWordIdx]!.contains(c)) {
        unrevealedCharIdx = c;
        break;
      }
    }

    if (unrevealedCharIdx == -1) return;

    final neededLetter = target.word[unrevealedCharIdx];

    // Highlight a matching tile in scramble pool
    LetterTile? hintTile;
    for (var tile in _scrambleTiles) {
      if (!tile.isSelected && tile.letter == neededLetter) {
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
          'Hint: Word #${unsolvedWordIdx + 1} starts with "$neededLetter"!';
    });
  }

  void _onSubmit() {
    if (_selectedTiles.isEmpty) return;

    final guess = _selectedTiles.map((t) => t.letter).join();

    // Check if guess matches any unsolved target word
    int matchedIndex = -1;
    for (int i = 0; i < _targetWords.length; i++) {
      if (!_targetWords[i].isSolved && _targetWords[i].word == guess) {
        matchedIndex = i;
        break;
      }
    }

    if (matchedIndex != -1) {
      final String wordStr = guess;

      // Calculate starting offset from Guess Tray
      Offset startOffset = const Offset(100, 500);
      final RenderBox? trayBox =
          _guessTrayKey.currentContext?.findRenderObject() as RenderBox?;
      if (trayBox != null) {
        final pos = trayBox.localToGlobal(Offset.zero);
        startOffset = Offset(
          pos.dx + (trayBox.size.width / 2) - (wordStr.length * 16),
          pos.dy + 10,
        );
      }

      // Calculate target offset from target WordSlotWidget
      Offset targetOffset = const Offset(100, 100);
      final RenderBox? slotBox = _wordSlotKeys[matchedIndex]
          ?.currentContext
          ?.findRenderObject() as RenderBox?;
      if (slotBox != null) {
        targetOffset = slotBox.localToGlobal(Offset.zero);
      }

      // Immediately consume solved tiles so they vanish from scramble area
      final tilesToRemove = Set<LetterTile>.from(_selectedTiles);
      setState(() {
        _scrambleTiles.removeWhere((tile) => tilesToRemove.contains(tile));
        _score += guess.length * 100;
        _feedbackMessage = '✨ Solved "$wordStr"!';
        _selectedTiles.clear();
      });

      // Launch flying word animation above everything on screen
      _launchFlyingWordOverlay(
        word: wordStr,
        startOffset: startOffset,
        targetOffset: targetOffset,
        onComplete: () {
          if (!mounted) return;
          setState(() {
            _targetWords[matchedIndex].isSolved = true;

            // Check if level is complete
            if (_targetWords.every((w) => w.isSolved)) {
              _handleLevelCompleted();
            }
          });
        },
      );
    } else {
      // Check if already solved
      final bool alreadySolved =
          _targetWords.any((w) => w.isSolved && w.word == guess);

      setState(() {
        if (alreadySolved) {
          _feedbackMessage = 'Already found "$guess"!';
        } else {
          _feedbackMessage = '"$guess" is not one of the secret words.';
        }
      });
    }
  }

  void _launchFlyingWordOverlay({
    required String word,
    required Offset startOffset,
    required Offset targetOffset,
    required VoidCallback onComplete,
  }) {
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => FlyingTileWidget(
        word: word,
        startOffset: startOffset,
        targetOffset: targetOffset,
        onComplete: () {
          overlayEntry.remove();
          onComplete();
        },
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }

  void _handleLevelCompleted() {
    _isLevelCompleted = true;
    _timer?.cancel();

    // Time bonus
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
    final int remainingLetters = _scrambleTiles.length;

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
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
              'Chapter: ${_currentLevel.category}',
              style: const TextStyle(
                color: AppColors.purpleLight,
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
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.purplePrimary),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined,
                      color: AppColors.gold, size: 16),
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
                color: AppColors.purpleLight),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Secret Words Display Panel
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 180),
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              decoration: const BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 4.0,
                  runSpacing: 4.0,
                  children: List.generate(_targetWords.length, (index) {
                    _wordSlotKeys[index] ??= GlobalKey();
                    return KeyedSubtree(
                      key: _wordSlotKeys[index],
                      child: WordSlotWidget(
                        targetWord: _targetWords[index],
                        revealedIndices: _revealedIndices[index] ?? {},
                      ),
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Letter Pool Counter Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Unsolved letters: $remainingLetters / ${_currentLevel.totalLetters}',
                    style: const TextStyle(
                      color: AppColors.purpleLight,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Score: $_score',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Scramble Tiles Grid Area
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: AppColors.bgContainer.withAlpha(180),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.surfaceDark),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _scrambleTiles.map((tile) {
                        return LetterTileWidget(
                          tile: tile,
                          size: 48.0,
                          onTap: () => _onTileTap(tile),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),

            // Guess Tray Component at Bottom
            GuessTray(
              key: _guessTrayKey,
              selectedTiles: _selectedTiles,
              onTileTap: _onSelectedTileTap,
              onSubmit: _onSubmit,
              onClear: _onClearSelection,
              onShuffle: _onShuffle,
              onHint: _onHint,
              hintsRemaining: _hintsRemaining,
              message: _feedbackMessage,
            ),
          ],
        ),
      ),
    );
  }
}
