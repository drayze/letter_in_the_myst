import 'dart:math';
import 'package:flutter/material.dart';

/// Categories / Theme types for Letters in the Myst
enum CategoryThemeType {
  natureWorld,
  wisdomTools,
  celestialWonders,
  earthyPieces,
  sorceryOfTheAncestors,
  scientificFindings,
  animalsOfTheWorld,
}

/// Category specific Theme model
class CategoryTheme {
  final String categoryName;
  final String displayName;
  final IconData icon;
  final Color scaffoldBackground;
  final Color appBarBackground;
  final Color cardBackground;
  final Color boardBackground;
  final Color primaryAccent;
  final Color secondaryAccent;
  final Color tileBorderColor;
  final Color bubbleTileBorder;
  final Color activeLineColor;
  final Color highlightColor;
  final List<Color> backgroundGradientColors;
  final CategoryThemeType type;

  const CategoryTheme({
    required this.categoryName,
    required this.displayName,
    required this.icon,
    required this.scaffoldBackground,
    required this.appBarBackground,
    required this.cardBackground,
    required this.boardBackground,
    required this.primaryAccent,
    required this.secondaryAccent,
    required this.tileBorderColor,
    required this.bubbleTileBorder,
    required this.activeLineColor,
    required this.highlightColor,
    required this.backgroundGradientColors,
    required this.type,
  });
}

/// Centralized Registry of Category Themes
abstract class CategoryThemeData {
  static const CategoryTheme natureWorld = CategoryTheme(
    categoryName: 'Nature World',
    displayName: 'Nature World',
    icon: Icons.forest_rounded,
    scaffoldBackground: Color(0xFF113824),
    appBarBackground: Color(0xFF0D2D1C),
    cardBackground: Color(0xFF1B4E32),
    boardBackground: Color(0xFF16442A),
    primaryAccent: Color(0xFF52B788),
    secondaryAccent: Color(0xFF74C69D),
    tileBorderColor: Color(0xFF40916C),
    bubbleTileBorder: Color(0xFF52B788),
    activeLineColor: Color(0xFF74C69D),
    highlightColor: Color(0xFFD8F3DC),
    backgroundGradientColors: [
      Color(0xFF0E301F),
      Color(0xFF174C30),
      Color(0xFF226641),
    ],
    type: CategoryThemeType.natureWorld,
  );

  static const CategoryTheme wisdomTools = CategoryTheme(
    categoryName: 'Wisdom Tools',
    displayName: 'Wisdom Tools',
    icon: Icons.menu_book_rounded,
    scaffoldBackground: Color(0xFF1E2D4A),
    appBarBackground: Color(0xFF17233B),
    cardBackground: Color(0xFF283B60),
    boardBackground: Color(0xFF213252),
    primaryAccent: Color(0xFFF59E0B),
    secondaryAccent: Color(0xFFFCD34D),
    tileBorderColor: Color(0xFFD97706),
    bubbleTileBorder: Color(0xFFF59E0B),
    activeLineColor: Color(0xFFF59E0B),
    highlightColor: Color(0xFFFEF3C7),
    backgroundGradientColors: [
      Color(0xFF15223A),
      Color(0xFF20355A),
      Color(0xFF2C4A7C),
    ],
    type: CategoryThemeType.wisdomTools,
  );

  static const CategoryTheme celestialWonders = CategoryTheme(
    categoryName: 'Celestial Wonders',
    displayName: 'Celestial Wonders',
    icon: Icons.auto_awesome_rounded,
    scaffoldBackground: Color(0xFF1C153B),
    appBarBackground: Color(0xFF150F2E),
    cardBackground: Color(0xFF2C1F56),
    boardBackground: Color(0xFF241948),
    primaryAccent: Color(0xFF00F5D4),
    secondaryAccent: Color(0xFFB066FF),
    tileBorderColor: Color(0xFF7B2CBF),
    bubbleTileBorder: Color(0xFF00F5D4),
    activeLineColor: Color(0xFF00F5D4),
    highlightColor: Color(0xFFE0AAFF),
    backgroundGradientColors: [
      Color(0xFF140F2D),
      Color(0xFF251A50),
      Color(0xFF38236E),
    ],
    type: CategoryThemeType.celestialWonders,
  );

