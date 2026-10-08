/// Playlist detail screen — full track list, reorder, play.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/theme.dart';
import '../../domain/entities/entities.dart';
import '../../features/player/player_notifier.dart';
import '../../features/player/player_state.dart' as ps;
import '../../features/playlists/playlists_provider.dart';
import '../../shared/widgets/album_artwork.dart';
import '../../shared/widgets/music_list_tile.dart';
import '../../shared/widgets/states.dart';
import '../../shared/widgets/track_options.dart';

class PlaylistDetailScreen extends ConsumerWidget {
  const PlaylistDetailScreen({super.key, required this.playlistId});
  final String playlistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlist = ref.watch(playlistDetailProvider(playlistId));

    return Scaffold(
      backgroundColor: context.colors.background,
      body: playlist.when(
        loading: () => const Scaffold(
          body: LoadingState(message: 'Loading playlist...'),
        ),
        error: (e, _) => Scaffold(
          appBar: AppBar(),
          body: ErrorState(
            message: e.toString(),
            onRetry: () => ref.invalidate(playlistDetailProvider(playlistId)),
          ),
        ),
        data: (p) => _PlaylistContent(playlist: p),
      ),
    );
  }
}

class _PlaylistContent extends ConsumerStatefulWidget {
  const _PlaylistContent({required this.playlist});
  final Playlist playlist;

  @override
  ConsumerState<_PlaylistContent> createState() => _PlaylistContentState();
}

class _PlaylistContentState extends ConsumerState<_PlaylistContent> {
  late List<Track> _tracks;

  @override
  void initState() {
    super.initState();
    _tracks = List.from(widget.playlist.tracks);
  }

  @override
  void didUpdateWidget(_PlaylistContent old) {
    super.didUpdateWidget(old);
    if (old.playlist.updatedAt != widget.playlist.updatedAt) {
      _tracks = List.from(widget.playlist.tracks);
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerProvider);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 220,
          floating: false,
          pinned: true,
          surfaceTintColor: Colors.transparent,
          backgroundColor: context.colors.background,
          flexibleSpace: FlexibleSpaceBar(
            background: _PlaylistHeader(playlist: widget.playlist),
            collapseMode: CollapseMode.parallax,
          ),
          actions: [
            IconButton(
              onPressed: () => _showOptions(context),
              icon: const Icon(Icons.more_horiz),
              tooltip: 'Playlist options',
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _tracks.isEmpty
                        ? null
                        : () => ref
                            .read(playerProvider.notifier)
                            .playTrack(_tracks.first, queue: _tracks),
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('Play'),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _tracks.isEmpty
                        ? null
                        : () {
                            ref.read(playerProvider.notifier)
                              ..toggleShuffle();
                            ref
                                .read(playerProvider.notifier)
                                .playTrack(_tracks.first, queue: _tracks);
                          },
                    icon: const Icon(Icons.shuffle, size: 18),
                    label: const Text('Shuffle'),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_tracks.isEmpty)
          SliverFillRemaining(
            child: EmptyState(
              title: 'This playlist is empty',
              subtitle: 'Search for songs and add them here.',
              icon: Icons.queue_music_outlined,
              actionLabel: 'Find Music',
              onAction: () => context.go('/search'),
            ),
          )
        else
          SliverReorderableList(
            onReorder: (oldIndex, newIndex) async {
              setState(() {
                if (newIndex > oldIndex) newIndex -= 1;
                final track = _tracks.removeAt(oldIndex);
                _tracks.insert(newIndex, track);
              });
              await ref.read(playlistsProvider.notifier).reorder(
                widget.playlist.id,
                _tracks.map((t) => t.sourceId).toList(),
              );
            },
            itemCount: _tracks.length,
            itemBuilder: (_, i) {
              final track = _tracks[i];
              final isCurrent =
                  playerState.currentTrack?.sourceId == track.sourceId;

              return ReorderableDragStartListener(
                key: ValueKey(track.sourceId),
                index: i,
                child: _ReorderableTrackTile(
                  track: track,
                  isCurrent: isCurrent,
                  isPlaying: isCurrent && playerState.isPlaying,
                  onTap: () => ref.read(playerProvider.notifier).playTrack(
                    track,
                    queue: _tracks,
                  ),
                  onMore: () => _showTrackOptions(context, track, i),
                ),
              );
            },
          ),
      ],
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: context.colors.error),
              title: Text(
                'Delete playlist',
                style: TextStyle(color: context.colors.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context) {
    final ctrl = TextEditingController(text: widget.playlist.name);
    showDialog(
      context: context,
      builder: (ctx) => Consumer(
        builder: (context, ref, _) => AlertDialog(
          title: const Text('Rename playlist'),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Playlist name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = ctrl.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(ctx);
                ref
                    .read(playlistsProvider.notifier)
                    .rename(widget.playlist.id, name);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Consumer(
        builder: (context, ref, _) => AlertDialog(
          title: const Text('Delete playlist?'),
          content: const Text(
            "This won't delete the songs from the music catalog.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.go('/library');
                ref
                    .read(playlistsProvider.notifier)
                    .delete(widget.playlist.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Playlist deleted')),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: context.colors.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTrackOptions(BuildContext context, Track track, int index) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.remove_circle_outline,
                  color: context.colors.error),
              title: Text(
                'Remove from playlist',
                style: TextStyle(color: context.colors.error),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() => _tracks.removeAt(index));
                ref.read(playlistsProvider.notifier).removeTrack(
                  widget.playlist.id,
                  track.sourceId,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Removed "${track.title}"')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.more_horiz),
              title: const Text('More options'),
              onTap: () {
                Navigator.pop(context);
                showTrackOptions(context, track);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaylistHeader extends StatelessWidget {
  const _PlaylistHeader({required this.playlist});
  final Playlist playlist;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.background,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md, 80, AppSpacing.md, AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: context.colors.lavenderLight,
              borderRadius: AppRadius.cardBR,
            ),
            child: Icon(
              Icons.queue_music,
              color: context.colors.lavender,
              size: 40,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  playlist.name,
                  style: AppTypography.heading2,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (playlist.description != null &&
                    playlist.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    playlist.description!,
                    style: AppTypography.secondary.copyWith(
                      color: context.colors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  '${playlist.trackCount} songs',
                  style: AppTypography.metadata.copyWith(
                    color: context.colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReorderableTrackTile extends StatelessWidget {
  const _ReorderableTrackTile({
    required this.track,
    required this.isCurrent,
    required this.isPlaying,
    required this.onTap,
    required this.onMore,
  });

  final Track track;
  final bool isCurrent;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return MusicListTile(
      track: track,
      isPlaying: isPlaying,
      onTap: onTap,
      onMore: onMore,
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
          const SizedBox(width: AppSpacing.xxs),
          Icon(Icons.drag_handle, size: 18, color: context.colors.textMuted),
        ],
      ),
    );
  }
}
