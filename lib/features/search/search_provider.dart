/// Search provider — debounced, paginated.
library;

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../domain/entities/entities.dart';

class SearchState {
  const SearchState({
    this.query = '',
    this.results = const [],
    this.isLoading = false,
    this.hasMore = false,
    this.error,
    this.page = 1,
  });

  final String query;
  final List<SearchResult> results;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final int page;

  SearchState copyWith({
    String? query,
    List<SearchResult>? results,
    bool? isLoading,
    bool? hasMore,
    String? error,
    int? page,
    bool clearError = false,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : error ?? this.error,
      page: page ?? this.page,
    );
  }
}

class SearchNotifier extends Notifier<SearchState> {
  Timer? _debounce;

  @override
  SearchState build() => const SearchState();

  void onQueryChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      state = const SearchState();
      return;
    }
    state = state.copyWith(query: query, isLoading: true, clearError: true);
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _search(query.trim(), page: 1);
    });
  }

  Future<void> _search(String query, {required int page}) async {
    try {
      final page = await ref.read(musicRepositoryProvider).search(query);
      if (state.query != query) return; // stale
      state = state.copyWith(
        results: page.results,
        isLoading: false,
        hasMore: page.hasNextPage,
        page: page.page,
        clearError: true,
      );
    } catch (e) {
      if (state.query != query) return;
      state = state.copyWith(
        isLoading: false,
        error: 'Couldn\'t load results. Check your connection.',
      );
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;
    final query = state.query;
    final nextPage = state.page + 1;
    state = state.copyWith(isLoading: true);
    try {
      final page = await ref
          .read(musicRepositoryProvider)
          .search(query, page: nextPage);
      if (state.query != query) return;
      state = state.copyWith(
        results: [...state.results, ...page.results],
        isLoading: false,
        hasMore: page.hasNextPage,
        page: nextPage,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void clear() {
    _debounce?.cancel();
    state = const SearchState();
  }
}

final searchProvider = NotifierProvider<SearchNotifier, SearchState>(
  SearchNotifier.new,
);