  static const CategoryTheme earthyPieces = CategoryTheme(
    categoryName: 'Earthy Pieces',
    displayName: 'Earthy Pieces',
    icon: Icons.diamond_rounded,
    scaffoldBackground: Color(0xFF332924),
    appBarBackground: Color(0xFF281F1B),
    cardBackground: Color(0xFF453630),
    boardBackground: Color(0xFF3B2E29),
    primaryAccent: Color(0xFFE07A5F),
    secondaryAccent: Color(0xFFF2CC8F),
    tileBorderColor: Color(0xFF815B48),
    bubbleTileBorder: Color(0xFFE07A5F),
    activeLineColor: Color(0xFFFFB703),
    highlightColor: Color(0xFFF4F1DE),
    backgroundGradientColors: [
      Color(0xFF261D1A),
      Color(0xFF3B2D27),
      Color(0xFF523E36),
    ],
    type: CategoryThemeType.earthyPieces,
  );

  static const CategoryTheme sorceryOfTheAncestors = CategoryTheme(
    categoryName: 'Sorcery of the Ancestors',
    displayName: 'Sorcery of Ancestors',
    icon: Icons.auto_fix_high_rounded,
    scaffoldBackground: Color(0xFF250A47),
    appBarBackground: Color(0xFF1C0637),
    cardBackground: Color(0xFF39106A),
    boardBackground: Color(0xFF2F0C58),
    primaryAccent: Color(0xFFD93B8A),
    secondaryAccent: Color(0xFFE8B4FF),
    tileBorderColor: Color(0xFF8A2BE2),
    bubbleTileBorder: Color(0xFF03BB38),
    activeLineColor: Color(0xFFFF007F),
    highlightColor: Color(0xFFFFD700),
    backgroundGradientColors: [
      Color(0xFF1C0637),
      Color(0xFF340E60),
      Color(0xFF4E168C),
    ],
    type: CategoryThemeType.sorceryOfTheAncestors,
  );

  static const CategoryTheme scientificFindings = CategoryTheme(
    categoryName: 'Scientific Findings',
    displayName: 'Scientific Findings',
    icon: Icons.science_rounded,
    scaffoldBackground: Color(0xFF122E52),
    appBarBackground: Color(0xFF0C223E),
    cardBackground: Color(0xFF1A4070),
    boardBackground: Color(0xFF15355D),
    primaryAccent: Color(0xFF64FFDA),
    secondaryAccent: Color(0xFF38BDF8),
    tileBorderColor: Color(0xFF2563EB),
    bubbleTileBorder: Color(0xFF64FFDA),
    activeLineColor: Color(0xFF64FFDA),
    highlightColor: Color(0xFFE0F2FE),
    backgroundGradientColors: [
      Color(0xFF0C223E),
      Color(0xFF163B66),
      Color(0xFF225792),
    ],
    type: CategoryThemeType.scientificFindings,
  );

  static const CategoryTheme animalsOfTheWorld = CategoryTheme(
    categoryName: 'Animals of the World',
    displayName: 'Animals of World',
    icon: Icons.pets_rounded,
    scaffoldBackground: Color(0xFF331E12),
    appBarBackground: Color(0xFF26150C),
    cardBackground: Color(0xFF472A1A),
    boardBackground: Color(0xFF3D2315),
    primaryAccent: Color(0xFFF59E0B),
    secondaryAccent: Color(0xFFFBBF24),
    tileBorderColor: Color(0xFFB45309),
    bubbleTileBorder: Color(0xFFF59E0B),
    activeLineColor: Color(0xFFF59E0B),
    highlightColor: Color(0xFFFEF3C7),
    backgroundGradientColors: [
      Color(0xFF24140B),
      Color(0xFF3E2314),
      Color(0xFF5A341E),
    ],
    type: CategoryThemeType.animalsOfTheWorld,
  );

  static const Map<String, CategoryTheme> themesMap = {
    'Nature World': natureWorld,
    'Wisdom Tools': wisdomTools,
    'Celestial Wonders': celestialWonders,
    'Earthy Pieces': earthyPieces,
    'Sorcery of the Ancestors': sorceryOfTheAncestors,
    'Scientific Findings': scientificFindings,
    'Animals of the World': animalsOfTheWorld,
  };

  static List<CategoryTheme> get allThemes => [
        natureWorld,
        wisdomTools,
        celestialWonders,
        earthyPieces,
        sorceryOfTheAncestors,
        scientificFindings,
        animalsOfTheWorld,
      ];

