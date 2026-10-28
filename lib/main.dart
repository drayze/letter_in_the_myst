import 'package:flutter/material.dart';
import 'screens/level_select_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const LettersInTheMystApp());
}

class LettersInTheMystApp extends StatelessWidget {
  const LettersInTheMystApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Letters in the Myst',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const LevelSelectScreen(),
    );
  }
}
