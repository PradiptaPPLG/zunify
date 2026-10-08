/// MusicListTile — reusable track list row.
/// Clean list style: no giant card, subtle divider.
library;

import 'package:flutter/material.dart';
import '../../app/theme/theme.dart';
import '../../domain/entities/entities.dart';
import 'album_artwork.dart';

class MusicListTile extends StatelessWidget {
  const MusicListTile({
    super.key,
    required this.track,
    this.onTap,
    this.onMore,
    this.trailing,
    this.isPlaying = false,
    this.showDivider = true,
    this.artworkSize = 46,
    this.compact = false,
  });

  final Track track;
  final VoidCallback? onTap;
  final VoidCallback? onMore;
  final Widget? trailing;
  final bool isPlaying;
  final bool showDivider;
  final double artworkSize;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: AppRadius.normalBR,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: compact ? AppSpacing.xxs + 2 : AppSpacing.xs,
            ),
            child: Row(
              children: [
                AlbumArtwork(url: track.thumbnailUrl, size: artworkSize),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          if (isPlaying) ...[
                            Container(
                              width: 3,
                              height: 14,
                              decoration: BoxDecoration(
                                color: context.colors.lavender,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xxs + 2),
                          ],
                          Expanded(
                            child: Text(
                              track.title,
                              style: AppTypography.bodyMedium.copyWith(
                                color: isPlaying
                                    ? context.colors.lavender
                                    : context.colors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
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
                const SizedBox(width: AppSpacing.xs),
                if (trailing != null)
                  trailing!
                else ...[
                  if (track.duration != null)
                    Text(
                      _formatDuration(track.duration!),
                      style: AppTypography.metadata.copyWith(
                        color: context.colors.textMuted,
                      ),
                    ),
                  if (onMore != null) ...[
                    const SizedBox(width: AppSpacing.xxs),
                    IconButton(
                      onPressed: onMore,
                      icon: const Icon(Icons.more_horiz),
                      iconSize: 18,
                      color: context.colors.textMuted,
                      tooltip: 'More options',
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.only(left: AppSpacing.md + 46 + AppSpacing.sm),
            child: Divider(height: 1),
          ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

/// SearchResult variant — lighter model.
class SearchResultTile extends StatelessWidget {
  const SearchResultTile({
    super.key,
    required this.result,
    this.onTap,
    this.onMore,
    this.isPlaying = false,
    this.showDivider = true,
  });

  final SearchResult result;
  final VoidCallback? onTap;
  final VoidCallback? onMore;
  final bool isPlaying;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return MusicListTile(
      track: result.toTrack(),
      onTap: onTap,
      onMore: onMore,
      isPlaying: isPlaying,
      showDivider: showDivider,
    );
  }
}
