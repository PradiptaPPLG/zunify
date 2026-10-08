/// Playlists Riverpod provider.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../domain/entities/entities.dart';

class PlaylistsNotifier extends AsyncNotifier<List<Playlist>> {
  @override
  Future<List<Playlist>> build() async {
    return ref.read(playlistRepositoryProvider).getPlaylists();
  }

  Future<Playlist?> create(String name, {String? description}) async {
    try {
      final playlist = await ref
          .read(playlistRepositoryProvider)
          .createPlaylist(name, description: description);
      final current = state.valueOrNull ?? [];
      state = AsyncData([...current, playlist]);
      return playlist;
    } catch (e) {
      return null;
    }
  }

  Future<void> rename(String id, String newName, {String? description}) async {
    final playlist = await ref
        .read(playlistRepositoryProvider)
        .updatePlaylist(id, name: newName, description: description);
    final current = state.valueOrNull ?? [];
    state = AsyncData(
      current.map((p) => p.id == id ? playlist : p).toList(),
    );
  }

  Future<void> delete(String id) async {
    await ref.read(playlistRepositoryProvider).deletePlaylist(id);
    final current = state.valueOrNull ?? [];
    state = AsyncData(current.where((p) => p.id != id).toList());
  }

  Future<void> addTrack(String playlistId, Track track) async {
    await ref
        .read(playlistRepositoryProvider)
        .addTrackToPlaylist(playlistId, track);
    // Invalidate the specific playlist detail provider
    ref.invalidate(playlistDetailProvider(playlistId));
    // Update count in list
    final current = state.valueOrNull ?? [];
    state = AsyncData(
      current
          .map((p) => p.id == playlistId
              ? p.copyWith(trackCount: p.trackCount + 1)
              : p)
          .toList(),
    );
  }

  Future<void> removeTrack(String playlistId, String trackId) async {
    await ref
        .read(playlistRepositoryProvider)
        .removeTrackFromPlaylist(playlistId, trackId);
    ref.invalidate(playlistDetailProvider(playlistId));
    final current = state.valueOrNull ?? [];
    state = AsyncData(
      current
          .map((p) => p.id == playlistId
              ? p.copyWith(trackCount: (p.trackCount - 1).clamp(0, 9999))
              : p)
          .toList(),
    );
  }

  Future<void> reorder(
    String playlistId,
    List<String> orderedTrackIds,
  ) async {
    await ref
        .read(playlistRepositoryProvider)
        .reorderPlaylistTracks(playlistId, orderedTrackIds);
    ref.invalidate(playlistDetailProvider(playlistId));
  }
}

final playlistsProvider =
    AsyncNotifierProvider<PlaylistsNotifier, List<Playlist>>(
  PlaylistsNotifier.new,
);

// Individual playlist detail provider (auto-refreshes on invalidation)
final playlistDetailProvider =
    FutureProvider.family<Playlist, String>((ref, id) async {
  return ref.read(playlistRepositoryProvider).getPlaylist(id);
});
