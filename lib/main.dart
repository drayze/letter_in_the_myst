import 'package:flutter/material.dart';
import 'screens/level_select_screen.dart';
import 'services/score_manager.dart';
import 'theme/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScoreManager().init();
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