  static CategoryTheme getTheme(String categoryName) {
    return themesMap[categoryName] ?? sorceryOfTheAncestors;
  }
}

/// Centralized color palette for Letters in the Myst
abstract class AppColors {
  // --- Backgrounds & Surfaces ---
  static const Color scaffoldBackground = Color(0xFF10002B);
  static const Color appBarBackground = Color(0xFF07020E);
  static const Color cardBackground = Color(0xFF190933);
  static const Color surfaceDark = Color(0xFF10002B);
  static const Color containerDark = Color(0xFF240046);
  static const Color boardBackground = Color(0xFF140032);
  static const Color usedTileBackground = Color(0xFF381460);

  // --- Purple Brand & Accents ---
  static const Color seedPurple = Color(0xFF5A189A);
  static const Color darkPurpleBorder = Color(0xFF3C096C);
  static const Color purpleBorder = Color(0xFF5A189A);
  static const Color purpleAccent = Color(0xFF7B2CBF);
  static const Color purpleLight = Color(0xFFE0AAFF);
  static const Color primaryPink = Color(0xFFBF2C78);
  static const Color bubbleTileBorder = Color(0xFF03BB38);

  // --- Mint / Green / Solved States ---
  static const Color mintAccent = Color(0xFF74C69D);
  static const Color greenSolved = Color(0xFF52B788);
  static const Color greenSolvedDark = Color(0xFF2D6A4F);
  static const Color greenSolvedBg = Color(0xFF1B4332);
  static const Color greenDarkText = Color(0xFF081C15);
  static const Color greenLightText = Color(0xFFD8F3DC);

  // --- Gold / Yellow / Warning ---
  static const Color goldAccent = Color(0xFFFFD700);
  static const Color warningOrange = Color(0xFFFF9E00);

  // --- Cyan / Active Selection ---
  static const Color activeCyan = Color(0xFF00F5D4);

  // --- Line Palette (for Tracing Word Lines) ---
  static const List<Color> linePalette = [
    Color(0xFF00F5D4), // Cyan
    Color(0xFFFF007F), // Neon Pink
    Color(0xFFFFB703), // Amber
    Color(0xFF9D4EDD), // Purple
    Color(0xFF74C69D), // Mint
    Color(0xFF3A86FF), // Blue
  ];
}

