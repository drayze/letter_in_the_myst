import 'package:flutter/material.dart';

class LetterTile {
  final String id;
  final String letter;
  bool isUsed;
  bool isSelected;
  bool isHinted;
  Color? solvedColor;
  Offset? centerPosition;

  LetterTile({
    required this.id,
    required this.letter,
    this.isUsed = false,
    this.isSelected = false,
    this.isHinted = false,
    this.solvedColor,
    this.centerPosition,
  });
}
