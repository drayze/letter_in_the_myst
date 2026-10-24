import 'package:flutter_test/flutter_test.dart';
import 'package:letters_in_the_myst/main.dart';

void main() {
  testWidgets('Letters in the Myst smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LettersInTheMystApp());

    // Verify that the title appears.
    expect(find.text('Letters in the Myst'), findsWidgets);
    expect(find.text('Unscramble Hidden Puzzles'), findsOneWidget);
  });
}
