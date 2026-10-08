/// Settings state management — persisted via shared_preferences.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Settings Model ───────────────────────────────────────────────────────────
import 'package:flutter/material.dart';

class AppSettings {
  const AppSettings({
    this.autoplay = true,
    this.gaplessPlayback = true,
    this.wifiOnly = false,
    this.dataSaver = false,
    this.defaultRepeat = AudioRepeatMode.off,
    this.defaultShuffle = false,
    this.showPlaybackNotification = true,
    this.themeMode = ThemeMode.system,
  });

  final bool autoplay;
  final bool gaplessPlayback;
  final bool wifiOnly;
  final bool dataSaver;
  final AudioRepeatMode defaultRepeat;
  final bool defaultShuffle;
  final bool showPlaybackNotification;
  final ThemeMode themeMode;

  AppSettings copyWith({
    bool? autoplay,
    bool? gaplessPlayback,
    bool? wifiOnly,
    bool? dataSaver,
    AudioRepeatMode? defaultRepeat,
    bool? defaultShuffle,
    bool? showPlaybackNotification,
    ThemeMode? themeMode,
  }) {
    return AppSettings(
      autoplay: autoplay ?? this.autoplay,
      gaplessPlayback: gaplessPlayback ?? this.gaplessPlayback,
      wifiOnly: wifiOnly ?? this.wifiOnly,
      dataSaver: dataSaver ?? this.dataSaver,
      defaultRepeat: defaultRepeat ?? this.defaultRepeat,
      defaultShuffle: defaultShuffle ?? this.defaultShuffle,
      showPlaybackNotification:
          showPlaybackNotification ?? this.showPlaybackNotification,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

enum AudioRepeatMode { off, all, one }

// ─── Notifier ────────────────────────────────────────────────────────────────

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  static const _keyAutoplay = 'autoplay';
  static const _keyGapless = 'gapless';
  static const _keyWifiOnly = 'wifi_only';
  static const _keyDataSaver = 'data_saver';
  static const _keyRepeat = 'repeat_mode';
  static const _keyShuffle = 'default_shuffle';
  static const _keyNotification = 'playback_notification';
  static const _keyThemeMode = 'theme_mode';

  @override
  Future<AppSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      autoplay: prefs.getBool(_keyAutoplay) ?? true,
      gaplessPlayback: prefs.getBool(_keyGapless) ?? true,
      wifiOnly: prefs.getBool(_keyWifiOnly) ?? false,
      dataSaver: prefs.getBool(_keyDataSaver) ?? false,
      defaultRepeat: AudioRepeatMode.values[prefs.getInt(_keyRepeat) ?? 0],
      defaultShuffle: prefs.getBool(_keyShuffle) ?? false,
      showPlaybackNotification: prefs.getBool(_keyNotification) ?? true,
      themeMode: ThemeMode.values[prefs.getInt(_keyThemeMode) ?? 0],
    );
  }

  Future<void> setAutoplay(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoplay, value);
    state = AsyncData(state.requireValue.copyWith(autoplay: value));
  }

  Future<void> setGaplessPlayback(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyGapless, value);
    state = AsyncData(state.requireValue.copyWith(gaplessPlayback: value));
  }

  Future<void> setWifiOnly(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyWifiOnly, value);
    state = AsyncData(state.requireValue.copyWith(wifiOnly: value));
  }

  Future<void> setDataSaver(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDataSaver, value);
    state = AsyncData(state.requireValue.copyWith(dataSaver: value));
  }

  Future<void> setAudioRepeatMode(AudioRepeatMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyRepeat, mode.index);
    state = AsyncData(state.requireValue.copyWith(defaultRepeat: mode));
  }

  Future<void> setDefaultShuffle(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShuffle, value);
    state = AsyncData(state.requireValue.copyWith(defaultShuffle: value));
  }

  Future<void> setNotification(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotification, value);
    state = AsyncData(
      state.requireValue.copyWith(showPlaybackNotification: value),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeMode, mode.index);
    state = AsyncData(state.requireValue.copyWith(themeMode: mode));
  }
}

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
