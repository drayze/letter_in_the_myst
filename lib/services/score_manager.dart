import 'package:shared_preferences/shared_preferences.dart';

class ScoreManager {
  static final ScoreManager _instance = ScoreManager._internal();
  factory ScoreManager() => _instance;
  ScoreManager._internal();

  static const String _keyTotalScore = 'myst_total_score';
  static const String _keyHighScore = 'myst_high_score';
  static const String _keyCompletedLevels = 'myst_completed_levels';
  static const String _keyTotalWordsSolved = 'myst_total_words_solved';
  static const String _keyLevelScorePrefix = 'myst_level_score_';
  static const String _keyCurrentLevelId = 'myst_current_level_id';

  int _totalScore = 0;
  int _highScore = 0;
  int _totalWordsSolved = 0;
  int _currentLevelId = 1;
  final Set<int> _completedLevelIds = {};
  final Map<int, int> _levelBestScores = {};

  int get totalScore => _totalScore;
  int get highScore => _highScore;
  int get totalWordsSolved => _totalWordsSolved;
  int get currentLevelId => _currentLevelId;
  Set<int> get completedLevelIds => Set.unmodifiable(_completedLevelIds);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _totalScore = prefs.getInt(_keyTotalScore) ?? 0;
    _highScore = prefs.getInt(_keyHighScore) ?? 0;
    _totalWordsSolved = prefs.getInt(_keyTotalWordsSolved) ?? 0;
    _currentLevelId = prefs.getInt(_keyCurrentLevelId) ?? 1;

    final completedList = prefs.getStringList(_keyCompletedLevels) ?? [];
    _completedLevelIds.clear();
    for (var idStr in completedList) {
      final id = int.tryParse(idStr);
      if (id != null) {
        _completedLevelIds.add(id);
        _levelBestScores[id] = prefs.getInt('$_keyLevelScorePrefix$id') ?? 0;
      }
    }
  }

  int getLevelBestScore(int levelId) {
    return _levelBestScores[levelId] ?? 0;
  }

  Future<void> recordLevelCompletion({
    required int levelId,
    required int levelScore,
    required int wordsSolvedCount,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Accumulate total score
    _totalScore += levelScore;
    if (_totalScore > _highScore) {
      _highScore = _totalScore;
    }

    _totalWordsSolved += wordsSolvedCount;
    _completedLevelIds.add(levelId);

    // Advance current level number
    if (levelId >= _currentLevelId) {
      _currentLevelId = levelId + 1;
      await prefs.setInt(_keyCurrentLevelId, _currentLevelId);
    }

    // Update level best score
    final currentBest = _levelBestScores[levelId] ?? 0;
    if (levelScore > currentBest) {
      _levelBestScores[levelId] = levelScore;
      await prefs.setInt('$_keyLevelScorePrefix$levelId', levelScore);
    }

    // Persist scores to SharedPreferences
    await prefs.setInt(_keyTotalScore, _totalScore);
    await prefs.setInt(_keyHighScore, _highScore);
    await prefs.setInt(_keyTotalWordsSolved, _totalWordsSolved);
    await prefs.setStringList(
      _keyCompletedLevels,
      _completedLevelIds.map((id) => id.toString()).toList(),
    );
  }
}
