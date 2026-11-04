import 'package:flutter/material.dart';

class LetterTile {
  final String id;
  final String letter;
  bool isUsed;
  bool isSelected;
  Color? solvedColor;
  Offset? centerPosition;

  LetterTile({
    required this.id,
    required this.letter,
    this.isUsed = false,
    this.isSelected = false,
    this.solvedColor,
    this.centerPosition,
  });
}
