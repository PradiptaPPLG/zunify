/// go_router configuration for Zunify.
/// Adaptive shell: bottom nav (mobile) / nav rail (tablet) / sidebar (desktop).
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/responsive/responsive.dart';
import '../../features/home/home_screen.dart';
import '../../features/library/library_screen.dart';
import '../../features/player/player_screen.dart';
import '../../features/playlists/playlist_detail_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../shared/widgets/mini_player.dart';
import '../theme/theme.dart';
import 'routes.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    ShellRoute(
      builder: (context, state, child) => _AppShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.search,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SearchScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.library,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: LibraryScreen(),
          ),
          routes: [
            GoRoute(
              path: 'playlists/:id',
              builder: (context, state) => PlaylistDetailScreen(
                playlistId: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.settings,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.player,
      builder: (context, state) => const PlayerScreen(),
    ),
  ],
);

// ─── Navigation items ─────────────────────────────────────────────────────────

class _NavItem {
  const _NavItem({
    required this.path,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final String path;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

const _navItems = [
  _NavItem(
    path: AppRoutes.home,
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
    label: 'Home',
  ),
  _NavItem(
    path: AppRoutes.search,
    icon: Icons.search,
    selectedIcon: Icons.search,
    label: 'Search',
  ),
  _NavItem(
    path: AppRoutes.library,
    icon: Icons.library_music_outlined,
    selectedIcon: Icons.library_music,
    label: 'Library',
  ),
  _NavItem(
    path: AppRoutes.settings,
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    label: 'Settings',
  ),
];

// ─── App Shell ────────────────────────────────────────────────────────────────

class _AppShell extends StatelessWidget {
  const _AppShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (context, _) => _MobileShell(child: child),
      tablet: (context, _) => _TabletShell(child: child),
      desktop: (context, _) => _DesktopShell(child: child),
    );
  }
}

// ─── Mobile Shell ─────────────────────────────────────────────────────────────

class _MobileShell extends StatelessWidget {
  const _MobileShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _navItems.indexWhere(
      (item) => location.startsWith(item.path),
    );
    final navIndex = currentIndex == -1 ? 0 : currentIndex;

    return Scaffold(
      body: child,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MiniPlayer(
            onTap: () => context.push(AppRoutes.player),
          ),
          NavigationBar(
            selectedIndex: navIndex,
            onDestinationSelected: (i) => context.go(_navItems[i].path),
            destinations: _navItems
                .map((item) => NavigationDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.selectedIcon),
                      label: item.label,
                    ))
                .toList(),
            height: 64,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          ),
        ],
      ),
    );
  }
}

// ─── Tablet Shell ─────────────────────────────────────────────────────────────

class _TabletShell extends StatelessWidget {
  const _TabletShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _navItems.indexWhere(
      (item) => location.startsWith(item.path),
    );
    final navIndex = currentIndex == -1 ? 0 : currentIndex;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: navIndex,
            onDestinationSelected: (i) => context.go(_navItems[i].path),
            labelType: NavigationRailLabelType.selected,
            destinations: _navItems
                .map((item) => NavigationRailDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.selectedIcon),
                      label: Text(item.label),
                    ))
                .toList(),
          ),
          const VerticalDivider(width: 1, thickness: 0.5),
          Expanded(
            child: Column(
              children: [
                Expanded(child: child),
                MiniPlayer(onTap: () => context.push(AppRoutes.player)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Desktop Shell ────────────────────────────────────────────────────────────

class _DesktopShell extends StatelessWidget {
  const _DesktopShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _navItems.indexWhere(
      (item) => location.startsWith(item.path),
    );
    final navIndex = currentIndex == -1 ? 0 : currentIndex;

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 220,
            decoration: BoxDecoration(
              color: context.colors.surface,
              border: Border(
                right: BorderSide(color: context.colors.border, width: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Zunify',
                    style: AppTypography.heading3.copyWith(
                      color: context.colors.lavender,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ..._navItems.asMap().entries.map((entry) {
                  final i = entry.key;
                  final item = entry.value;
                  final isSelected = i == navIndex;
                  return _SidebarItem(
                    item: item,
                    isSelected: isSelected,
                    onTap: () => context.go(item.path),
                  );
                }),
                const Spacer(),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Column(
              children: [
                Expanded(child: child),
                MiniPlayer(onTap: () => context.push(AppRoutes.player)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.lavenderLight : Colors.transparent,
          borderRadius: AppRadius.normalBR,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? item.selectedIcon : item.icon,
              color: isSelected ? context.colors.lavender : context.colors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              item.label,
              style: AppTypography.bodyMedium.copyWith(
                color: isSelected ? context.colors.lavender : context.colors.textSecondary,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
