import 'package:flutter/material.dart';

/// Centralized color palette for Letters in the Myst
abstract class AppColors {
  // --- Backgrounds & Surfaces ---
  static const Color scaffoldBackground = Color(0xFF10002B);
  static const Color appBarBackground = Color(0xFF190933);
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
  static const Color bubbleTileBorder = Color(0xFF8A50C0);

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
  static List<BoxShadow> glow(Color color, {double blurRadius = 12, double spreadRadius = 0}) {
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
