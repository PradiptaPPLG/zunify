/// Breakpoints and responsive helpers for Zunify.
/// Mobile < 600, Tablet 600–1024, Desktop > 1024
library;

import 'package:flutter/material.dart';

enum ScreenSize { mobile, tablet, desktop }

abstract final class ScreenBreakpoints {
  static const double tablet = 600;
  static const double desktop = 1024;
  static const double maxContentWidth = 1280;

  static ScreenSize of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= desktop) return ScreenSize.desktop;
    if (width >= tablet) return ScreenSize.tablet;
    return ScreenSize.mobile;
  }

  static bool isMobile(BuildContext context) =>
      of(context) == ScreenSize.mobile;
  static bool isTablet(BuildContext context) =>
      of(context) == ScreenSize.tablet;
  static bool isDesktop(BuildContext context) =>
      of(context) == ScreenSize.desktop;
  static bool isTabletOrDesktop(BuildContext context) =>
      of(context) != ScreenSize.mobile;
}

/// Build widget differently per screen size.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final Widget Function(BuildContext, BoxConstraints) mobile;
  final Widget Function(BuildContext, BoxConstraints)? tablet;
  final Widget Function(BuildContext, BoxConstraints)? desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = ScreenBreakpoints.of(context);
        return switch (size) {
          ScreenSize.desktop => desktop?.call(context, constraints) ??
              tablet?.call(context, constraints) ??
              mobile(context, constraints),
          ScreenSize.tablet => tablet?.call(context, constraints) ??
              mobile(context, constraints),
          ScreenSize.mobile => mobile(context, constraints),
        };
      },
    );
  }
}

/// Constrain content to max width on large screens.
class ContentWidth extends StatelessWidget {
  const ContentWidth({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: ScreenBreakpoints.maxContentWidth,
        ),
        child: padding != null ? Padding(padding: padding!, child: child) : child,
      ),
    );
  }
}
