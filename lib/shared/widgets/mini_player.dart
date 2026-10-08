/// Mini Player — sits above bottom nav, expands to full player on tap.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/theme.dart';
import '../../features/player/player_notifier.dart';
import '../../features/player/player_state.dart' as ps;
import 'album_artwork.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerProvider);

    if (!playerState.hasTrack) return const SizedBox.shrink();

    final track = playerState.currentTrack!;
    final isPlaying = playerState.isPlaying;
    final isLoading = playerState.isLoading;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          boxShadow: AppShadows.miniPlayer,
          border: Border(
            top: BorderSide(color: context.colors.border, width: 0.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress bar (thin, above content)
            _ProgressBar(
              position: playerState.position,
              duration: playerState.duration,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  AlbumArtwork(url: track.thumbnailUrl, size: 40),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          track.title,
                          style: AppTypography.bodyMedium.copyWith(
                            color: context.colors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          track.artist,
                          style: AppTypography.metadata.copyWith(
                            color: context.colors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  if (isLoading)
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  else
                    _ControlButton(
                      icon: isPlaying ? Icons.pause : Icons.play_arrow,
                      onTap: () =>
                          ref.read(playerProvider.notifier).togglePlay(),
                      tooltip: isPlaying ? 'Pause' : 'Play',
                    ),
                  _ControlButton(
                    icon: Icons.skip_next,
                    onTap: playerState.hasNext
                        ? () => ref.read(playerProvider.notifier).next()
                        : null,
                    tooltip: 'Next',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.position, required this.duration});
  final Duration position;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final progress = duration.inMilliseconds > 0
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return LinearProgressIndicator(
      value: progress,
      minHeight: 2,
      backgroundColor: context.colors.border,
      valueColor: AlwaysStoppedAnimation(context.colors.lavender),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon),
      iconSize: 22,
      color: onTap != null ? context.colors.textPrimary : context.colors.textMuted,
      tooltip: tooltip,
      padding: const EdgeInsets.all(AppSpacing.xs),
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
    );
  }
}
