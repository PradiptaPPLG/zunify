import 'package:flutter/material.dart';

class ZunifyColors extends ThemeExtension<ZunifyColors> {
  final Color background;
  final Color backgroundAlt;
  final Color surface;
  final Color surfaceSecondary;
  final Color border;
  final Color borderSubtle;
  final Color lavender;
  final Color lavenderLight;
  final Color lavenderMuted;
  final Color blue;
  final Color blueLight;
  final Color pink;
  final Color pinkLight;
  final Color green;
  final Color greenLight;
  final Color yellow;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textOnAccent;
  final Color error;
  final Color errorLight;
  final Color success;
  final Color successLight;
  final Color overlay;
  final Color overlayMedium;
  final LinearGradient gradientPrimary;
  final LinearGradient gradientSubtle;

  const ZunifyColors({
    required this.background,
    required this.backgroundAlt,
    required this.surface,
    required this.surfaceSecondary,
    required this.border,
    required this.borderSubtle,
    required this.lavender,
    required this.lavenderLight,
    required this.lavenderMuted,
    required this.blue,
    required this.blueLight,
    required this.pink,
    required this.pinkLight,
    required this.green,
    required this.greenLight,
    required this.yellow,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textOnAccent,
    required this.error,
    required this.errorLight,
    required this.success,
    required this.successLight,
    required this.overlay,
    required this.overlayMedium,
    required this.gradientPrimary,
    required this.gradientSubtle,
  });

  @override
  ThemeExtension<ZunifyColors> copyWith({
    Color? background,
    Color? backgroundAlt,
    Color? surface,
    Color? surfaceSecondary,
    Color? border,
    Color? borderSubtle,
    Color? lavender,
    Color? lavenderLight,
    Color? lavenderMuted,
    Color? blue,
    Color? blueLight,
    Color? pink,
    Color? pinkLight,
    Color? green,
    Color? greenLight,
    Color? yellow,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textOnAccent,
    Color? error,
    Color? errorLight,
    Color? success,
    Color? successLight,
    Color? overlay,
    Color? overlayMedium,
    LinearGradient? gradientPrimary,
    LinearGradient? gradientSubtle,
  }) {
    return ZunifyColors(
      background: background ?? this.background,
      backgroundAlt: backgroundAlt ?? this.backgroundAlt,
      surface: surface ?? this.surface,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      border: border ?? this.border,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      lavender: lavender ?? this.lavender,
      lavenderLight: lavenderLight ?? this.lavenderLight,
      lavenderMuted: lavenderMuted ?? this.lavenderMuted,
      blue: blue ?? this.blue,
      blueLight: blueLight ?? this.blueLight,
      pink: pink ?? this.pink,
      pinkLight: pinkLight ?? this.pinkLight,
      green: green ?? this.green,
      greenLight: greenLight ?? this.greenLight,
      yellow: yellow ?? this.yellow,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textOnAccent: textOnAccent ?? this.textOnAccent,
      error: error ?? this.error,
      errorLight: errorLight ?? this.errorLight,
      success: success ?? this.success,
      successLight: successLight ?? this.successLight,
      overlay: overlay ?? this.overlay,
      overlayMedium: overlayMedium ?? this.overlayMedium,
      gradientPrimary: gradientPrimary ?? this.gradientPrimary,
      gradientSubtle: gradientSubtle ?? this.gradientSubtle,
    );
  }

