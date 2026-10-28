import 'package:flutter/material.dart';

/// Centralized color palette for Letters in the Myst.
abstract class AppColors {
  // Main Backgrounds & Surfaces
  static const Color bgDeep = Color(0xFF10002B);
  static const Color bgSurface = Color(0xFF190933);
  static const Color bgContainer = Color(0xFF140032);
  static const Color surfaceDark = Color(0xFF240046);

  // Purple Accents
  static const Color purpleDark = Color(0xFF3C096C);
  static const Color purplePrimary = Color(0xFF5A189A);
  static const Color purpleAccent = Color(0xFF7B2CBF);
  static const Color purpleBright = Color(0xFF9D4EDD);
  static const Color purpleLight = Color(0xFFE0AAFF);

  // Gold / Amber / Hints
  static const Color gold = Color(0xFFFFD700);
  static const Color goldLight = Color(0xFFFFE57F);
  static const Color goldBgDark = Color(0xFF4A3B00);
  static const Color goldBgMedium = Color(0xFF5C4000);
  static const Color amber = Color(0xFFFF9E00);

  // Success / Emerald / Solved
  static const Color emerald = Color(0xFF74C69D);
  static const Color emeraldDark = Color(0xFF081C15);
  static const Color successBg = Color(0xFF1B4332);
  static const Color successBorder = Color(0xFF52B788);
  static const Color successContainer = Color(0xFF2D6A4F);
  static const Color successLight = Color(0xFFD8F3DC);

  // Letter Tile States
  static const Color tileNormalBg = Color(0xFF231942);
  static const Color tileNormalBorder = Color(0xFF5E548E);
  static const Color tileSelectedBg = Color(0xFF311B92);
  static const Color tileSelectedBorder = Color(0xFF7C4DFF);
  static const Color tileSolvedBg = Color(0xFF1E3A2B);
  static const Color tileSolvedBorder = Color(0xFF4CAF50);
  static const Color tileSolvedText = Color(0xFF81C784);
}

/// Centralized theme definitions and UI style helpers.
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.purplePrimary,
        brightness: Brightness.dark,
        surface: AppColors.bgDeep,
        primary: AppColors.purpleAccent,
        secondary: AppColors.purpleLight,
      ),
      scaffoldBackgroundColor: AppColors.bgDeep,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgSurface,
        elevation: 0,
        centerTitle: false,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.bgDeep,
      ),
      dividerColor: AppColors.purpleDark,
    );
  }

  // Common UI Styles & Component Decorations
  static BoxDecoration bannerDecoration = BoxDecoration(
    gradient: const LinearGradient(
      colors: [AppColors.purpleDark, AppColors.purplePrimary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: AppColors.purpleAccent),
    boxShadow: [
      BoxShadow(
        color: AppColors.purplePrimary.withAlpha(120),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ],
  );

  static BoxDecoration badgeDecoration({Color color = AppColors.gold}) {
    return BoxDecoration(
      color: color.withAlpha(50),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color),
    );
  }

  static ButtonStyle emeraldButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.emerald,
    foregroundColor: AppColors.emeraldDark,
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
    elevation: 4,
  );

  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.purpleAccent,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );
}
