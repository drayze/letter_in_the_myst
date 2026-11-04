import 'dart:math';
import '../models/level.dart';

class LevelsData {
  /// Categorized word database
  static const Map<String, List<String>> categoryWordBank = {
    'Nature World': [
      'LEAF', 'TREE', 'MOSS', 'FERN', 'WOOD', 'ROOT', 'BARK', 'STEM',
      'VINE', 'SEED', 'FLORA', 'GROVE', 'PINES', 'SHADE', 'BRANCH',
      'TRUNK', 'BLOOM', 'PLANT', 'FOREST', 'BUD', 'BROOK', 'RIVER',
      'STREAM', 'OCEAN', 'WAVE', 'RAIN', 'FLOW', 'SURF', 'POND', 'MIST',
      'MUSHROOM', 'FUNGI', 'SEA', 'MOUNTAIN', 'FLOWER', 'FAUNA', 'SEASON',
      'CLOUD', 'SOIL', 'DUSK', 'DAWN',
    ],
    'Wisdom Tools': [
      'BOOK', 'RUNE', 'TOME', 'PAGE', 'TEXT', 'READ', 'WISDOM', 'MIST',
      'SCROLL', 'QUILL', 'SHELF', 'INK', 'MIND', 'LOGIC', 'WORD',
      'FACT', 'LORE', 'LEARN', 'TRUTH', 'GUIDE', 'STUDY',
      'KNOWLEDGE', 'TEACH'
    ],
    'Celestial Wonders': [
      'STAR', 'MOON', 'GLOW', 'BEAM', 'RAY', 'ASTRAL', 'LUNAR',
      'SOLAR', 'NEBULA', 'GALAXY', 'ORBIT', 'COMET', 'NOVA', 'PLANET',
      'SPACE', 'COSMO', 'VENUS', 'PULSAR', 'ZENITH', 'METEOR', 'HALO',
      'GRAVITY',
    ],
    'Earthy Pieces': [
      'GEM', 'RUBY', 'MIST', 'STONE', 'GOLD', 'COIN', 'ORE', 'MINE',
      'CAVE', 'JADE', 'ROCK', 'GLINT', 'SHINE', 'CRYSTAL', 'QUARTZ',
      'AMBER', 'SILVER', 'PEARL', 'JEWEL', 'FLINT', 'COPPER', 'IRON'
    ],
    'Sorcery of the Ancestors': [
      'MAGIC', 'SPELL', 'WAND', 'CHARM', 'AURA', 'HEX', 'BREW', 'HERB',
      'RELIC', 'CURSE', 'ORB', 'MANA', 'ELIXIR', 'POTION', 'WITCH',
      'WIZARD', 'MYSTIC', 'ARCANE', 'TRICK', 'RITUAL', 'STAFF',
      'CAULDRON', 'NIGHT', 'MASK', 'MIRAGE', 'GLOOM',
      'SHADE', 'DREAM', 'VISION', 'VEIL', 'FOG', 'CLOAK', 'SPIRIT',
      'SOUL', 'LOST', 'WHISPER', 'TEMPLE',
      'CIPHER', 'PUZZLE', 'MYSTERY', 'CRYPT', 'LOCK', 'RUNE', 'KEY',
      'CODE', 'VAULT', 'SECRET', 'RIDDLE', 'GHOST', 'PHANTOM',
      'ENIGMA', 'HIDDEN', 'SHADOW', 'CLUE', 'DARK', 'GIFT', 'DOOR',
      'SHRINE', 'LEGEND', 'CROWN'
    ],
    'Scientific Findings': [
      'FLASK', 'ECHO', 'WEATHER', 'BASE', 'NOTES', 'THEORY', 'FACT',
      'BOIL', 'VIAL', 'ACID', 'VAPOR', 'MIX', 'SOLVE', 'EQUATION',
      'TOXIN', 'LAB', 'ATOM', 'BOND', 'CELL', 'FORM', 'HEAT',
      'MOLECULE', 'DNA', 'ENERGY', 'VOLUME', 'ELECTRIC', 'ELECTRODE',
      'SOLUTION', 'REACTION', 'FINDINGS', 'CONDUCTOR', 'FUSE', 'ELEMENTS',
    ],
    'Animals of the World': [
      'BEAR', 'HAWK', 'TROUT', 'DOG', 'FELINE', 'CAT', 'PANDA', 'LION',
      'WOLF', 'COYOTE', 'EAGLE', 'CARDINAL', 'HORSE', 'WHALE',
      'BLUEJAY', 'KANGAROO', 'SKUNK', 'RACOON', 'PRIMATE', 'TIGER',
      'COUGAR', 'SNAKE', 'HOUND', 'FROG', 'BUTTERFLY', 'SPIDER', 'LIZARD',
      'BLUEHEELER', 'GRIZZLY', 'MIXBREED', 'RABBIT', 'SQUIRREL', 'MOUSE',
      'GECKO', 'COBRA', 'ELK', 'MOOSE', 'GOOSE', 'TURKEY', 'PIGEON',
      'SALMON', 'SHARK', 'TORTOISE', 'TURTLE', 'FAWN', 'CUB', 'PUP', 'KITTEN',
      'DEER', 'FINCH', 'BEE', 'HUMMINGBIRD', 'ELEPHANT', 'LAMB', 'PUMA',
      'BAT', 'BARNOWL', 'TOAD', 'MOLE',
    ],
  };

