/// Home feature providers.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../domain/entities/entities.dart';

final trendingProvider = FutureProvider<List<SearchResult>>((ref) async {
  return ref.read(musicRepositoryProvider).getTrending();
});

final historyProvider = FutureProvider<List<HistoryEntry>>((ref) async {
  return ref.read(historyRepositoryProvider).getHistory(limit: 20);
});
