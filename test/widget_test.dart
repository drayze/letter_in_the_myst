import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:letters_in_the_myst/data/levels_data.dart';
import 'package:letters_in_the_myst/main.dart';
import 'package:letters_in_the_myst/theme/themes.dart';

void main() {
  setUp(() {
    LevelsData.resetState();
  });

  testWidgets('Letters in the Myst smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LettersInTheMystApp());

    // Verify that the title and score header appear.
    expect(find.text('Letters in the Myst'), findsWidgets);
    expect(find.textContaining('TOTAL SCORE'), findsOneWidget);
  });

  test('Every category has a distinct theme with a custom background definition', () {
    final categories = LevelsData.categoryWordBank.keys.toList();
    expect(CategoryThemeData.allThemes.length, equals(7));

    for (final category in categories) {
      final theme = CategoryThemeData.getTheme(category);
      expect(theme.categoryName, equals(category));
      expect(theme.backgroundGradientColors.length, greaterThanOrEqualTo(2));
      expect(theme.primaryAccent, isNotNull);
      expect(theme.scaffoldBackground, isNotNull);
    }
  });

  testWidgets('ThemeBackgroundWidget renders correctly for each category theme', (WidgetTester tester) async {
    for (final theme in CategoryThemeData.allThemes) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemeBackgroundWidget(
              theme: theme,
              child: Text('Theme: ${theme.categoryName}'),
            ),
          ),
        ),
      );

      expect(find.text('Theme: ${theme.categoryName}'), findsOneWidget);
    }
  });

  test('Every level displays category name as level title and has 6 to 8 words', () {
    LevelsData.resetState();
    final validCategories = LevelsData.categoryWordBank.keys.toSet();

    for (int id = 1; id <= 100; id++) {
      final level = LevelsData.getLevel(id);
      expect(level.id, equals(id));
      expect(validCategories.contains(level.name), isTrue,
          reason: 'Level name "${level.name}" should be a valid category name');
      expect(level.category, equals(level.name));
      expect(level.words.length, greaterThanOrEqualTo(6),
          reason: 'Level $id (${level.name}) should have at least 6 words');
      expect(level.words.length, lessThanOrEqualTo(8),
          reason: 'Level $id (${level.name}) should have at most 8 words');

      // Verify all words in this level belong to the specified category
      final categoryWords = LevelsData.categoryWordBank[level.category]!;
      for (final word in level.words) {
        expect(categoryWords.contains(word), isTrue,
            reason: 'Word "$word" should belong to category "${level.category}"');
      }
    }
  });

  test('Words are not reused within a category until available category words are depleted', () {
    LevelsData.resetState();
    final usedWordsPerCategory = <String, Set<String>>{};

    for (int id = 1; id <= 50; id++) {
      final level = LevelsData.getLevel(id);
      final cat = level.category;
      final categoryWords = LevelsData.categoryWordBank[cat]!.toSet();
      usedWordsPerCategory.putIfAbsent(cat, () => <String>{});

      final currentUsed = usedWordsPerCategory[cat]!;
      final unusedInCat = categoryWords.difference(currentUsed);

      if (unusedInCat.length < level.words.length) {
        // Pool reset occurred for this category because unused words were less than required level word count
        usedWordsPerCategory[cat] = level.words.toSet();
      } else {
        // Words in this level must be strictly from the unused pool
        for (final word in level.words) {
          expect(currentUsed.contains(word), isFalse,
              reason: 'Word "$word" in category "$cat" was reused before category words were depleted');
          currentUsed.add(word);
        }
      }
    }
  });
}