/// Centralized gradients for UI backgrounds, cauldrons, and tiles
abstract class AppGradients {
  static const LinearGradient headerBanner = LinearGradient(
    colors: [
      AppColors.darkPurpleBorder,
      AppColors.seedPurple,
      AppColors.greenDarkText,
      AppColors.greenSolvedBg,
      AppColors.greenSolved
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient scaffoldBackgroundGrade = LinearGradient(
    colors: [AppColors.darkPurpleBorder, AppColors.seedPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static RadialGradient bubbleTile(Color bubbleColor) {
    return RadialGradient(
      center: const Alignment(-0.3, -0.4),
      radius: 0.85,
      colors: [
        Color.alphaBlend(Colors.white.withAlpha(120), bubbleColor),
        bubbleColor,
        Color.alphaBlend(Colors.black.withAlpha(80), bubbleColor),
      ],
      stops: const [0.0, 0.65, 1.0],
    );
  }
}

/// Centralized text styles used across screens and widgets
abstract class AppTextStyles {
  static const TextStyle appBarTitle = TextStyle(
    color: Colors.white,
    fontSize: 17,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle headerTitle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.0,
  );

  static const TextStyle totalScoreBanner = TextStyle(
    color: AppColors.mintAccent,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle levelCardNumber = TextStyle(
    color: AppColors.purpleLight,
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle levelCardTitle = TextStyle(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle levelCardSubtitle = TextStyle(
    color: Colors.white60,
    fontSize: 14,
  );

  static const TextStyle levelCardScore = TextStyle(
    color: AppColors.goldAccent,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle statLabel = TextStyle(
    color: Colors.white54,
    fontSize: 14,
  );

  static const TextStyle statValue = TextStyle(
    color: Colors.white,
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle activeWordBanner = TextStyle(
    color: AppColors.greenDarkText,
    fontSize: 18,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.5,
  );

  static const TextStyle warningMessage = TextStyle(
    color: AppColors.warningOrange,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle dialogTitle = TextStyle(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle victoryTitle = TextStyle(
    color: AppColors.greenLightText,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
  );

  static const TextStyle victoryLevelName = TextStyle(
    color: AppColors.purpleLight,
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );
}

/// Centralized shadows and glow effects
abstract class AppShadows {
  static List<BoxShadow> glow(Color color,
      {double blurRadius = 12, double spreadRadius = 0}) {
    return [
      BoxShadow(
        color: color.withAlpha(150),
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
      ),
    ];
  }

  static final List<BoxShadow> bannerShadow = [
    BoxShadow(
      color: AppColors.seedPurple.withAlpha(120),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
}

/// Custom Background Painter that renders artistic backgrounds reflecting each theme
class ThemeBackgroundPainter extends CustomPainter {
  final CategoryTheme theme;

  ThemeBackgroundPainter({required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    // Shared Central Ambient Light Wash
    final centerLight = Paint()
      ..shader = RadialGradient(
        colors: [
          theme.primaryAccent.withAlpha(65),
          theme.secondaryAccent.withAlpha(25),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.5, size.height * 0.45),
          radius: size.width * 0.75,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.45),
      size.width * 0.75,
      centerLight,
    );

    switch (theme.type) {
      case CategoryThemeType.natureWorld:
        _paintNatureBackground(canvas, size);
        break;
      case CategoryThemeType.wisdomTools:
        _paintWisdomBackground(canvas, size);
        break;
      case CategoryThemeType.celestialWonders:
        _paintCelestialBackground(canvas, size);
        break;
      case CategoryThemeType.earthyPieces:
        _paintEarthyBackground(canvas, size);
        break;
      case CategoryThemeType.sorceryOfTheAncestors:
        _paintSorceryBackground(canvas, size);
        break;
      case CategoryThemeType.scientificFindings:
        _paintScientificBackground(canvas, size);
        break;
      case CategoryThemeType.animalsOfTheWorld:
        _paintAnimalsBackground(canvas, size);
        break;
    }
  }

  /// Nature World: Floating leaves, forest mist glow, ambient pollen motes
  void _paintNatureBackground(Canvas canvas, Size size) {
    final rand = Random(42);

    // 1. Forest Mist Glows
    final mistPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          theme.primaryAccent.withAlpha(90),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.8, size.height * 0.2),
          radius: size.width * 0.55,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      size.width * 0.55,
      mistPaint,
    );

    final mistPaint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          theme.secondaryAccent.withAlpha(80),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.2, size.height * 0.75),
          radius: size.width * 0.6,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.75),
      size.width * 0.6,
      mistPaint2,
    );

    // 2. Floating Leaf Motifs
    final leafPaint = Paint()
      ..color = theme.primaryAccent.withAlpha(50)
      ..style = PaintingStyle.fill;

    final leafStroke = Paint()
      ..color = theme.secondaryAccent.withAlpha(90)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final leafOffsets = [
      Offset(size.width * 0.15, size.height * 0.12),
      Offset(size.width * 0.85, size.height * 0.35),
      Offset(size.width * 0.25, size.height * 0.55),
      Offset(size.width * 0.75, size.height * 0.82),
      Offset(size.width * 0.1, size.height * 0.9),
    ];

    for (int i = 0; i < leafOffsets.length; i++) {
      final pos = leafOffsets[i];
      final leafPath = Path();
      final scale = 18.0 + (i % 3) * 6;
      final angle = (i * 45) * pi / 180;

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(angle);

      leafPath.moveTo(0, -scale);
      leafPath.quadraticBezierTo(scale * 0.8, -scale * 0.2, 0, scale);
      leafPath.quadraticBezierTo(-scale * 0.8, -scale * 0.2, 0, -scale);

      canvas.drawPath(leafPath, leafPaint);
      canvas.drawPath(leafPath, leafStroke);
      canvas.drawLine(
          Offset(0, -scale * 0.8), Offset(0, scale * 0.8), leafStroke);
      canvas.restore();
    }

    // 3. Spore / Pollen Particles
    final particlePaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 28; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final radius = 1.8 + rand.nextDouble() * 2.8;
      final alpha = (60 + rand.nextInt(120));

      particlePaint.color =
          (i % 2 == 0 ? theme.primaryAccent : theme.highlightColor)
              .withAlpha(alpha);
      canvas.drawCircle(Offset(x, y), radius, particlePaint);
    }
  }

  /// Wisdom Tools: Ancient parchment candle glow, glyph rings & book silhouettes
  void _paintWisdomBackground(Canvas canvas, Size size) {
    final rand = Random(108);

    // 1. Candlelight / Parchment Center Halo
    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          theme.primaryAccent.withAlpha(90),
          theme.secondaryAccent.withAlpha(45),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.5, size.height * 0.4),
          radius: size.width * 0.75,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.4),
      size.width * 0.75,
      haloPaint,
    );

    // 2. Concentric Glyph / Ink Rings
    final ringPaint = Paint()
      ..color = theme.primaryAccent.withAlpha(45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.4), size.width * 0.35, ringPaint);
    canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.4), size.width * 0.55, ringPaint);

    // 3. Ancient Book / Rune Markings
    final runePaint = Paint()
      ..color = theme.secondaryAccent.withAlpha(70)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    final runePositions = [
      Offset(size.width * 0.18, size.height * 0.18),
      Offset(size.width * 0.82, size.height * 0.22),
      Offset(size.width * 0.12, size.height * 0.75),
      Offset(size.width * 0.88, size.height * 0.8),
    ];

    for (var pos in runePositions) {
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      final path = Path()
        ..moveTo(0, -14)
        ..lineTo(14, 0)
        ..lineTo(0, 14)
        ..lineTo(-14, 0)
        ..close();
      canvas.drawPath(path, runePaint);
      canvas.drawLine(const Offset(0, -14), const Offset(0, 14), runePaint);
      canvas.restore();
    }

    // 4. Floating Ink Sparkles
    final dotPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 24; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      dotPaint.color = theme.primaryAccent.withAlpha(50 + rand.nextInt(100));
      canvas.drawCircle(Offset(x, y), 1.5 + rand.nextDouble() * 2.5, dotPaint);
    }
  }

