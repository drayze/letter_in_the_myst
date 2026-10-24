import 'package:flutter/material.dart';
import 'screens/level_select_screen.dart';
import 'services/score_manager.dart';

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
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5A189A),
          brightness: Brightness.dark,
          surface: const Color(0xFF10002B),
          primary: const Color(0xFF7B2CBF),
          secondary: const Color(0xFFE0AAFF),
        ),
        scaffoldBackgroundColor: const Color(0xFF10002B),
        fontFamily: 'Roboto',
      ),
      home: const LevelSelectScreen(),
    );
  }
}
