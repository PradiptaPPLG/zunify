/// Favorites Riverpod provider.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../domain/entities/entities.dart';

class FavoritesNotifier extends AsyncNotifier<List<Track>> {
  @override
  Future<List<Track>> build() async {
    return ref.read(favoritesRepositoryProvider).getFavorites();
  }

  Future<void> add(Track track) async {
    await ref.read(favoritesRepositoryProvider).addFavorite(track);
    final current = state.valueOrNull ?? [];
    if (!current.any((t) => t.sourceId == track.sourceId)) {
      state = AsyncData([track, ...current]);
    }
  }

  Future<void> remove(String sourceId) async {
    await ref.read(favoritesRepositoryProvider).removeFavorite(sourceId);
    final current = state.valueOrNull ?? [];
    state = AsyncData(current.where((t) => t.sourceId != sourceId).toList());
  }

  Future<void> toggle(Track track) async {
    final current = state.valueOrNull ?? [];
    if (current.any((t) => t.sourceId == track.sourceId)) {
      await remove(track.sourceId);
    } else {
      await add(track);
    }
  }

  bool isFavorite(String sourceId) {
    return state.valueOrNull?.any((t) => t.sourceId == sourceId) ?? false;
  }
}

final favoritesProvider =
    AsyncNotifierProvider<FavoritesNotifier, List<Track>>(
  FavoritesNotifier.new,
);
