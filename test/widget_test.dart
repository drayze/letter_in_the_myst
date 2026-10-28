import 'package:flutter_test/flutter_test.dart';
import 'package:letters_in_the_myst/data/levels_data.dart';
import 'package:letters_in_the_myst/main.dart';

void main() {
  testWidgets('Letters in the Myst smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LettersInTheMystApp());

    // Verify that the title appears.
    expect(find.text('Letters in the Myst'), findsWidgets);
    expect(find.text('Unscramble Hidden Puzzles'), findsOneWidget);
  });

  test('Every level contains exactly 10 words', () {
    for (final level in LevelsData.levels) {
      expect(level.words.length, equals(10),
          reason: 'Level ${level.id} (${level.name}) should have 10 words');
    }

    for (int i = 0; i < LevelsData.randomWordGroups.length; i++) {
      expect(LevelsData.randomWordGroups[i].length, equals(10),
          reason: 'Random word group $i should have 10 words');
    }

    final randomLevel = LevelsData.getRandomLevel(99);
    expect(randomLevel.words.length, equals(10));
  });
}
