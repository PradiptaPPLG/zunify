/// Player state model.
library;

import '../../domain/entities/entities.dart';
import '../../features/settings/settings_provider.dart';

enum PlayerStatus { idle, loading, playing, paused, error, completed }

class PlayerState {
  const PlayerState({
    this.currentTrack,
    this.status = PlayerStatus.idle,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.queue = const [],
    this.queueIndex = -1,
    this.shuffleEnabled = false,
    this.shuffledIndices = const [],
    this.repeatMode = AudioRepeatMode.off,
    this.volume = 1.0,
    this.error,
  });

  final Track? currentTrack;
  final PlayerStatus status;
  final Duration position;
  final Duration duration;
  final Duration bufferedPosition;
  final List<Track> queue;
  final int queueIndex;
  final bool shuffleEnabled;
  final List<int> shuffledIndices; // indices into queue
  final AudioRepeatMode repeatMode;
  final double volume;
  final String? error;

  bool get isPlaying => status == PlayerStatus.playing;
  bool get isLoading => status == PlayerStatus.loading;
  bool get hasTrack => currentTrack != null;
  bool get hasNext => _nextIndex != null;
  bool get hasPrevious => _previousIndex != null;

  int? get _nextIndex {
    if (queue.isEmpty) return null;
    if (repeatMode == AudioRepeatMode.one) return queueIndex;
    if (shuffleEnabled && shuffledIndices.isNotEmpty) {
      final currentShufflePos = shuffledIndices.indexOf(queueIndex);
      if (currentShufflePos < shuffledIndices.length - 1) {
        return shuffledIndices[currentShufflePos + 1];
      }
      if (repeatMode == AudioRepeatMode.all) return shuffledIndices[0];
      return null;
    }
    if (queueIndex < queue.length - 1) return queueIndex + 1;
    if (repeatMode == AudioRepeatMode.all) return 0;
    return null;
  }

  int? get _previousIndex {
    if (queue.isEmpty) return null;
    if (shuffleEnabled && shuffledIndices.isNotEmpty) {
      final currentShufflePos = shuffledIndices.indexOf(queueIndex);
      if (currentShufflePos > 0) {
        return shuffledIndices[currentShufflePos - 1];
      }
      return null;
    }
    if (queueIndex > 0) return queueIndex - 1;
    return null;
  }

  int? get nextQueueIndex => _nextIndex;
  int? get previousQueueIndex => _previousIndex;

  PlayerState copyWith({
    Track? currentTrack,
    PlayerStatus? status,
    Duration? position,
    Duration? duration,
    Duration? bufferedPosition,
    List<Track>? queue,
    int? queueIndex,
    bool? shuffleEnabled,
    List<int>? shuffledIndices,
    AudioRepeatMode? repeatMode,
    double? volume,
    String? error,
    bool clearError = false,
    bool clearTrack = false,
  }) {
    return PlayerState(
      currentTrack: clearTrack ? null : currentTrack ?? this.currentTrack,
      status: status ?? this.status,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      queue: queue ?? this.queue,
      queueIndex: queueIndex ?? this.queueIndex,
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
      shuffledIndices: shuffledIndices ?? this.shuffledIndices,
      repeatMode: repeatMode ?? this.repeatMode,
      volume: volume ?? this.volume,
      error: clearError ? null : error ?? this.error,
    );
  }
}
