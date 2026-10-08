/// Home Screen — greeting, recently played, trending, playlists.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../app/router/routes.dart';
import '../../app/theme/theme.dart';
import '../../core/responsive/responsive.dart';
import '../../domain/entities/entities.dart';
import '../../features/player/player_notifier.dart';
import '../../features/playlists/playlists_provider.dart';
import '../../shared/widgets/album_artwork.dart';
import '../../shared/widgets/music_list_tile.dart';
import '../../shared/widgets/states.dart';
import '../../shared/widgets/track_options.dart';
import 'home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = ScreenBreakpoints.isMobile(context);
    final padding = isMobile
        ? AppSpacing.screenPadding
        : AppSpacing.screenPaddingTablet;

    return Scaffold(
      backgroundColor: context.colors.background,
      body: CustomScrollView(
        slivers: [
          _HomeAppBar(padding: padding),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppSpacing.xl),
                _RecentlyPlayedSection(),
                const SizedBox(height: AppSpacing.sectionGap),
                _TrendingSection(),
                const SizedBox(height: AppSpacing.sectionGap),
                _PlaylistsSection(),
                const SizedBox(height: AppSpacing.huge),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar({required this.padding});
  final double padding;

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: context.colors.background,
      surfaceTintColor: Colors.transparent,
      floating: true,
      snap: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      expandedHeight: 120,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: EdgeInsets.fromLTRB(padding, 52, padding, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting(),
                style: AppTypography.metadata.copyWith(
                  color: context.colors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              ShaderMask(
                shaderCallback: (bounds) => context.colors.gradientPrimary.createShader(bounds),
                child: Text(
                  'Zunify',
                  style: AppTypography.heading1.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.md),
          child: IconButton(
            onPressed: () => context.go(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ─── Search Entry ──────────────────────────────────────────────────────────────

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(AppRoutes.search),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: context.colors.surfaceSecondary,
          borderRadius: AppRadius.inputBR,
        ),
        child: Row(
          children: [
            const SizedBox(width: AppSpacing.md),
            Icon(Icons.search, color: context.colors.textMuted, size: 20),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Search songs, artists, albums...',
              style: AppTypography.body.copyWith(color: context.colors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Recently Played ──────────────────────────────────────────────────────────

class _RecentlyPlayedSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);

    return history.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (entries) {
        if (entries.isEmpty) return const SizedBox.shrink();
        final tracks = entries.map((e) => e.track).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Recently Played',
              actionLabel: 'See all',
              onAction: () => context.go(AppRoutes.history),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: tracks.take(10).length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (_, i) => _RecentCard(track: tracks[i]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RecentCard extends ConsumerWidget {
  const _RecentCard({required this.track});
  final Track track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(playerProvider.notifier).playTrack(track),
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            AlbumArtwork(url: track.thumbnailUrl, size: 64),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              track.title,
              style: AppTypography.metadata.copyWith(
                color: context.colors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Trending ─────────────────────────────────────────────────────────────────

class _TrendingSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trending = ref.watch(trendingProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Trending',
          actionLabel: 'See all',
          onAction: () => context.go(AppRoutes.search),
        ),
        const SizedBox(height: AppSpacing.xs),
        trending.when(
          loading: () => Column(
            children: List.generate(
              4,
              (_) => const ShimmerTile(),
            ),
          ),
          error: (e, _) => ErrorState(
            message: 'Couldn\'t load trending music.',
            onRetry: () => ref.invalidate(trendingProvider),
          ),
          data: (results) {
            if (results.isEmpty) {
              return const EmptyState(
                title: 'Nothing trending yet',
                subtitle: 'Check back soon.',
              );
            }
            return Column(
              children: results.take(8).map((r) {
                final track = r.toTrack();
                return MusicListTile(
                  track: track,
                  onTap: () => ref.read(playerProvider.notifier).playTrack(
                    track,
                    queue: results.take(8).map((r) => r.toTrack()).toList(),
                  ),
                  onMore: () => showTrackOptions(context, track),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

// ─── Playlists ────────────────────────────────────────────────────────────────

class _PlaylistsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Your Playlists',
          actionLabel: 'See all',
          onAction: () => context.go(AppRoutes.library),
        ),
        const SizedBox(height: AppSpacing.md),
        playlists.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (list) {
            if (list.isEmpty) {
              return GestureDetector(
                onTap: () => showCreatePlaylistDialog(context),
                child: Container(
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: context.colors.gradientSubtle,
                    borderRadius: AppRadius.cardBR,
                    border: Border.all(
                      color: context.colors.lavenderLight,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add,
                          color: context.colors.lavender,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Create your first playlist',
                        style: AppTypography.bodyMedium.copyWith(
                          color: context.colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: list.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (_, i) => _PlaylistCard(playlist: list[i]),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  const _PlaylistCard({required this.playlist});
  final Playlist playlist;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(AppRoutes.playlistDetail(playlist.id)),
      child: SizedBox(
        width: 88,
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: context.colors.lavenderLight,
                borderRadius: AppRadius.artworkBR,
              ),
              child: Icon(
                Icons.queue_music,
                color: context.colors.lavender,
                size: 28,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              playlist.name,
              style: AppTypography.metadata.copyWith(
                color: context.colors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            Text(
              '${playlist.trackCount} songs',
              style: AppTypography.label.copyWith(
                color: context.colors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