  @override
  ThemeExtension<ZunifyColors> lerp(ThemeExtension<ZunifyColors>? other, double t) {
    if (other is! ZunifyColors) return this;
    return ZunifyColors(
      background: Color.lerp(background, other.background, t)!,
      backgroundAlt: Color.lerp(backgroundAlt, other.backgroundAlt, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSecondary: Color.lerp(surfaceSecondary, other.surfaceSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      lavender: Color.lerp(lavender, other.lavender, t)!,
      lavenderLight: Color.lerp(lavenderLight, other.lavenderLight, t)!,
      lavenderMuted: Color.lerp(lavenderMuted, other.lavenderMuted, t)!,
      blue: Color.lerp(blue, other.blue, t)!,
      blueLight: Color.lerp(blueLight, other.blueLight, t)!,
      pink: Color.lerp(pink, other.pink, t)!,
      pinkLight: Color.lerp(pinkLight, other.pinkLight, t)!,
      green: Color.lerp(green, other.green, t)!,
      greenLight: Color.lerp(greenLight, other.greenLight, t)!,
      yellow: Color.lerp(yellow, other.yellow, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textOnAccent: Color.lerp(textOnAccent, other.textOnAccent, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorLight: Color.lerp(errorLight, other.errorLight, t)!,
      success: Color.lerp(success, other.success, t)!,
      successLight: Color.lerp(successLight, other.successLight, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
      overlayMedium: Color.lerp(overlayMedium, other.overlayMedium, t)!,
      gradientPrimary: other.gradientPrimary,
      gradientSubtle: other.gradientSubtle,
    );
  }
}

extension ZunifyContext on BuildContext {
  ZunifyColors get colors => Theme.of(this).extension<ZunifyColors>()!;
}

abstract final class AppColors {
  static const ZunifyColors light = ZunifyColors(
    background: Color(0xFFFAF9FC),
    backgroundAlt: Color(0xFFF6F5F8),
    surface: Color(0xFFFFFFFF),
    surfaceSecondary: Color(0xFFF3F2F6),
    border: Color(0xFFE8E6EC),
    borderSubtle: Color(0xFFF0EEF4),
    lavender: Color(0xFFA78BFA),
    lavenderLight: Color(0xFFEDE9FF),
    lavenderMuted: Color(0xFFD4C6FC),
    blue: Color(0xFF93C5FD),
    blueLight: Color(0xFFE0EFFE),
    pink: Color(0xFFF9A8D4),
    pinkLight: Color(0xFFFDE8F3),
    green: Color(0xFF86EFAC),
    greenLight: Color(0xFFDCFCE7),
    yellow: Color(0xFFFDE68A),
    textPrimary: Color(0xFF27272A),
    textSecondary: Color(0xFF71717A),
    textMuted: Color(0xFFA1A1AA),
    textOnAccent: Color(0xFFFFFFFF),
    error: Color(0xFFF87171),
    errorLight: Color(0xFFFEE2E2),
    success: Color(0xFF4ADE80),
    successLight: Color(0xFFF0FDF4),
    overlay: Color(0x0F000000),
    overlayMedium: Color(0x1A000000),
    gradientPrimary: LinearGradient(
      colors: [Color(0xFFA78BFA), Color(0xFFF9A8D4)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    gradientSubtle: LinearGradient(
      colors: [Color(0xFFEDE9FF), Color(0xFFFDE8F3)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static const ZunifyColors dark = ZunifyColors(
    background: Color(0xFF09090B),
    backgroundAlt: Color(0xFF18181B),
    surface: Color(0xFF121214),
    surfaceSecondary: Color(0xFF1F1F22),
    border: Color(0xFF27272A),
    borderSubtle: Color(0xFF3F3F46),
    lavender: Color(0xFFA78BFA),
    lavenderLight: Color(0xFF2E244B),
    lavenderMuted: Color(0xFF8B5CF6),
    blue: Color(0xFF93C5FD),
    blueLight: Color(0xFF1E3A8A),
    pink: Color(0xFFF9A8D4),
    pinkLight: Color(0xFF831843),
    green: Color(0xFF86EFAC),
    greenLight: Color(0xFF14532D),
    yellow: Color(0xFFFDE68A),
    textPrimary: Color(0xFFFAFAFA),
    textSecondary: Color(0xFFA1A1AA),
    textMuted: Color(0xFF71717A),
    textOnAccent: Color(0xFFFFFFFF),
    error: Color(0xFFF87171),
    errorLight: Color(0xFF7F1D1D),
    success: Color(0xFF4ADE80),
    successLight: Color(0xFF14532D),
    overlay: Color(0x20FFFFFF),
    overlayMedium: Color(0x40FFFFFF),
    gradientPrimary: LinearGradient(
      colors: [Color(0xFFA78BFA), Color(0xFFF9A8D4)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    gradientSubtle: LinearGradient(
      colors: [Color(0xFF2E244B), Color(0xFF831843)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );
}
