import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.darkBrown,
      brightness: Brightness.light,
      surface: AppColors.cream,
      onSurface: AppColors.darkBrown,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: AppColors.cream,
      surfaceContainer: AppColors.wheat,
      surfaceContainerHigh: AppColors.oatmeal,
      primary: AppColors.darkBrown,
      onPrimary: Colors.white,
      secondary: AppColors.warmAccent,
      onSecondary: Colors.white,
      tertiary: AppColors.honeyGold,
      error: const Color(0xFFBA1A1A),
    );

    return _buildTheme(colorScheme);
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.darkBrown,
      brightness: Brightness.dark,
      surface: AppColors.darkSurface,
      onSurface: AppColors.wheat,
      surfaceContainerLowest: const Color(0xFF110E0C),
      surfaceContainerLow: AppColors.darkSurface,
      surfaceContainer: AppColors.darkSurfaceContainer,
      surfaceContainerHigh: AppColors.darkSurfaceContainerHigh,
      primary: AppColors.warmAccent,
      onPrimary: AppColors.darkSurface,
      secondary: AppColors.honeyGold,
      onSecondary: AppColors.darkSurface,
      tertiary: AppColors.lightBrown,
      error: const Color(0xFFFFB4AB),
    );

    return _buildTheme(colorScheme);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final textTheme = _buildTextTheme(colorScheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLowest,
        elevation: 1,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        indicatorColor: colorScheme.secondaryContainer,
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.lato(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        elevation: 2,
        height: 64,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.surfaceContainerHigh,
        thumbColor: colorScheme.primary,
        overlayColor: colorScheme.primary.withValues(alpha: 0.12),
        valueIndicatorColor: colorScheme.primary,
        valueIndicatorTextStyle: TextStyle(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
        showValueIndicator: ShowValueIndicator.onlyForContinuous,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        thickness: 1,
      ),
    );
  }

  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    final headingFont = GoogleFonts.playfairDisplayTextTheme();
    final bodyFont = GoogleFonts.latoTextTheme();

    return TextTheme(
      headlineLarge: headingFont.headlineLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: headingFont.headlineMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: headingFont.headlineSmall?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: headingFont.titleLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: bodyFont.titleMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: bodyFont.titleSmall?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: bodyFont.bodyLarge?.copyWith(
        color: colorScheme.onSurface,
      ),
      bodyMedium: bodyFont.bodyMedium?.copyWith(
        color: colorScheme.onSurface,
      ),
      bodySmall: bodyFont.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      labelLarge: bodyFont.labelLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: bodyFont.labelMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      labelSmall: bodyFont.labelSmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}
