import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppThemeId { violet, forest, ocean }

/// One selectable theme: an accent color plus an optional photo background.
/// [scrimColor] and [scrimAlphas] describe the dark gradient laid over the
/// photo so text stays readable.
class AppThemePreset {
  const AppThemePreset({
    required this.id,
    required this.label,
    required this.seedColor,
    required this.previewGradient,
    this.backgroundAsset,
    this.scrimColor = Colors.black,
    this.scrimAlphas = const [0.35, 0.15, 0.45],
    this.backgroundAlignment = Alignment.center,
  });

  final AppThemeId id;
  final String label;
  final Color seedColor;
  final List<Color> previewGradient;
  final String? backgroundAsset;
  final Color scrimColor;
  final List<double> scrimAlphas;
  final Alignment backgroundAlignment;

  bool get hasPhotoBackground => backgroundAsset != null;
}

const appThemePresets = [
  AppThemePreset(
    id: AppThemeId.violet,
    label: 'Violet',
    seedColor: Color(0xFF7C5CFF),
    previewGradient: [Color(0xFF6C63FF), Color(0xFFEC72C1)],
    backgroundAsset: 'assets/images/sunset_background.png',
    scrimColor: Color(0xFF241344),
    scrimAlphas: [0.6, 0.4, 0.75],
    backgroundAlignment: Alignment.bottomCenter,
  ),
  AppThemePreset(
    id: AppThemeId.forest,
    label: 'Forest',
    seedColor: Color(0xFF2FA36B),
    previewGradient: [Color(0xFF0B3D2E), Color(0xFF2FA36B)],
    backgroundAsset: 'assets/images/forest_background.png',
  ),
  AppThemePreset(
    id: AppThemeId.ocean,
    label: 'Ocean',
    seedColor: Color(0xFF0288D1),
    previewGradient: [Color(0xFF0288D1), Color(0xFF26E5C6)],
    backgroundAsset: 'assets/images/fjord_background.png',
    scrimColor: Color(0xFF071A33),
    scrimAlphas: [0.6, 0.35, 0.7],
    backgroundAlignment: Alignment.bottomCenter,
  ),
];

AppThemePreset presetById(AppThemeId id) =>
    appThemePresets.firstWhere((preset) => preset.id == id);

/// Builds the full Material 3 [ThemeData] (colors, fonts, buttons, cards,
/// inputs, dialogs) from one seed color, so the whole app stays consistent.
/// With [translucentSurfaces] cards become see-through "glass" for photo themes.
ThemeData buildAppTheme(
  Color seedColor,
  Brightness brightness, {
  required bool translucentSurfaces,
}) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: brightness,
  );
  final base = ThemeData(colorScheme: colorScheme, useMaterial3: true);
  final textTheme = GoogleFonts.poppinsTextTheme(base.textTheme);

  final cardColor =
      translucentSurfaces ? Colors.black.withValues(alpha: 0.32) : null;

  return base.copyWith(
    textTheme: textTheme,
    scaffoldBackgroundColor: colorScheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      elevation: translucentSurfaces ? 0 : 4,
      color: cardColor,
      shadowColor: colorScheme.primary.withValues(alpha: 0.25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: translucentSurfaces
            ? BorderSide(color: Colors.white.withValues(alpha: 0.18))
            : BorderSide.none,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 3,
        shadowColor: colorScheme.primary.withValues(alpha: 0.5),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.onSurfaceVariant,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
