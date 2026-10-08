/// Core Riverpod providers — repositories, API client.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../data/repositories/remote_music_repository.dart';
import '../data/repositories/remote_playlist_repository.dart';
import '../data/repositories/remote_favorites_history_repository.dart';
import '../domain/repositories/repositories.dart';
import '../features/settings/settings_provider.dart';

// ─── API Client ──────────────────────────────────────────────────────────────

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// ─── Repository Providers ────────────────────────────────────────────────────

final musicRepositoryProvider = Provider<MusicRepository>((ref) {
  return RemoteMusicRepository(ref.watch(apiClientProvider));
});

final playlistRepositoryProvider = Provider<PlaylistRepository>((ref) {
  return RemotePlaylistRepository(ref.watch(apiClientProvider));
});

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return RemoteFavoritesRepository(ref.watch(apiClientProvider));
});

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return RemoteHistoryRepository(ref.watch(apiClientProvider));
});
