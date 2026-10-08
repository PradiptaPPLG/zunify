/// Track options bottom sheet — Add to Playlist, Favorite, Queue, etc.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/theme.dart';
import '../../domain/entities/entities.dart';
import '../../features/player/player_notifier.dart';
import '../../features/library/favorites_provider.dart';
import '../../features/playlists/playlists_provider.dart';
import 'album_artwork.dart';

void showTrackOptions(BuildContext context, Track track) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => _TrackOptionsSheet(track: track),
  );
}

class _TrackOptionsSheet extends ConsumerWidget {
  const _TrackOptionsSheet({required this.track});
  final Track track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref
        .watch(favoritesProvider)
        .valueOrNull
        ?.any((t) => t.sourceId == track.sourceId) ?? false;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Track info header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md,
              ),
              child: Row(
                children: [
                  AlbumArtwork(url: track.thumbnailUrl, size: 48),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          track.title,
                          style: AppTypography.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          track.artist,
                          style: AppTypography.secondary.copyWith(
                            color: context.colors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            _OptionTile(
              icon: isFavorite ? Icons.favorite : Icons.favorite_border,
              iconColor: isFavorite ? context.colors.pink : null,
              label: isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
              onTap: () {
                Navigator.pop(context);
                if (isFavorite) {
                  ref.read(favoritesProvider.notifier).remove(track.sourceId);
                } else {
                  ref.read(favoritesProvider.notifier).add(track);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isFavorite ? 'Removed from Favorites' : 'Added to Favorites',
                    ),
                  ),
                );
              },
            ),
            _OptionTile(
              icon: Icons.queue_music,
              label: 'Add to Queue',
              onTap: () {
                Navigator.pop(context);
                ref.read(playerProvider.notifier).addToQueue(track);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added to queue')),
                );
              },
            ),
            _OptionTile(
              icon: Icons.playlist_add,
              label: 'Add to Playlist',
              onTap: () {
                Navigator.pop(context);
                showAddToPlaylistSheet(context, track);
              },
            ),
          ],
        ),
      ),
    );
  }
}

void showAddToPlaylistSheet(BuildContext context, Track track) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => _AddToPlaylistSheet(track: track),
  );
}

class _AddToPlaylistSheet extends ConsumerWidget {
  const _AddToPlaylistSheet({required this.track});
  final Track track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistsProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md,
              ),
              child: Text(
                'Add to playlist',
                style: AppTypography.heading3,
              ),
            ),
            const Divider(height: 1),
            _OptionTile(
              icon: Icons.add,
              label: 'New Playlist',
              onTap: () {
                Navigator.pop(context);
                showCreatePlaylistDialog(context, initialTrack: track);
              },
            ),
            const Divider(height: 1),
            ...playlists.valueOrNull?.map((p) => _OptionTile(
              icon: Icons.queue_music,
              label: p.name,
              onTap: () {
                Navigator.pop(context);
                ref.read(playlistsProvider.notifier).addTrack(p.id, track);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added to ${p.name}')),
                );
              },
            )) ?? [],
          ],
        ),
      ),
    );
  }
}

void showCreatePlaylistDialog(
  BuildContext context, {
  Track? initialTrack,
}) {
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  showDialog(
    context: context,
    builder: (ctx) => Consumer(
      builder: (context, ref, _) => AlertDialog(
        title: const Text('Create playlist'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Playlist name'),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(
                hintText: 'Description (optional)',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);
              final playlist = await ref
                  .read(playlistsProvider.notifier)
                  .create(name, description: descCtrl.text.trim());
              if (initialTrack != null && playlist != null) {
                await ref
                    .read(playlistsProvider.notifier)
                    .addTrack(playlist.id, initialTrack);
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Created "$name"')),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    ),
  );
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? context.colors.textSecondary, size: 20),
      title: Text(label, style: AppTypography.body),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xxs,
      ),
    );
  }
}
