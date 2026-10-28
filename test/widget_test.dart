import 'package:flutter_test/flutter_test.dart';
import 'package:letters_in_the_myst/data/levels_data.dart';
import 'package:letters_in_the_myst/main.dart';

void main() {
  testWidgets('Letters in the Myst smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LettersInTheMystApp());

    // Verify that the title and score header appear.
    expect(find.text('Letters in the Myst'), findsWidgets);
    expect(find.textContaining('TOTAL SCORE'), findsOneWidget);
  });

  test('Every level contains between 6 and 8 words from database', () {
    for (final level in LevelsData.levels) {
      expect(level.words.length, greaterThanOrEqualTo(6),
          reason: 'Level ${level.id} (${level.name}) should have at least 6 words');
      expect(level.words.length, lessThanOrEqualTo(8),
          reason: 'Level ${level.id} (${level.name}) should have at most 8 words');
    }

    for (int id = 1; id <= 20; id++) {
      final randomLevel = LevelsData.getRandomLevel(id);
      expect(randomLevel.words.length, greaterThanOrEqualTo(6));
      expect(randomLevel.words.length, lessThanOrEqualTo(8));
    }
  });
}
