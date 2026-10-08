/// AlbumArtwork — cached network image with consistent fallback.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../app/theme/theme.dart';

class AlbumArtwork extends StatelessWidget {
  const AlbumArtwork({
    super.key,
    this.url,
    required this.size,
    this.borderRadius,
    this.showShadow = false,
  });

  final String? url;
  final double size;
  final double? borderRadius;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppRadius.artwork;
    final Widget image = url != null && url!.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: url!,
            fit: BoxFit.cover,
            width: size,
            height: size,
            placeholder: (_, __) => _Fallback(size: size),
            errorWidget: (_, __, ___) => _Fallback(size: size),
          )
        : _Fallback(size: size);

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: showShadow ? AppShadows.card : null,
      ),
      child: image,
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: context.colors.surfaceSecondary,
      child: Icon(
        Icons.music_note,
        color: context.colors.textMuted,
        size: size * 0.4,
      ),
    );
  }
}
