import 'dart:math';
import '../models/level.dart';

class LevelsData {
  /// Categorized word database
  static const Map<String, List<String>> categoryWordBank = {
    'Nature': [
      'LEAF', 'TREE', 'MOSS', 'FERN', 'WOOD', 'ROOT', 'BARK', 'STEM',
      'VINE', 'SEED', 'FLORA', 'GROVE', 'PINES', 'SHADE', 'BRANCH',
      'TRUNK', 'BLOOM', 'PLANT', 'FOREST', 'BUD', 'BROOK', 'RIVER',
      'STREAM', 'OCEAN', 'WAVE', 'RAIN', 'FLOW', 'SURF', 'POND'
    ],
    'Wisdom': [
      'BOOK', 'RUNE', 'TOME', 'PAGE', 'TEXT', 'READ', 'WISE', 'MIST',
      'SCROLL', 'QUILL', 'SHELF', 'INK', 'MIND', 'LOGIC', 'WORD',
      'FACT', 'LORE', 'KNOW', 'LEARN', 'TRUTH', 'GUIDE', 'STUDY'
    ],
    'Cosmic': [
      'STAR', 'MOON', 'GLOW', 'DUSK', 'BEAM', 'RAY', 'ASTRAL', 'LUNAR',
      'SOLAR', 'NEBULA', 'GALAXY', 'ORBIT', 'COMET', 'NOVA', 'PLANET',
      'SPACE', 'COSMO', 'VENUS', 'PULSAR', 'ZENITH', 'STARRY', 'HALO'
    ],
    'Elements': [
      'GEM', 'RUBY', 'MIST', 'STONE', 'GOLD', 'COIN', 'ORE', 'MINE',
      'CAVE', 'JADE', 'ROCK', 'GLINT', 'SHINE', 'CRYSTAL', 'QUARTZ',
      'AMBER', 'SILVER', 'PEARL', 'JEWEL', 'FLINT', 'COPPER', 'IRON'
    ],
    'Sorcery': [
      'MAGIC', 'SPELL', 'WAND', 'CHARM', 'AURA', 'HEX', 'BREW', 'HERB',
      'RELIC', 'CURSE', 'ORB', 'MANA', 'ELIXIR', 'POTION', 'WITCH',
      'WIZARD', 'MYSTIC', 'ARCANE', 'TRICK', 'RITUAL', 'STAFF'
    ],
    'Mystery': [
      'CIPHER', 'PUZZLE', 'MYSTERY', 'CRYPT', 'LOCK', 'RUNE', 'KEY',
      'CODE', 'VAULT', 'SECRET', 'RIDDLE', 'MASK', 'GHOST', 'PHANTOM',
      'ENIGMA', 'HIDDEN', 'SHADOW', 'CLUE', 'DARK', 'GIFT', 'DOOR'
    ],
    'Science': [
      'ELIXIR', 'POTION', 'BREW', 'FLASK', 'HERB', 'ROOT', 'MIST',
      'SPELL', 'BOIL', 'VIAL', 'MAGIC', 'ACID', 'VAPOR', 'MIX',
      'TOXIN', 'LAB', 'ATOM', 'BOND', 'CELL', 'FORM', 'HEAT'
    ],
    'Illusion': [
      'SHADOW', 'SECRET', 'RIDDLE', 'GHOST', 'DARK', 'MIST', 'NIGHT',
      'PHANTOM', 'RUNE', 'CRYPT', 'VAULT', 'MASK', 'MIRAGE', 'GLOOM',
      'SHADE', 'DREAM', 'VISION', 'VEIL', 'ECHO', 'FOG', 'CLOAK'
    ],
    'Mastery': [
      'PHANTOM', 'ENIGMA', 'WHISPER', 'TEMPLE', 'SHADOW', 'RIDDLE',
      'SECRET', 'CRYPT', 'VAULT', 'RUNE', 'MAGIC', 'GHOST', 'MYSTERY',
      'DARK', 'SHRINE', 'LEGEND', 'MASTER', 'ARCANE', 'SPIRIT', 'CROWN'
    ],
  };

