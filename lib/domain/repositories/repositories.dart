/// Abstract repository interfaces — domain layer.
library;

import '../entities/entities.dart';

abstract class MusicRepository {
  /// Search music by query with optional page/cursor.
  Future<SearchPage> search(String query, {int page = 1, String? cursor});

  /// Get track metadata by sourceId.
  Future<Track> getTrack(String sourceId);

  /// Resolve the ephemeral stream URL for a track.
  Future<String> resolveStreamUrl(String sourceId);

  /// Get trending tracks.
  Future<List<SearchResult>> getTrending();
}

abstract class PlaylistRepository {
  Future<List<Playlist>> getPlaylists();
  Future<Playlist> getPlaylist(String id);
  Future<Playlist> createPlaylist(String name, {String? description});
  Future<Playlist> updatePlaylist(String id, {String? name, String? description});
  Future<void> deletePlaylist(String id);
  Future<void> addTrackToPlaylist(String playlistId, Track track);
  Future<void> removeTrackFromPlaylist(String playlistId, String trackId);
  Future<void> reorderPlaylistTracks(String playlistId, List<String> orderedTrackIds);
}

abstract class FavoritesRepository {
  Future<List<Track>> getFavorites();
  Future<void> addFavorite(Track track);
  Future<void> removeFavorite(String trackId);
  Future<bool> isFavorite(String trackId);
}

abstract class HistoryRepository {
  Future<List<HistoryEntry>> getHistory({int limit = 50});
  Future<void> recordPlay(Track track);
  Future<void> clearHistory();
}
