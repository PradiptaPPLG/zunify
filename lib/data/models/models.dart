/// Data models with JSON parsing for backend responses.
/// These map directly to the backend API contract.
library;

import '../../domain/entities/entities.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Track Model
// ─────────────────────────────────────────────────────────────────────────────

class TrackModel {
  const TrackModel({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.thumbnailUrl,
    this.durationSeconds,
    required this.source,
    required this.sourceId,
    this.streamUrl,
    this.uploader,
    this.publishedAt,
    this.isExplicit = false,
    this.available = true,
  });

  final String id;
  final String title;
  final String artist;
  final String? album;
  final String? thumbnailUrl;
  final int? durationSeconds;
  final String source;
  final String sourceId;
  final String? streamUrl;
  final String? uploader;
  final String? publishedAt;
  final bool isExplicit;
  final bool available;

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    return TrackModel(
      id: json['id'] as String? ?? json['sourceId'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String? ?? json['uploader'] as String? ?? 'Unknown Artist',
      album: json['album'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      durationSeconds: json['duration'] as int?,
      source: json['source'] as String? ?? 'youtube',
      sourceId: json['sourceId'] as String,
      streamUrl: json['streamUrl'] as String?,
      uploader: json['uploader'] as String?,
      publishedAt: json['publishedAt'] as String?,
      isExplicit: json['isExplicit'] as bool? ?? false,
      available: json['available'] as bool? ?? true,
    );
  }

  Track toEntity() => Track(
    id: id,
    title: title,
    artist: artist,
    album: album,
    thumbnailUrl: thumbnailUrl,
    duration: durationSeconds != null
        ? Duration(seconds: durationSeconds!)
        : null,
    source: source,
    sourceId: sourceId,
    streamUrl: streamUrl,
    uploader: uploader,
    publishedAt: publishedAt != null ? DateTime.tryParse(publishedAt!) : null,
    isExplicit: isExplicit,
    available: available,
  );

  static Track entityFromJson(Map<String, dynamic> json) =>
      TrackModel.fromJson(json).toEntity();
}

// ─────────────────────────────────────────────────────────────────────────────
// Search Result Model
// ─────────────────────────────────────────────────────────────────────────────

class SearchResultModel {
  const SearchResultModel({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.thumbnailUrl,
    this.durationSeconds,
    required this.source,
    required this.sourceId,
    this.available = true,
  });

  final String id;
  final String title;
  final String artist;
  final String? album;
  final String? thumbnailUrl;
  final int? durationSeconds;
  final String source;
  final String sourceId;
  final bool available;

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      id: json['id'] as String? ?? json['sourceId'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String? ?? json['uploader'] as String? ?? 'Unknown Artist',
      album: json['album'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      durationSeconds: json['duration'] as int?,
      source: json['source'] as String? ?? 'youtube',
      sourceId: json['sourceId'] as String,
      available: json['available'] as bool? ?? true,
    );
  }

  SearchResult toEntity() => SearchResult(
    id: id,
    title: title,
    artist: artist,
    album: album,
    thumbnailUrl: thumbnailUrl,
    duration: durationSeconds != null
        ? Duration(seconds: durationSeconds!)
        : null,
    source: source,
    sourceId: sourceId,
    available: available,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Playlist Model
// ─────────────────────────────────────────────────────────────────────────────

class PlaylistModel {
  const PlaylistModel({
    required this.id,
    required this.name,
    this.description,
    this.coverUrl,
    required this.trackCount,
    required this.createdAt,
    required this.updatedAt,
    this.tracks = const [],
  });

  final String id;
  final String name;
  final String? description;
  final String? coverUrl;
  final int trackCount;
  final String createdAt;
  final String updatedAt;
  final List<TrackModel> tracks;

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    final trackList = (json['tracks'] as List<dynamic>?)
            ?.map((t) => TrackModel.fromJson(t as Map<String, dynamic>))
            .toList() ??
        [];
    return PlaylistModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      coverUrl: json['coverUrl'] as String?,
      trackCount: json['trackCount'] as int? ?? trackList.length,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      tracks: trackList,
    );
  }

  Playlist toEntity() => Playlist(
    id: id,
    name: name,
    description: description,
    coverUrl: coverUrl,
    trackCount: trackCount,
    createdAt: DateTime.parse(createdAt),
    updatedAt: DateTime.parse(updatedAt),
    tracks: tracks.map((t) => t.toEntity()).toList(),
  );
}