  /// Master word database containing all words across all categories
  static List<String> get masterWordDatabase {
    final Set<String> all = {};
    for (var list in categoryWordBank.values) {
      all.addAll(list);
    }
    return all.toList();
  }

  /// Generates a random selection of 6 to 8 unique words from a word bank
  static List<String> getRandomWordsForLevel({
    String? category,
    int? count,
    Random? random,
  }) {
    final rand = random ?? Random();
    final int targetCount = count ?? (6 + rand.nextInt(3)); // 6, 7, or 8 words

    final List<String> pool = [];
    if (category != null && categoryWordBank.containsKey(category)) {
      pool.addAll(categoryWordBank[category]!);
    } else {
      pool.addAll(masterWordDatabase);
    }

    pool.shuffle(rand);
    final Set<String> selected = {};

    for (var w in pool) {
      selected.add(w);
      if (selected.length >= targetCount) break;
    }

    // Fallback if pool was small
    if (selected.length < targetCount) {
      final master = masterWordDatabase..shuffle(rand);
      for (var w in master) {
        selected.add(w);
        if (selected.length >= targetCount) break;
      }
    }

    return selected.toList();
  }

  /// Story levels configuration definitions
  static final List<LevelConfig> storyLevelConfigs = [
    LevelConfig(1, 'Mystic Grove', 'Nature', 'Unscramble the secrets hidden within the enchanted grove.'),
    LevelConfig(2, 'Ancient Library', 'Wisdom', 'Dusty scrolls hold forgotten letters waiting to be revealed.'),
    LevelConfig(3, 'Celestial Night', 'Cosmic', 'Look to the night sky to find the glowing starlight words.'),
    LevelConfig(4, 'Crystal Cavern', 'Elements', 'Reflective crystals shatter into letters among the shadows.'),
    LevelConfig(5, 'Arcane Sanctum', 'Sorcery', 'Weave mystical runes into words of pure spellcraft.'),
    LevelConfig(6, 'Whispering River', 'Nature', 'Flowing waters swirl letters across the mysterious shore.'),
    LevelConfig(7, 'Twilight Forest', 'Nature', 'Deep within the woods, ancient trunks whisper their names.'),
    LevelConfig(8, 'Forgotten Vault', 'Mystery', 'Decode the ancient lock where every tile plays its part.'),
    LevelConfig(9, 'Alchemy Lab', 'Science', 'Mix glowing concoctions of scrambled golden runes.'),
    LevelConfig(10, 'Cosmic Nebula', 'Cosmic', 'Stardust particles align to form celestial mysteries.'),
    LevelConfig(11, 'Shadow Realm', 'Illusion', 'Darkness parts when you reveal the true words of the mist.'),
    LevelConfig(12, 'Grand Sanctuary', 'Mastery', 'The ultimate test of letters in the myst.'),
  ];

  /// Get static list of levels dynamically constructed with 6-8 words pulled from word database
  static List<Level> get levels {
    return storyLevelConfigs.map((config) {
      return getLevelForConfig(config);
    }).toList();
  }

  /// Creates a Level instance with 6 to 8 words randomly pulled from the word database
  static Level getLevelForConfig(LevelConfig config, [int? seed]) {
    final rand = seed != null ? Random(seed) : Random();
    final words = getRandomWordsForLevel(
      category: config.category,
      random: rand,
    );

    return Level(
      id: config.id,
      name: config.name,
      category: config.category,
      words: words,
      description: config.description,
    );
  }

  /// Get random endless level with 6-8 words pulled from word database
  static Level getRandomLevel(int id) {
    final words = getRandomWordsForLevel();
    return Level(
      id: id,
      name: 'Mystic Challenge #$id',
      category: 'Endless Myst',
      words: words,
      description: 'A newly summoned puzzle of ${words.length} secret words!',
    );
  }
}

class LevelConfig {
  final int id;
  final String name;
  final String category;
  final String description;

  const LevelConfig(this.id, this.name, this.category, this.description);
}
