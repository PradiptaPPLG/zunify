/// Spacing, radius, and shadow tokens.
library;

import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double huge = 48;

  // Screen horizontal padding
  static const double screenPadding = 20;
  static const double screenPaddingTablet = 28;
  static const double screenPaddingDesktop = 40;

  // Section gaps
  static const double sectionGap = 36;
  static const double cardGap = 12;
  static const double listGap = 4;
}

abstract final class AppRadius {
  static const double small = 6;
  static const double input = 10;
  static const double normal = 10;
  static const double card = 12;
  static const double artwork = 10;
  static const double large = 14;
  static const double modal = 18;
  static const double chip = 8;

  static BorderRadius get smallBR => BorderRadius.circular(small);
  static BorderRadius get inputBR => BorderRadius.circular(input);
  static BorderRadius get normalBR => BorderRadius.circular(normal);
  static BorderRadius get cardBR => BorderRadius.circular(card);
  static BorderRadius get artworkBR => BorderRadius.circular(artwork);
  static BorderRadius get largeBR => BorderRadius.circular(large);
  static BorderRadius get modalBR => BorderRadius.vertical(
    top: Radius.circular(modal),
  );
  static BorderRadius get chipBR => BorderRadius.circular(chip);
}

abstract final class AppShadows {
  // Used only where elevation matters: mini player, modals, dropdowns
  static List<BoxShadow> get miniPlayer => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, -2),
    ),
  ];

  static List<BoxShadow> get modal => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.10),
      blurRadius: 24,
      offset: const Offset(0, -4),
    ),
  ];

  static List<BoxShadow> get card => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get elevated => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];
}
