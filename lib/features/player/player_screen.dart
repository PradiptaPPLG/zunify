/// Full Player Screen — artwork, controls, seek bar, queue.
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/theme.dart';
import '../../domain/entities/entities.dart';
import '../../features/player/player_notifier.dart';
import '../../features/player/player_state.dart' as ps;
import '../../features/library/favorites_provider.dart';
import '../../features/settings/settings_provider.dart';
import '../../shared/widgets/album_artwork.dart';
import '../../shared/widgets/track_options.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerProvider);

    if (!state.hasTrack) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                context.go('/');
              }
            },
            icon: const Icon(Icons.keyboard_arrow_down),
          ),
        ),
        body: const Center(child: Text('No track playing')),
      );
    }

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Column(
          children: [
            _PlayerAppBar(track: state.currentTrack!),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.xxl),
                    _ArtworkSection(state: state),
                    const SizedBox(height: AppSpacing.xxl),
                    _TrackInfo(state: state),
                    const SizedBox(height: AppSpacing.xl),
                    _SeekBar(state: state),
                    const SizedBox(height: AppSpacing.lg),
                    _Controls(state: state),
                    const SizedBox(height: AppSpacing.xl),
                    _SecondaryControls(state: state),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerAppBar extends StatelessWidget {
  const _PlayerAppBar({required this.track});
  final Track track;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.keyboard_arrow_down),
            iconSize: 28,
            tooltip: 'Minimize',
            color: context.colors.textPrimary,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Now Playing',
                  style: AppTypography.label.copyWith(
                    color: context.colors.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
                if (track.album != null)
                  Text(
                    track.album!,
                    style: AppTypography.metadataMedium.copyWith(
                      color: context.colors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Consumer(
            builder: (context, ref, _) => IconButton(
              onPressed: () => showTrackOptions(context, track),
              icon: const Icon(Icons.more_horiz),
              tooltip: 'More options',
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArtworkSection extends StatelessWidget {
  const _ArtworkSection({required this.state});
  final ps.PlayerState state;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context).width - AppSpacing.xl * 2;
    final artSize = size.clamp(200.0, 360.0);

    return AnimatedScale(
      scale: state.isPlaying ? 1.0 : 0.92,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: AlbumArtwork(
        url: state.currentTrack?.thumbnailUrl,
        size: artSize,
        borderRadius: AppRadius.large,
        showShadow: true,
      ),
    );
  }
}

class _TrackInfo extends ConsumerWidget {
  const _TrackInfo({required this.state});
  final ps.PlayerState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final track = state.currentTrack!;
    final isFavorite =
        ref.watch(favoritesProvider).valueOrNull?.any(
              (t) => t.sourceId == track.sourceId,
            ) ??
            false;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                track.title,
                style: AppTypography.heading2.copyWith(
                  color: context.colors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                track.artist,
                style: AppTypography.bodyMedium.copyWith(
                  color: context.colors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: IconButton(
            key: ValueKey(isFavorite),
            onPressed: () => ref.read(favoritesProvider.notifier).toggle(track),
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? context.colors.pink : context.colors.textMuted,
            ),
            iconSize: 24,
            tooltip: isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
          ),
        ),
      ],
    );
  }
}

class _SeekBar extends ConsumerWidget {
  const _SeekBar({required this.state});
  final ps.PlayerState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = state.position;
    final duration = state.duration;
    final progress = duration.inMilliseconds > 0
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3.5,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
          ),
          child: Slider(
            value: progress,
            onChanged: (v) {
              final newPos = Duration(
                milliseconds: (v * duration.inMilliseconds).round(),
              );
              ref.read(playerProvider.notifier).seek(newPos);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _format(position),
                style: AppTypography.metadata.copyWith(
                  color: context.colors.textMuted,
                ),
              ),
              Text(
                _format(duration),
                style: AppTypography.metadata.copyWith(
                  color: context.colors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _format(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

class _Controls extends ConsumerWidget {
  const _Controls({required this.state});
  final ps.PlayerState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.read(playerProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          onPressed: state.hasPrevious
              ? () => player.previous()
              : null,
          icon: const Icon(Icons.skip_previous),
          iconSize: 32,
          color: state.hasPrevious
              ? context.colors.textPrimary
              : context.colors.textMuted,
          tooltip: 'Previous',
        ),
        // Main play/pause
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: context.colors.lavender,
            shape: BoxShape.circle,
          ),
          child: state.isLoading
              ? const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                )
              : IconButton(
                  onPressed: () => player.togglePlay(),
                  icon: Icon(
                    state.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  iconSize: 32,
                  tooltip: state.isPlaying ? 'Pause' : 'Play',
                ),
        ),
        IconButton(
          onPressed: state.hasNext ? () => player.next() : null,
          icon: const Icon(Icons.skip_next),
          iconSize: 32,
          color: state.hasNext ? context.colors.textPrimary : context.colors.textMuted,
          tooltip: 'Next',
        ),
      ],
    );
  }
}

