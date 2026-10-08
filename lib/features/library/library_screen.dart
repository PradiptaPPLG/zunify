/// Library Screen — Favorites, Recently Played, Playlists.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/router/routes.dart';
import '../../app/theme/theme.dart';
import '../../domain/entities/entities.dart';
import '../../features/library/favorites_provider.dart';
import '../../features/home/home_provider.dart';
import '../../features/player/player_notifier.dart';
import '../../features/player/player_state.dart' as ps;
import '../../features/playlists/playlists_provider.dart';
import '../../shared/widgets/album_artwork.dart';
import '../../shared/widgets/music_list_tile.dart';
import '../../shared/widgets/states.dart';
import '../../shared/widgets/track_options.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Library'),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(text: 'Playlists'),
            Tab(text: 'Favorites'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: const [
          _PlaylistsTab(),
          _FavoritesTab(),
          _HistoryTab(),
        ],
      ),
    );
  }
}

// ─── Playlists Tab ────────────────────────────────────────────────────────────

class _PlaylistsTab extends ConsumerWidget {
  const _PlaylistsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistsProvider);

    return playlists.when(
      loading: () => ListView(
        children: List.generate(4, (_) => const ShimmerTile()),
      ),
      error: (e, _) => ErrorState(
        message: e.toString(),
        onRetry: () => ref.invalidate(playlistsProvider),
      ),
      data: (list) => Column(
        children: [
          // Create playlist button
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: OutlinedButton.icon(
              onPressed: () => showCreatePlaylistDialog(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New Playlist'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
          ),
          if (list.isEmpty)
            Expanded(
              child: EmptyState(
                title: 'No playlists yet',
                subtitle:
                    'Create playlists to organize your favorite music.',
                icon: Icons.queue_music_outlined,
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) => _PlaylistTile(playlist: list[i]),
              ),
            ),
        ],
      ),
    );
  }
}

class _PlaylistTile extends ConsumerWidget {
  const _PlaylistTile({required this.playlist});
  final Playlist playlist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xxs,
      ),
      leading: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: context.colors.lavenderLight,
          borderRadius: AppRadius.artworkBR,
        ),
        child: Icon(
          Icons.queue_music,
          color: context.colors.lavender,
          size: 22,
        ),
      ),
      title: Text(playlist.name, style: AppTypography.bodyMedium),
      subtitle: Text(
        '${playlist.trackCount} songs',
        style: AppTypography.metadata.copyWith(color: context.colors.textMuted),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: context.colors.textMuted,
        size: 20,
      ),
      onTap: () => context.go(AppRoutes.playlistDetail(playlist.id)),
    );
  }
}

// ─── Favorites Tab ────────────────────────────────────────────────────────────

class _FavoritesTab extends ConsumerWidget {
  const _FavoritesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final playerState = ref.watch(playerProvider);

    return favorites.when(
      loading: () => ListView(
        children: List.generate(4, (_) => const ShimmerTile()),
      ),
      error: (e, _) => ErrorState(
        message: e.toString(),
        onRetry: () => ref.invalidate(favoritesProvider),
      ),
      data: (tracks) {
        if (tracks.isEmpty) {
          return EmptyState(
            title: 'No favorites yet',
            subtitle: 'Favorite songs to find them here.',
            icon: Icons.favorite_border,
            actionLabel: 'Find Music',
            onAction: () => context.go(AppRoutes.search),
          );
        }

        return Column(
          children: [
            // Play all button
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => ref
                          .read(playerProvider.notifier)
                          .playTrack(tracks.first, queue: tracks),
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: const Text('Play All'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ref.read(playerProvider.notifier)
                          ..toggleShuffle();
                        ref
                            .read(playerProvider.notifier)
                            .playTrack(tracks.first, queue: tracks);
                      },
                      icon: const Icon(Icons.shuffle, size: 18),
                      label: const Text('Shuffle'),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: tracks.length,
                itemBuilder: (_, i) {
                  final track = tracks[i];
                  final isCurrent =
                      playerState.currentTrack?.sourceId == track.sourceId;
                  return MusicListTile(
                    track: track,
                    isPlaying: isCurrent && playerState.isPlaying,
                    onTap: () => ref.read(playerProvider.notifier).playTrack(
                      track,
                      queue: tracks,
                    ),
                    onMore: () => showTrackOptions(context, track),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── History Tab ──────────────────────────────────────────────────────────────

class _HistoryTab extends ConsumerWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);
    final playerState = ref.watch(playerProvider);

    return history.when(
      loading: () => ListView(
        children: List.generate(4, (_) => const ShimmerTile()),
      ),
      error: (e, _) => ErrorState(
        message: e.toString(),
        onRetry: () => ref.invalidate(historyProvider),
      ),
      data: (entries) {
        if (entries.isEmpty) {
          return const EmptyState(
            title: 'No listening history',
            subtitle: 'Songs you play will appear here.',
            icon: Icons.history,
          );
        }

        return ListView.builder(
          itemCount: entries.length,
          itemBuilder: (_, i) {
            final entry = entries[i];
            final track = entry.track;
            final isCurrent =
                playerState.currentTrack?.sourceId == track.sourceId;
            return MusicListTile(
              track: track,
              isPlaying: isCurrent && playerState.isPlaying,
              onTap: () => ref.read(playerProvider.notifier).playTrack(
                track,
                queue: entries.map((e) => e.track).toList(),
              ),
              onMore: () => showTrackOptions(context, track),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (track.duration != null)
                    Text(
                      '${track.duration!.inMinutes}:${(track.duration!.inSeconds % 60).toString().padLeft(2, '0')}',
                      style: AppTypography.metadata.copyWith(
                        color: context.colors.textMuted,
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
