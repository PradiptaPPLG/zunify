/// Search Screen — real search with debounce, pagination, error/empty states.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/router/routes.dart';
import '../../app/theme/theme.dart';
import '../../features/player/player_notifier.dart';
import '../../features/player/player_state.dart' as ps;
import '../../shared/widgets/music_list_tile.dart';
import '../../shared/widgets/states.dart';
import '../../shared/widgets/track_options.dart';
import 'search_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _ctrl;
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      ref.read(searchProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final search = ref.watch(searchProvider);
    final playerState = ref.watch(playerProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Column(
          children: [
            _SearchBar(ctrl: _ctrl),
            Expanded(
              child: _SearchBody(
                state: search,
                playerState: playerState,
                scrollCtrl: _scrollCtrl,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends ConsumerWidget {
  const _SearchBar({required this.ctrl});
  final TextEditingController ctrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: ctrl,
              autofocus: true,
              onChanged: (q) =>
                  ref.read(searchProvider.notifier).onQueryChanged(q),
              decoration: InputDecoration(
                hintText: 'Search songs, artists, albums...',
                prefixIcon: Icon(
                  Icons.search,
                  color: context.colors.textMuted,
                  size: 20,
                ),
                suffixIcon: ctrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        color: context.colors.textMuted,
                        onPressed: () {
                          ctrl.clear();
                          ref.read(searchProvider.notifier).clear();
                        },
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBody extends ConsumerWidget {
  const _SearchBody({
    required this.state,
    required this.playerState,
    required this.scrollCtrl,
  });

  final SearchState state;
  final ps.PlayerState playerState;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.query.isEmpty) {
      return const _InitialSearchState();
    }

    if (state.isLoading && state.results.isEmpty) {
      return ListView(
        children: List.generate(6, (_) => const ShimmerTile()),
      );
    }

    if (state.error != null && state.results.isEmpty) {
      return ErrorState(
        message: state.error!,
        onRetry: () =>
            ref.read(searchProvider.notifier).onQueryChanged(state.query),
      );
    }

    if (!state.isLoading && state.results.isEmpty) {
      return EmptyState(
        title: 'No results found',
        subtitle:
            'Try another artist, song title, or keyword.',
        icon: Icons.search_off,
      );
    }

    return ListView.builder(
      controller: scrollCtrl,
      itemCount: state.results.length + (state.hasMore ? 1 : 0),
      itemBuilder: (_, i) {
        if (i == state.results.length) {
          return state.isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Center(child: CircularProgressIndicator()),
                )
              : const SizedBox.shrink();
        }

        final result = state.results[i];
        final track = result.toTrack();
        final isCurrent = playerState.currentTrack?.sourceId == track.sourceId;

        return SearchResultTile(
          result: result,
          isPlaying: isCurrent && playerState.isPlaying,
          showDivider: i < state.results.length - 1,
          onTap: () => ref.read(playerProvider.notifier).playTrack(
            track,
            queue: state.results.map((r) => r.toTrack()).toList(),
          ),
          onMore: () => showTrackOptions(context, track),
        );
      },
    );
  }
}

class _InitialSearchState extends StatelessWidget {
  const _InitialSearchState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: context.colors.blueLight,
              borderRadius: BorderRadius.circular(AppRadius.large),
            ),
            child: Icon(
              Icons.search,
              color: context.colors.blue,
              size: 28,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Search music',
            style: AppTypography.heading3.copyWith(
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Find songs, artists, and albums.',
            style: AppTypography.body.copyWith(
              color: context.colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
