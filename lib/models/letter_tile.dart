import 'package:flutter/material.dart';

class LetterTile {
  final String id;
  final String letter;
  int row;
  int col;
  bool isUsed;
  bool isSelected;
  bool isHinted;
  Color? solvedColor;
  Offset? centerPosition;

  LetterTile({
    required this.id,
    required this.letter,
    this.row = 0,
    this.col = 0,
    this.isUsed = false,
    this.isSelected = false,
    this.isHinted = false,
    this.solvedColor,
    this.centerPosition,
  });

  LetterTile copyWith({
    String? id,
    String? letter,
    int? row,
    int? col,
    bool? isUsed,
    bool? isSelected,
    bool? isHinted,
    Color? solvedColor,
    Offset? centerPosition,
  }) {
    return LetterTile(
      id: id ?? this.id,
      letter: letter ?? this.letter,
      row: row ?? this.row,
      col: col ?? this.col,
      isUsed: isUsed ?? this.isUsed,
      isSelected: isSelected ?? this.isSelected,
      isHinted: isHinted ?? this.isHinted,
      solvedColor: solvedColor ?? this.solvedColor,
      centerPosition: centerPosition ?? this.centerPosition,
    );
  }
}

class SolvedWordLine {
  final String word;
  final List<Offset> points;
  final Color color;

  SolvedWordLine({
    required this.word,
    required this.points,
    required this.color,
  });
}
