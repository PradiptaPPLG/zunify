/// Favorites and History repositories — backed by the API.
library;

import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../data/models/models.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';

class RemoteFavoritesRepository implements FavoritesRepository {
  RemoteFavoritesRepository(this._client);

  final ApiClient _client;
  // Local cache to avoid repeated network calls for isFavorite checks
  final Set<String> _cachedIds = {};
  bool _loaded = false;

  @override
  Future<List<Track>> getFavorites() async {
    try {
      final data = await _client.get('/favorites') as List<dynamic>;
      final tracks = data
          .map((e) => TrackModel.fromJson(e as Map<String, dynamic>).toEntity())
          .toList();
      _cachedIds
        ..clear()
        ..addAll(tracks.map((t) => t.sourceId));
      _loaded = true;
      return tracks;
    } on DioException catch (e) {
      throw ApiException(e.error?.toString() ?? 'Failed to load favorites');
    }
  }

  @override
  Future<void> addFavorite(Track track) async {
    try {
      await _client.post('/favorites/${track.sourceId}', data: {
        'title': track.title,
        'artist': track.artist,
        'album': track.album,
        'thumbnailUrl': track.thumbnailUrl,
        'duration': track.duration?.inSeconds,
        'source': track.source,
        'sourceId': track.sourceId,
      });
      _cachedIds.add(track.sourceId);
    } on DioException catch (e) {
      throw ApiException(e.error?.toString() ?? 'Failed to add favorite');
    }
  }

  @override
  Future<void> removeFavorite(String trackId) async {
    try {
      await _client.delete('/favorites/$trackId');
      _cachedIds.remove(trackId);
    } on DioException catch (e) {
      throw ApiException(e.error?.toString() ?? 'Failed to remove favorite');
    }
  }

  @override
  Future<bool> isFavorite(String trackId) async {
    if (!_loaded) await getFavorites();
    return _cachedIds.contains(trackId);
  }
}

class RemoteHistoryRepository implements HistoryRepository {
  RemoteHistoryRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<HistoryEntry>> getHistory({int limit = 50}) async {
    try {
      final data = await _client.get(
        '/history',
        queryParameters: {'limit': limit},
      ) as List<dynamic>;

      return data.map((e) {
        final map = e as Map<String, dynamic>;
        final track = TrackModel.fromJson(
          map['track'] as Map<String, dynamic>,
        ).toEntity();
        return HistoryEntry(
          track: track,
          playedAt: DateTime.parse(map['playedAt'] as String),
        );
      }).toList();
    } on DioException catch (e) {
      throw ApiException(e.error?.toString() ?? 'Failed to load history');
    }
  }

  @override
  Future<void> recordPlay(Track track) async {
    try {
      await _client.post('/history', data: {
        'trackId': track.sourceId,
        'title': track.title,
        'artist': track.artist,
        'album': track.album,
        'thumbnailUrl': track.thumbnailUrl,
        'duration': track.duration?.inSeconds,
        'source': track.source,
        'sourceId': track.sourceId,
      });
    } on DioException catch (_) {
      // History recording failure should not block user
    }
  }

  @override
  Future<void> clearHistory() async {
    try {
      await _client.delete('/history');
    } on DioException catch (e) {
      throw ApiException(e.error?.toString() ?? 'Failed to clear history');
    }
  }
}
