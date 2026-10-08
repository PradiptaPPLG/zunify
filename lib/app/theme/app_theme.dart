import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light, AppColors.light);
  static ThemeData get dark => _build(Brightness.dark, AppColors.dark);

  static ThemeData _build(Brightness brightness, ZunifyColors colors) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: colors.lavender,
      onPrimary: colors.textOnAccent,
      primaryContainer: colors.lavenderLight,
      onPrimaryContainer: colors.textPrimary,
      secondary: colors.blue,
      onSecondary: colors.textOnAccent,
      secondaryContainer: colors.blueLight,
      onSecondaryContainer: colors.textPrimary,
      tertiary: colors.pink,
      onTertiary: colors.textOnAccent,
      tertiaryContainer: colors.pinkLight,
      onTertiaryContainer: colors.textPrimary,
      error: colors.error,
      onError: colors.textOnAccent,
      errorContainer: colors.errorLight,
      onErrorContainer: colors.textPrimary,
      surface: colors.surface,
      onSurface: colors.textPrimary,
      surfaceContainerHighest: colors.surfaceSecondary,
      onSurfaceVariant: colors.textSecondary,
      outline: colors.border,
      outlineVariant: colors.borderSubtle,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: colors.textPrimary,
      onInverseSurface: colors.surface,
      inversePrimary: colors.lavenderMuted,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      extensions: [colors],
      
      // Typography
      fontFamily: AppTypography.fontFamily,
      textTheme: TextTheme(
        displayLarge: AppTypography.display.copyWith(color: colors.textPrimary),
        headlineLarge: AppTypography.heading1.copyWith(color: colors.textPrimary),
        headlineMedium: AppTypography.heading2.copyWith(color: colors.textPrimary),
        headlineSmall: AppTypography.heading3.copyWith(color: colors.textPrimary),
        titleLarge: AppTypography.sectionTitle.copyWith(color: colors.textPrimary),
        titleMedium: AppTypography.bodyMedium.copyWith(color: colors.textPrimary),
        titleSmall: AppTypography.secondaryMedium.copyWith(color: colors.textPrimary),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: colors.textPrimary),
        bodyMedium: AppTypography.body.copyWith(color: colors.textPrimary),
        bodySmall: AppTypography.secondary.copyWith(color: colors.textSecondary),
        labelLarge: AppTypography.bodyMedium.copyWith(color: colors.textPrimary),
        labelMedium: AppTypography.metadataMedium.copyWith(color: colors.textSecondary),
        labelSmall: AppTypography.label.copyWith(color: colors.textMuted),
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: brightness == Brightness.light ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
        titleTextStyle: AppTypography.heading3.copyWith(color: colors.textPrimary),
        iconTheme: IconThemeData(color: colors.textPrimary),
        actionsIconTheme: IconThemeData(color: colors.textPrimary),
      ),

      // BottomNavigationBar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colors.lavenderLight,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colors.lavender, size: 22);
          }
          return IconThemeData(color: colors.textMuted, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.metadata.copyWith(
              color: colors.lavender,
              fontWeight: FontWeight.w600,
            );
          }
          return AppTypography.metadata.copyWith(color: colors.textMuted);
        }),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),

      // NavigationRail
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colors.surface,
        indicatorColor: colors.lavenderLight,
        selectedIconTheme: IconThemeData(color: colors.lavender, size: 22),
        unselectedIconTheme: IconThemeData(color: colors.textMuted, size: 22),
        selectedLabelTextStyle: TextStyle(
          fontFamily: AppTypography.fontFamily,
          color: colors.lavender,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: TextStyle(
          fontFamily: AppTypography.fontFamily,
          color: colors.textMuted,
          fontSize: 12,
        ),
        useIndicator: true,
        minWidth: 68,
        elevation: 0,
      ),

      // Card
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardBR,
          side: BorderSide(color: colors.border, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),

      // Input / Search
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceSecondary,
        border: OutlineInputBorder(
          borderRadius: AppRadius.inputBR,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBR,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBR,
          borderSide: BorderSide(color: colors.lavender, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        hintStyle: AppTypography.body.copyWith(color: colors.textMuted),
      ),

      // Buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.lavender,
          foregroundColor: colors.textOnAccent,
          textStyle: AppTypography.bodyMedium,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.normalBR),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.sm,
          ),
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.lavender,
          side: BorderSide(color: colors.lavender),
          textStyle: AppTypography.bodyMedium,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.normalBR),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.sm,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.lavender,
          textStyle: AppTypography.bodyMedium,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.normalBR),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colors.textSecondary,
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: 0.5,
        space: 0,
      ),

      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: colors.lavender,
        inactiveTrackColor: colors.border,
        thumbColor: colors.lavender,
        overlayColor: colors.lavender.withValues(alpha: 0.12),
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.textPrimary,
        contentTextStyle: AppTypography.body.copyWith(color: colors.surface),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.normalBR),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),

      // BottomSheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.modal)),
        ),
        elevation: 0,
        showDragHandle: true,
        dragHandleColor: colors.border,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.largeBR),
        titleTextStyle: AppTypography.heading3.copyWith(color: colors.textPrimary),
        contentTextStyle: AppTypography.body.copyWith(color: colors.textSecondary),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceSecondary,
        selectedColor: colors.lavenderLight,
        labelStyle: AppTypography.secondary.copyWith(color: colors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.chipBR,
          side: BorderSide(color: colors.border, width: 0.5),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        elevation: 0,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.lavender;
          }
          return colors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.lavenderLight;
          }
          return colors.surfaceSecondary;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          return colors.border;
        }),
      ),

      // ListTile
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xxs,
        ),
        minVerticalPadding: AppSpacing.xxs,
        dense: false,
      ),

      // Progress indicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.lavender,
        linearTrackColor: colors.border,
      ),

      // TabBar
      tabBarTheme: TabBarThemeData(
        labelColor: colors.lavender,
        unselectedLabelColor: colors.textMuted,
        labelStyle: AppTypography.bodyMedium,
        unselectedLabelStyle: AppTypography.body,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: colors.lavender, width: 2),
          borderRadius: AppRadius.smallBR,
        ),
        dividerColor: colors.border,
        dividerHeight: 0.5,
      ),

      // PageTransitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
