/// Remote playlist repository — CRUD via backend API.
library;

import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../data/models/models.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';

class RemotePlaylistRepository implements PlaylistRepository {
  RemotePlaylistRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<Playlist>> getPlaylists() async {
    try {
      final data = await _client.get('/playlists') as List<dynamic>;
      return data
          .map((e) => PlaylistModel.fromJson(e as Map<String, dynamic>).toEntity())
          .toList();
    } on DioException catch (e) {
      throw ApiException(e.error?.toString() ?? 'Failed to load playlists');
    }
  }

  @override
  Future<Playlist> getPlaylist(String id) async {
    try {
      final data = await _client.get('/playlists/$id') as Map<String, dynamic>;
      return PlaylistModel.fromJson(data).toEntity();
    } on DioException catch (e) {
      throw ApiException(e.error?.toString() ?? 'Failed to load playlist');
    }
  }

  @override
  Future<Playlist> createPlaylist(
    String name, {
    String? description,
  }) async {
    try {
      final data = await _client.post('/playlists', data: {
        'name': name,
        if (description != null) 'description': description,
      }) as Map<String, dynamic>;
      return PlaylistModel.fromJson(data).toEntity();
    } on DioException catch (e) {
      throw ApiException(e.error?.toString() ?? 'Failed to create playlist');
    }
  }

  @override
  Future<Playlist> updatePlaylist(
    String id, {
    String? name,
    String? description,
  }) async {
    try {
      final data = await _client.patch('/playlists/$id', data: {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
      }) as Map<String, dynamic>;
      return PlaylistModel.fromJson(data).toEntity();
    } on DioException catch (e) {
      throw ApiException(e.error?.toString() ?? 'Failed to update playlist');
    }
  }

  @override
  Future<void> deletePlaylist(String id) async {
    try {
      await _client.delete('/playlists/$id');
    } on DioException catch (e) {
      throw ApiException(e.error?.toString() ?? 'Failed to delete playlist');
    }
  }

  @override
  Future<void> addTrackToPlaylist(String playlistId, Track track) async {
    try {
      await _client.post('/playlists/$playlistId/tracks', data: {
        'trackId': track.sourceId,
        'title': track.title,
        'artist': track.artist,
        'album': track.album,
        'thumbnailUrl': track.thumbnailUrl,
        'duration': track.duration?.inSeconds,
        'source': track.source,
        'sourceId': track.sourceId,
      });
    } on DioException catch (e) {
      throw ApiException(e.error?.toString() ?? 'Failed to add track');
    }
  }

  @override
  Future<void> removeTrackFromPlaylist(
    String playlistId,
    String trackId,
  ) async {
    try {
      await _client.delete('/playlists/$playlistId/tracks/$trackId');
    } on DioException catch (e) {
      throw ApiException(e.error?.toString() ?? 'Failed to remove track');
    }
  }

  @override
  Future<void> reorderPlaylistTracks(
    String playlistId,
    List<String> orderedTrackIds,
  ) async {
    try {
      await _client.patch('/playlists/$playlistId/tracks/reorder', data: {
        'orderedTrackIds': orderedTrackIds,
      });
    } on DioException catch (e) {
      throw ApiException(e.error?.toString() ?? 'Failed to reorder tracks');
    }
  }
}
