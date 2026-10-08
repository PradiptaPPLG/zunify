/// Audio player notifier — manages just_audio + audio_service integration.
library;

import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../../app/providers.dart';
import '../../domain/entities/entities.dart';
import '../../features/settings/settings_provider.dart';
import 'player_state.dart' as ps;

class PlayerNotifier extends Notifier<ps.PlayerState> {
  late AudioPlayer _player;
  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<Duration>? _bufferedSub;
  StreamSubscription<ProcessingState>? _processingStateSub;

  @override
  ps.PlayerState build() {
    _player = AudioPlayer();
    _setupSubscriptions();
    ref.onDispose(() {
      _playerStateSub?.cancel();
      _positionSub?.cancel();
      _durationSub?.cancel();
      _bufferedSub?.cancel();
      _processingStateSub?.cancel();
      _player.dispose();
    });
    return const ps.PlayerState();
  }

  void _setupSubscriptions() {
    _playerStateSub = _player.playerStateStream.listen((s) {
      final isPlaying = s.playing;
      ps.PlayerStatus status;
      switch (s.processingState) {
        case ProcessingState.idle:
          status = ps.PlayerStatus.idle;
        case ProcessingState.loading:
        case ProcessingState.buffering:
          status = ps.PlayerStatus.loading;
        case ProcessingState.ready:
          status = isPlaying ? ps.PlayerStatus.playing : ps.PlayerStatus.paused;
        case ProcessingState.completed:
          status = ps.PlayerStatus.completed;
          _onTrackCompleted();
      }
      state = state.copyWith(status: status, clearError: true);
    });

    _positionSub = _player.positionStream.listen((pos) {
      state = state.copyWith(position: pos);
    });

    _durationSub = _player.durationStream.listen((dur) {
      if (dur != null) state = state.copyWith(duration: dur);
    });

    _bufferedSub = _player.bufferedPositionStream.listen((buf) {
      state = state.copyWith(bufferedPosition: buf);
    });
  }

  // ─── Public API ──────────────────────────────────────────────────────

  Future<void> playTrack(Track track, {List<Track>? queue}) async {
    final newQueue = queue ?? [track];
    final index = newQueue.indexOf(track);
    final actualIndex = index == -1 ? 0 : index;

    state = state.copyWith(
      currentTrack: track,
      queue: newQueue,
      queueIndex: actualIndex,
      status: ps.PlayerStatus.loading,
      position: Duration.zero,
      duration: Duration.zero,
      clearError: true,
    );

    if (state.shuffleEnabled) {
      _applyShuffleFrom(actualIndex, newQueue.length);
    }

    await _resolveAndPlay(track);

    // Record history
    try {
      await ref.read(historyRepositoryProvider).recordPlay(track);
    } catch (_) {}
  }

  Future<void> _resolveAndPlay(Track track) async {
    try {
      final url = await ref
          .read(musicRepositoryProvider)
          .resolveStreamUrl(track.sourceId);

      // Check if we're still supposed to play this track
      if (state.currentTrack?.sourceId != track.sourceId) return;

      final audioSource = AudioSource.uri(
        Uri.parse(url),
        tag: MediaItem(
          id: track.sourceId,
          title: track.title,
          artist: track.artist,
          artUri: track.thumbnailUrl != null ? Uri.parse(track.thumbnailUrl!) : null,
        ),
      );
      await _player.setAudioSource(audioSource);
      await _player.play();
    } catch (e, st) {
      print('PLAYER ERROR: $e\n$st');
      if (state.currentTrack?.sourceId == track.sourceId) {
        state = state.copyWith(
          status: ps.PlayerStatus.error,
          error: 'This track is currently unavailable.',
        );
      }
    }
  }

  Future<void> play() async => _player.play();
  Future<void> pause() async => _player.pause();

  Future<void> togglePlay() async {
    if (state.isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> seek(Duration position) async => _player.seek(position);

  Future<void> next() async {
    final nextIdx = state.nextQueueIndex;
    if (nextIdx == null) return;
    final track = state.queue[nextIdx];
    state = state.copyWith(queueIndex: nextIdx, currentTrack: track);
    await _resolveAndPlay(track);
  }

  Future<void> previous() async {
    // If more than 3s in, restart current; otherwise go previous
    if (state.position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }
    final prevIdx = state.previousQueueIndex;
    if (prevIdx == null) {
      await seek(Duration.zero);
      return;
    }
    final track = state.queue[prevIdx];
    state = state.copyWith(queueIndex: prevIdx, currentTrack: track);
    await _resolveAndPlay(track);
  }

  void toggleShuffle() {
    final newShuffle = !state.shuffleEnabled;
    if (newShuffle) {
      _applyShuffleFrom(state.queueIndex, state.queue.length);
    } else {
      state = state.copyWith(shuffleEnabled: false, shuffledIndices: []);
    }
  }

  void _applyShuffleFrom(int currentIndex, int queueLength) {
    final indices = List.generate(queueLength, (i) => i)
      ..remove(currentIndex)
      ..shuffle(Random());
    indices.insert(0, currentIndex);
    state = state.copyWith(
      shuffleEnabled: true,
      shuffledIndices: indices,
    );
  }

  void cycleRepeat() {
    final modes = AudioRepeatMode.values;
    final nextMode = modes[(state.repeatMode.index + 1) % modes.length];
    state = state.copyWith(repeatMode: nextMode);
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
    state = state.copyWith(volume: volume);
  }

  void addToQueue(Track track) {
    if (state.queue.any((t) => t.sourceId == track.sourceId)) return;
    state = state.copyWith(queue: [...state.queue, track]);
  }

  void removeFromQueue(int index) {
    if (index == state.queueIndex) return; // can't remove current
    final newQueue = List<Track>.from(state.queue)..removeAt(index);
    final newIndex = index < state.queueIndex
        ? state.queueIndex - 1
        : state.queueIndex;
    state = state.copyWith(queue: newQueue, queueIndex: newIndex);
  }

  void clearQueue() {
    state = state.copyWith(queue: [], queueIndex: -1, clearTrack: true);
    _player.stop();
  }

  Future<void> playFromQueue(int index) async {
    if (index < 0 || index >= state.queue.length) return;
    final track = state.queue[index];
    state = state.copyWith(queueIndex: index, currentTrack: track);
    await _resolveAndPlay(track);
  }

  void _onTrackCompleted() {
    final nextIdx = state.nextQueueIndex;
    if (nextIdx != null) {
      Future.microtask(() => playFromQueue(nextIdx));
    } else {
      // Check autoplay setting
      final settings = ref.read(settingsProvider).valueOrNull;
      if (settings?.autoplay == true) {
        // Could load recommendations here
      }
    }
  }
}

final playerProvider = NotifierProvider<PlayerNotifier, ps.PlayerState>(
  PlayerNotifier.new,
);
