/// Core domain entities for Zunify.
library;

import 'package:equatable/equatable.dart';

/// Represents a music track.
class Track extends Equatable {
  const Track({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.thumbnailUrl,
    this.duration,
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
  final Duration? duration;
  final String source; // 'youtube'
  final String sourceId;
  final String? streamUrl; // ephemeral, not persisted
  final String? uploader;
  final DateTime? publishedAt;
  final bool isExplicit;
  final bool available;

  Track copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? thumbnailUrl,
    Duration? duration,
    String? source,
    String? sourceId,
    String? streamUrl,
    String? uploader,
    DateTime? publishedAt,
    bool? isExplicit,
    bool? available,
  }) {
    return Track(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
      streamUrl: streamUrl ?? this.streamUrl,
      uploader: uploader ?? this.uploader,
      publishedAt: publishedAt ?? this.publishedAt,
      isExplicit: isExplicit ?? this.isExplicit,
      available: available ?? this.available,
    );
  }

  @override
  List<Object?> get props => [id, sourceId, source];
}

/// Search result (lighter model than Track).
class SearchResult extends Equatable {
  const SearchResult({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.thumbnailUrl,
    this.duration,
    required this.source,
    required this.sourceId,
    this.available = true,
  });

  final String id;
  final String title;
  final String artist;
  final String? album;
  final String? thumbnailUrl;
  final Duration? duration;
  final String source;
  final String sourceId;
  final bool available;

  Track toTrack() => Track(
    id: id,
    title: title,
    artist: artist,
    album: album,
    thumbnailUrl: thumbnailUrl,
    duration: duration,
    source: source,
    sourceId: sourceId,
    available: available,
  );

  @override
  List<Object?> get props => [id, sourceId];
}

/// User playlist.
class Playlist extends Equatable {
  const Playlist({
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
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Track> tracks;

  Playlist copyWith({
    String? id,
    String? name,
    String? description,
    String? coverUrl,
    int? trackCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Track>? tracks,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      trackCount: trackCount ?? this.trackCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tracks: tracks ?? this.tracks,
    );
  }

  @override
  List<Object?> get props => [id];
}

/// Play history entry.
class HistoryEntry extends Equatable {
  const HistoryEntry({required this.track, required this.playedAt});

  final Track track;
  final DateTime playedAt;

  @override
  List<Object?> get props => [track.id, playedAt];
}

/// Search page result with pagination.
class SearchPage extends Equatable {
  const SearchPage({
    required this.results,
    required this.hasNextPage,
    this.nextCursor,
    this.page = 1,
  });

  final List<SearchResult> results;
  final bool hasNextPage;
  final String? nextCursor;
  final int page;

  @override
  List<Object?> get props => [results, page];
}