  /// Master word database containing all unique words across all categories
  static List<String> get masterWordDatabase {
    final Set<String> all = {};
    for (var list in categoryWordBank.values) {
      all.addAll(list);
    }
    return all.toList();
  }

  // Cache for generated levels by level ID
  static final Map<int, Level> _levelCache = {};

  // Per-category tracking of words that have been used
  static final Map<String, Set<String>> _usedWordsPerCategory = {};

  /// Resets the internal level cache and word usage state.
  static void resetState() {
    _levelCache.clear();
    _usedWordsPerCategory.clear();
  }

  /// Retrieves or generates a Level instance for any level ID (1, 2, 3...)
  static Level getLevel(int id) {
    if (id < 1) id = 1;

    // Ensure all levels up to [id] are generated sequentially so word usage
    // tracking progresses systematically without missing or repeating words prematurely.
    for (int k = 1; k <= id; k++) {
      if (!_levelCache.containsKey(k)) {
        _levelCache[k] = _generateLevel(k);
      }
    }

    return _levelCache[id]!;
  }

  /// Generates level [k] by pulling 6, 7, or 8 words from one category
  /// while ensuring used words are tracked and not reused until all words in that category are used.
  static Level _generateLevel(int k) {
    final categories = categoryWordBank.keys.toList();
    final String categoryName = categories[(k - 1) % categories.length];

    // Unique words in this category
    final List<String> categoryWords =
        (categoryWordBank[categoryName] ?? []).toSet().toList();

    // Determine target word count (6, 7, or 8 words) for this level
    final rand = Random(k * 997);
    final int targetCount = 6 + rand.nextInt(3);

    // Track used words for this category
    final Set<String> used =
        _usedWordsPerCategory.putIfAbsent(categoryName, () => <String>{});

    // Filter words in this category that haven't been used yet
    List<String> unusedWords =
        categoryWords.where((w) => !used.contains(w)).toList();

    // If unused words in this category are fewer than target count,
    // all (or almost all) words in this category have been used.
    // Reset this category's used set so all words become available again.
    if (unusedWords.length < targetCount) {
      used.clear();
      unusedWords = List.from(categoryWords);
    }

    // Shuffle unused words for this level
    unusedWords.shuffle(rand);

    // Pick 6, 7, or 8 words
    final List<String> selectedWords = unusedWords.take(targetCount).toList();

    // Mark these words as used for this category
    used.addAll(selectedWords);

    return Level(
      id: k,
      name: categoryName,
      category: categoryName,
      words: selectedWords,
      description: 'Unscramble secret words from $categoryName.',
    );
  }
}