class _SecondaryControls extends ConsumerWidget {
  const _SecondaryControls({required this.state});
  final ps.PlayerState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.read(playerProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () => player.toggleShuffle(),
          icon: const Icon(Icons.shuffle),
          iconSize: 20,
          color: state.shuffleEnabled
              ? context.colors.lavender
              : context.colors.textMuted,
          tooltip: 'Shuffle',
        ),
        IconButton(
          onPressed: () => player.cycleRepeat(),
          icon: Icon(
            state.repeatMode == AudioRepeatMode.one
                ? Icons.repeat_one
                : Icons.repeat,
          ),
          iconSize: 20,
          color: state.repeatMode != AudioRepeatMode.off
              ? context.colors.lavender
              : context.colors.textMuted,
          tooltip: 'Repeat',
        ),
        IconButton(
          onPressed: () => _showQueueSheet(context),
          icon: const Icon(Icons.queue_music),
          iconSize: 20,
          color: context.colors.textMuted,
          tooltip: 'Queue',
        ),
      ],
    );
  }

  void _showQueueSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _QueueSheet(),
    );
  }
}

class _QueueSheet extends ConsumerWidget {
  const _QueueSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerProvider);
    final queue = state.queue;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      builder: (_, scrollCtrl) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xs,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Queue', style: AppTypography.heading3),
                TextButton(
                  onPressed: () {
                    ref.read(playerProvider.notifier).clearQueue();
                    Navigator.pop(context);
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: queue.isEmpty
                ? const Center(child: Text('Queue is empty'))
                : ListView.builder(
                    controller: scrollCtrl,
                    itemCount: queue.length,
                    itemBuilder: (_, i) {
                      final track = queue[i];
                      final isCurrent = i == state.queueIndex;
                      return ListTile(
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            borderRadius: AppRadius.artworkBR,
                            color: context.colors.surfaceSecondary,
                          ),
                          child: isCurrent
                              ? Icon(
                                  Icons.equalizer,
                                  size: 18,
                                  color: context.colors.lavender,
                                )
                              : Icon(
                                  Icons.music_note,
                                  size: 18,
                                  color: context.colors.textMuted,
                                ),
                        ),
                        title: Text(
                          track.title,
                          style: AppTypography.bodyMedium.copyWith(
                            color: isCurrent
                                ? context.colors.lavender
                                : context.colors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          track.artist,
                          style: AppTypography.metadata.copyWith(
                            color: context.colors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: !isCurrent
                            ? IconButton(
                                icon: const Icon(Icons.close, size: 16),
                                color: context.colors.textMuted,
                                onPressed: () => ref
                                    .read(playerProvider.notifier)
                                    .removeFromQueue(i),
                              )
                            : null,
                        onTap: () {
                          Navigator.pop(context);
                          ref
                              .read(playerProvider.notifier)
                              .playFromQueue(i);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
