import '../models/level.dart';

class LevelsData {
  static const List<Level> levels = [
    Level(
      id: 1,
      name: 'Mystic Grove',
      category: 'Nature',
      words: ['LEAF', 'TREE', 'MOSS', 'FERN'],
      description: 'Unscramble the secrets hidden within the enchanted grove.',
    ),
    Level(
      id: 2,
      name: 'Ancient Library',
      category: 'Wisdom',
      words: ['BOOK', 'RUNE', 'TOME', 'PAGE'],
      description: 'Dusty scrolls hold forgotten letters waiting to be revealed.',
    ),
    Level(
      id: 3,
      name: 'Celestial Night',
      category: 'Cosmic',
      words: ['STAR', 'MOON', 'GLOW', 'DUSK'],
      description: 'Look to the night sky to find the glowing starlight words.',
    ),
    Level(
      id: 4,
      name: 'Crystal Cavern',
      category: 'Elements',
      words: ['GEM', 'RUBY', 'MIST', 'STONE'],
      description: 'Reflective crystals shatter into letters among the shadows.',
    ),
    Level(
      id: 5,
      name: 'Arcane Sanctum',
      category: 'Sorcery',
      words: ['MAGIC', 'SPELL', 'WAND', 'CHARM'],
      description: 'Weave mystical runes into words of pure spellcraft.',
    ),
    Level(
      id: 6,
      name: 'Whispering River',
      category: 'Nature',
      words: ['WATER', 'RIVER', 'STREAM', 'OCEAN'],
      description: 'Flowing waters swirl letters across the mysterious shore.',
    ),
    Level(
      id: 7,
      name: 'Twilight Forest',
      category: 'Nature',
      words: ['TIMBER', 'FOREST', 'BRANCH', 'WOOD'],
      description: 'Deep within the woods, ancient trunks whisper their names.',
    ),
    Level(
      id: 8,
      name: 'Forgotten Vault',
      category: 'Mystery',
      words: ['CIPHER', 'PUZZLE', 'MYSTERY', 'CRYPT'],
      description: 'Decode the ancient lock where every tile plays its part.',
    ),
    Level(
      id: 9,
      name: 'Alchemy Lab',
      category: 'Science',
      words: ['ELIXIR', 'POTION', 'BREW', 'FLASK'],
      description: 'Mix glowing concoctions of scrambled golden runes.',
    ),
    Level(
      id: 10,
      name: 'Cosmic Nebula',
      category: 'Cosmic',
      words: ['GALAXY', 'COMET', 'NEBULA', 'ORBIT'],
      description: 'Stardust particles align to form celestial mysteries.',
    ),
    Level(
      id: 11,
      name: 'Shadow Realm',
      category: 'Illusion',
      words: ['SHADOW', 'SECRET', 'RIDDLE', 'GHOST'],
      description: 'Darkness parts when you reveal the true words of the mist.',
    ),
    Level(
      id: 12,
      name: 'Grand Sanctuary',
      category: 'Mastery',
      words: ['PHANTOM', 'ENIGMA', 'WHISPER', 'TEMPLE'],
      description: 'The ultimate test of letters in the myst.',
    ),
  ];

  /// Word bank for random puzzle generation
  static const List<List<String>> randomWordGroups = [
    ['FIRE', 'SPARK', 'FLAME', 'HEAT'],
    ['SNOW', 'FROST', 'ICE', 'CHILL'],
    ['BREEZE', 'WIND', 'STORM', 'GALE'],
    ['GOLD', 'SILVER', 'BRONZE', 'COIN'],
    ['DRAGON', 'BEAST', 'HYDRA', 'WYRM'],
    ['SHIELD', 'SWORD', 'ARMOR', 'HELM'],
    ['SOLAR', 'LUNAR', 'ASTRAL', 'STARRY'],
    ['DREAM', 'VISION', 'SLUMBER', 'REST'],
    ['LIGHT', 'SHINE', 'BEAM', 'RAY'],
    ['CROWN', 'KING', 'QUEEN', 'ROYAL'],
  ];

  static Level getRandomLevel(int id) {
    final index = (id - 1) % randomWordGroups.length;
    final words = randomWordGroups[index];
    return Level(
      id: id,
      name: 'Mystic Challenge #$id',
      category: 'Endless Myst',
      words: words,
      description: 'A newly summoned combination of secret runes!',
    );
  }
}
