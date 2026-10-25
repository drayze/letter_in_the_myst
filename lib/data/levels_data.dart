import 'dart:math';
import '../models/level.dart';

class LevelsData {
  static const List<Level> levels = [
    Level(
      id: 1,
      name: 'Mystic Grove',
      category: 'Nature',
      words: ['LEAF', 'TREE'], // 2 words
      description: 'Unscramble the initial secrets hidden within the enchanted grove.',
    ),
    Level(
      id: 2,
      name: 'Ancient Library',
      category: 'Wisdom',
      words: ['BOOK', 'RUNE', 'TOME'], // 3 words
      description: 'Dusty scrolls hold forgotten letters waiting to be revealed.',
    ),
    Level(
      id: 3,
      name: 'Celestial Night',
      category: 'Cosmic',
      words: ['STAR', 'MOON', 'GLOW', 'DUSK'], // 4 words
      description: 'Look to the night sky to find the glowing starlight words.',
    ),
    Level(
      id: 4,
      name: 'Crystal Cavern',
      category: 'Elements',
      words: ['GEM', 'RUBY', 'MIST', 'STONE', 'GOLD'], // 5 words
      description: 'Reflective crystals shatter into letters among the shadows.',
    ),
    Level(
      id: 5,
      name: 'Arcane Sanctum',
      category: 'Sorcery',
      words: ['MAGIC', 'SPELL', 'WAND', 'CHARM', 'RUNE', 'AURA'], // 6 words
      description: 'Weave mystical runes into words of pure spellcraft.',
    ),
    Level(
      id: 6,
      name: 'Whispering River',
      category: 'Nature',
      words: ['WATER', 'RIVER', 'STREAM', 'OCEAN', 'WAVE', 'RAIN', 'FLOW'], // 7 words
      description: 'Flowing waters swirl letters across the mysterious shore.',
    ),
    Level(
      id: 7,
      name: 'Twilight Forest',
      category: 'Nature',
      words: ['TIMBER', 'FOREST', 'BRANCH', 'WOOD', 'LEAF', 'TREE', 'ROOT', 'BARK'], // 8 words
      description: 'Deep within the woods, ancient trunks whisper their names.',
    ),
    Level(
      id: 8,
      name: 'Forgotten Vault',
      category: 'Mystery',
      words: ['CIPHER', 'PUZZLE', 'MYSTERY', 'CRYPT', 'LOCK', 'RUNE', 'KEY', 'CODE', 'VAULT'], // 9 words
      description: 'Decode the ancient lock where every tile plays its part.',
    ),
    Level(
      id: 9,
      name: 'Alchemy Lab',
      category: 'Science',
      words: ['ELIXIR', 'POTION', 'BREW', 'FLASK', 'HERB', 'ROOT', 'MIST', 'SPELL', 'BOIL', 'VIAL'], // 10 words
      description: 'Mix glowing concoctions of scrambled golden runes.',
    ),
    Level(
      id: 10,
      name: 'Cosmic Nebula',
      category: 'Cosmic',
      words: ['GALAXY', 'COMET', 'NEBULA', 'ORBIT', 'STAR', 'MOON', 'ASTRAL', 'SOLAR', 'LUNAR', 'RAY', 'GLOW'], // 11 words
      description: 'Stardust particles align to form celestial mysteries.',
    ),
    Level(
      id: 11,
      name: 'Shadow Realm',
      category: 'Illusion',
      words: ['SHADOW', 'SECRET', 'RIDDLE', 'GHOST', 'DARK', 'MIST', 'NIGHT', 'PHANTOM', 'RUNE', 'CRYPT', 'VAULT', 'MASK'], // 12 words
      description: 'Darkness parts when you reveal the true words of the mist.',
    ),
    Level(
      id: 12,
      name: 'Grand Sanctuary',
      category: 'Mastery',
      words: ['PHANTOM', 'ENIGMA', 'WHISPER', 'TEMPLE', 'SHADOW', 'RIDDLE', 'SECRET', 'CRYPT', 'VAULT', 'RUNE', 'MAGIC', 'GHOST', 'MYSTERY'], // 13 words
      description: 'The ultimate test of letters in the myst.',
    ),
  ];

  /// Master word pool for dynamic random level generation
  static const List<String> masterWordBank = [
    'LEAF', 'TREE', 'MOSS', 'FERN', 'WOOD', 'ROOT', 'BARK', 'STEM',
    'BOOK', 'RUNE', 'TOME', 'PAGE', 'TEXT', 'READ', 'WISE', 'MIST',
    'STAR', 'MOON', 'GLOW', 'DUSK', 'BEAM', 'RAY', 'ASTRAL', 'LUNAR',
    'GEM', 'RUBY', 'MIST', 'STONE', 'GOLD', 'COIN', 'ORE', 'MINE',
    'MAGIC', 'SPELL', 'WAND', 'CHARM', 'AURA', 'HEX', 'BREW', 'HERB',
    'WATER', 'RIVER', 'STREAM', 'OCEAN', 'WAVE', 'RAIN', 'FLOW', 'SEA',
    'FIRE', 'SPARK', 'FLAME', 'HEAT', 'ASH', 'COAL', 'EMBER', 'BURN',
    'SNOW', 'FROST', 'ICE', 'CHILL', 'COLD', 'HAIL', 'BLAST', 'WIND',
    'DRAGON', 'BEAST', 'HYDRA', 'WYRM', 'CLAW', 'FANG', 'ROAR', 'WING',
    'SHIELD', 'SWORD', 'ARMOR', 'HELM', 'BLADE', 'BOW', 'AXE', 'GUARD',
  ];

  static Level getRandomLevel(int id) {
    // Determine target word count: Level 1 has 2 words, Level id has id + 1 words (capped at 14)
    final int wordCount = (id + 1).clamp(2, 14);
    final rand = Random(id * 997); // Deterministic random seed per level id

    final Set<String> selectedWords = {};
    final bankCopy = List<String>.from(masterWordBank);

    while (selectedWords.length < wordCount && bankCopy.isNotEmpty) {
      final index = rand.nextInt(bankCopy.length);
      selectedWords.add(bankCopy.removeAt(index));
    }

    return Level(
      id: id,
      name: 'Mystic Challenge #$id',
      category: 'Endless Myst',
      words: selectedWords.toList(),
      description: 'A newly summoned combination of $wordCount secret runes!',
    );
  }
}