  /// Celestial Wonders: Twinkling starlight field, cosmic nebula clouds, shooting stars
  void _paintCelestialBackground(Canvas canvas, Size size) {
    final rand = Random(777);

    // 1. Nebula Cloud Layer
    final nebula1 = Paint()
      ..shader = RadialGradient(
        colors: [
          theme.secondaryAccent.withAlpha(90),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.25, size.height * 0.25),
          radius: size.width * 0.65,
        ),
      );
    canvas.drawCircle(
        Offset(size.width * 0.25, size.height * 0.25), size.width * 0.65, nebula1);

    final nebula2 = Paint()
      ..shader = RadialGradient(
        colors: [
          theme.primaryAccent.withAlpha(85),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.75, size.height * 0.7),
          radius: size.width * 0.6,
        ),
      );
    canvas.drawCircle(
        Offset(size.width * 0.75, size.height * 0.7), size.width * 0.6, nebula2);

    // 2. Starfield (Dots + 4-Point Sparkles)
    final starPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 55; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final radius = 1.0 + rand.nextDouble() * 2.2;
      final isSparkle = (i % 6 == 0);

      starPaint.color = (i % 3 == 0 ? theme.primaryAccent : Colors.white)
          .withAlpha(90 + rand.nextInt(165));

      canvas.drawCircle(Offset(x, y), radius, starPaint);

      if (isSparkle) {
        final sparkPaint = Paint()
          ..color = theme.primaryAccent.withAlpha(200)
          ..strokeWidth = 1.2;
        canvas.drawLine(Offset(x - 7, y), Offset(x + 7, y), sparkPaint);
        canvas.drawLine(Offset(x, y - 7), Offset(x, y + 7), sparkPaint);
      }
    }

    // 3. Shooting Star Streak
    final meteorPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          theme.primaryAccent.withAlpha(220),
          Colors.transparent,
        ],
      ).createShader(
          Rect.fromLTWH(size.width * 0.5, size.height * 0.1, 100, 40));
    canvas.save();
    canvas.translate(size.width * 0.5, size.height * 0.1);
    canvas.rotate(-pi / 6);
    final meteorPath = Path()
      ..moveTo(0, 0)
      ..lineTo(-70, -2)
      ..lineTo(-70, 2)
      ..close();
    canvas.drawPath(meteorPath, meteorPaint);
    canvas.restore();
  }

  /// Earthy Pieces: Subterranean gem veins, crystal facet grids & mineral shimmer
  void _paintEarthyBackground(Canvas canvas, Size size) {
    final rand = Random(333);

    // 1. Cavern Crystal Core Glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          theme.primaryAccent.withAlpha(90),
          theme.secondaryAccent.withAlpha(45),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.5, size.height * 0.5),
          radius: size.width * 0.7,
        ),
      );
    canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.5), size.width * 0.7, glowPaint);

    // 2. Geometric Crystal Facet Lines
    final facetPaint = Paint()
      ..color = theme.secondaryAccent.withAlpha(50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final nodes = [
      Offset(size.width * 0.1, size.height * 0.15),
      Offset(size.width * 0.4, size.height * 0.08),
      Offset(size.width * 0.85, size.height * 0.18),
      Offset(size.width * 0.9, size.height * 0.6),
      Offset(size.width * 0.75, size.height * 0.85),
      Offset(size.width * 0.2, size.height * 0.82),
      Offset(size.width * 0.05, size.height * 0.5),
    ];

    for (int i = 0; i < nodes.length; i++) {
      final next = nodes[(i + 1) % nodes.length];
      canvas.drawLine(nodes[i], next, facetPaint);
      if (i % 2 == 0) {
        canvas.drawLine(nodes[i], nodes[(i + 3) % nodes.length], facetPaint);
      }
    }

    // 3. Gemstone Diamond Shapes
    final gemPaint = Paint()
      ..color = theme.primaryAccent.withAlpha(65)
      ..style = PaintingStyle.fill;
    final gemStroke = Paint()
      ..color = theme.secondaryAccent.withAlpha(110)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final gemCenters = [
      Offset(size.width * 0.2, size.height * 0.25),
      Offset(size.width * 0.8, size.height * 0.35),
      Offset(size.width * 0.7, size.height * 0.78),
      Offset(size.width * 0.15, size.height * 0.7),
    ];

    for (var center in gemCenters) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      final path = Path()
        ..moveTo(0, -15)
        ..lineTo(12, -4)
        ..lineTo(0, 16)
        ..lineTo(-12, -4)
        ..close();
      canvas.drawPath(path, gemPaint);
      canvas.drawPath(path, gemStroke);
      canvas.restore();
    }

    // 4. Quartz Shimmer Dust
    final dustPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 28; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      dustPaint.color = theme.highlightColor.withAlpha(50 + rand.nextInt(100));
      canvas.drawCircle(Offset(x, y), 1.2 + rand.nextDouble() * 2.2, dustPaint);
    }
  }

  /// Sorcery of the Ancestors: Cauldron smoke aura, magic circle & arcane sparks
  void _paintSorceryBackground(Canvas canvas, Size size) {
    final rand = Random(999);

    // 1. Cauldron Mystic Aura Swirl
    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          theme.primaryAccent.withAlpha(100),
          theme.secondaryAccent.withAlpha(50),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.5, size.height * 0.75),
          radius: size.width * 0.75,
        ),
      );
    canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.75), size.width * 0.75, auraPaint);

    // 2. Arcane Magic Circle
    final arcPaint = Paint()
      ..color = theme.secondaryAccent.withAlpha(60)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    final center = Offset(size.width * 0.5, size.height * 0.5);
    final radius = size.width * 0.42;

    canvas.drawCircle(center, radius, arcPaint);
    canvas.drawCircle(center, radius * 0.85, arcPaint);

    for (int i = 0; i < 8; i++) {
      final ang = i * pi / 4;
      final p1 = Offset(center.dx + cos(ang) * (radius * 0.85),
          center.dy + sin(ang) * (radius * 0.85));
      final p2 = Offset(center.dx + cos(ang) * radius,
          center.dy + sin(ang) * radius);
      canvas.drawLine(p1, p2, arcPaint);
    }

    // 3. Arcane Spark Particles
    final sparkPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 35; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final sizeRadius = 1.4 + rand.nextDouble() * 2.4;
      sparkPaint.color = (i % 2 == 0 ? theme.activeLineColor : theme.secondaryAccent)
          .withAlpha(70 + rand.nextInt(140));

      canvas.drawCircle(Offset(x, y), sizeRadius, sparkPaint);
    }
  }

  /// Scientific Findings: Lab blueprint grid, atomic orbital rings & circuit nodes
  void _paintScientificBackground(Canvas canvas, Size size) {
    final rand = Random(555);

    // 1. Tech Glow Core
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          theme.primaryAccent.withAlpha(85),
          theme.secondaryAccent.withAlpha(45),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.5, size.height * 0.35),
          radius: size.width * 0.65,
        ),
      );
    canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.35), size.width * 0.65, glowPaint);

    // 2. Tech Blueprint Grid
    final gridPaint = Paint()
      ..color = theme.primaryAccent.withAlpha(25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 3. Atomic Orbital Rings
    final orbitPaint = Paint()
      ..color = theme.secondaryAccent.withAlpha(70)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    canvas.save();
    canvas.translate(size.width * 0.5, size.height * 0.35);

    final ellipseRect =
        Rect.fromCenter(center: Offset.zero, width: 140, height: 45);

    canvas.drawOval(ellipseRect, orbitPaint);
    canvas.rotate(pi / 3);
    canvas.drawOval(ellipseRect, orbitPaint);
    canvas.rotate(pi / 3);
    canvas.drawOval(ellipseRect, orbitPaint);

    final nucleusPaint = Paint()
      ..color = theme.primaryAccent
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, 4.5, nucleusPaint);

    canvas.restore();

    // 4. Circuit Connector Dots & Nodes
    final nodePaint = Paint()
      ..color = theme.primaryAccent.withAlpha(160)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 18; i++) {
      final cx = (rand.nextInt((size.width / spacing).floor()) * spacing);
      final cy = (rand.nextInt((size.height / spacing).floor()) * spacing);
      canvas.drawCircle(Offset(cx, cy), 2.8, nodePaint);
    }
  }

  /// Animals of the World: Savanna sunset horizon glow, paw prints & wilderness dust
  void _paintAnimalsBackground(Canvas canvas, Size size) {
    final rand = Random(222);

    // 1. Savanna Sunset Horizon Glow
    final horizonPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          theme.primaryAccent.withAlpha(70),
          theme.secondaryAccent.withAlpha(40),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), horizonPaint);

    // 2. Stylized Paw Prints
    final pawFill = Paint()
      ..color = theme.primaryAccent.withAlpha(45)
      ..style = PaintingStyle.fill;
    final pawStroke = Paint()
      ..color = theme.secondaryAccent.withAlpha(85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final pawPositions = [
      Offset(size.width * 0.15, size.height * 0.2),
      Offset(size.width * 0.85, size.height * 0.28),
      Offset(size.width * 0.22, size.height * 0.65),
      Offset(size.width * 0.78, size.height * 0.78),
    ];

    for (var pos in pawPositions) {
      canvas.save();
      canvas.translate(pos.dx, pos.dy);

      final mainPad = Path()
        ..addOval(
            Rect.fromCenter(center: const Offset(0, 4), width: 18, height: 14));
      canvas.drawPath(mainPad, pawFill);
      canvas.drawPath(mainPad, pawStroke);

      final toeOffsets = [
        const Offset(-9, -8),
        const Offset(-3, -12),
        const Offset(3, -12),
        const Offset(9, -8),
      ];

      for (var toe in toeOffsets) {
        canvas.drawCircle(toe, 3.2, pawFill);
        canvas.drawCircle(toe, 3.2, pawStroke);
      }

      canvas.restore();
    }

    // 3. Savanna Dust Motes
    final dustPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 28; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      dustPaint.color = (i % 2 == 0 ? theme.primaryAccent : theme.highlightColor)
          .withAlpha(50 + rand.nextInt(100));

      canvas.drawCircle(Offset(x, y), 1.5 + rand.nextDouble() * 2.2, dustPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ThemeBackgroundPainter oldDelegate) {
    return oldDelegate.theme.categoryName != theme.categoryName;
  }
}

/// A Reusable Theme Background Widget that paints custom gradients and graphics reflecting each theme
class ThemeBackgroundWidget extends StatelessWidget {
  final CategoryTheme theme;
  final Widget child;

  const ThemeBackgroundWidget({
    super.key,
    required this.theme,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: theme.backgroundGradientColors,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        // Theme Custom Painter reflecting the specific theme
        Positioned.fill(
          child: CustomPaint(
            painter: ThemeBackgroundPainter(theme: theme),
          ),
        ),
        // Screen Content
        child,
      ],
    );
  }
}

/// Centralized ThemeData provider for Letters in the Myst
abstract class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.seedPurple,
        brightness: Brightness.dark,
        surface: AppColors.surfaceDark,
        primary: AppColors.primaryPink,
        secondary: AppColors.purpleLight,
      ),
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
      fontFamily: 'Roboto',
    );
  }
}
