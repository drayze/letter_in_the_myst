class TargetWord {
  final String word;
  final String? clue;
  bool isSolved;

  TargetWord({
    required this.word,
    this.clue,
    this.isSolved = false,
  });

  int get length => word.length;
}

class Level {
  final int id;
  final String name;
  final String category;
  final List<String> words;
  final String description;

  const Level({
    required this.id,
    required this.name,
    required this.category,
    required this.words,
    required this.description,
  });

  /// Total number of letters across all target words in this level.
  int get totalLetters => words.fold(0, (sum, w) => sum + w.length);
}
