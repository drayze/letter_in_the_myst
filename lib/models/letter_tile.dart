class LetterTile {
  final String id;
  final String letter;
  bool isUsed;
  bool isSelected;
  bool isHinted;

  LetterTile({
    required this.id,
    required this.letter,
    this.isUsed = false,
    this.isSelected = false,
    this.isHinted = false,
  });

  LetterTile copyWith({
    String? id,
    String? letter,
    bool? isUsed,
    bool? isSelected,
    bool? isHinted,
  }) {
    return LetterTile(
      id: id ?? this.id,
      letter: letter ?? this.letter,
      isUsed: isUsed ?? this.isUsed,
      isSelected: isSelected ?? this.isSelected,
      isHinted: isHinted ?? this.isHinted,
    );
  }
}
