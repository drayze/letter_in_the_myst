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

  test('Every level contains between 6 and 8 words from database infinitely', () {
    for (int id = 1; id <= 100; id++) {
      final level = LevelsData.getLevel(id);
      expect(level.id, equals(id));
      expect(level.words.length, greaterThanOrEqualTo(6),
          reason: 'Level $id (${level.name}) should have at least 6 words');
      expect(level.words.length, lessThanOrEqualTo(8),
          reason: 'Level $id (${level.name}) should have at most 8 words');
    }
  });
}
