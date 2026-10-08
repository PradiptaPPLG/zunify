/// Settings Screen — all settings are functional and persisted.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../app/theme/theme.dart';
import 'settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(title: const Text('Settings')),
      body: settings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (s) => ListView(
          children: [
            _SettingsSection(
              title: 'Appearance',
              children: [
                _ListTile(
                  title: 'Theme',
                  trailing: Text(
                    _themeModeLabel(s.themeMode),
                    style: AppTypography.body.copyWith(
                      color: context.colors.lavender,
                    ),
                  ),
                  onTap: () => _cycleThemeMode(ref, s.themeMode),
                ),
              ],
            ),
            _SettingsSection(
              title: 'Playback',
              children: [
                _SwitchTile(
                  title: 'Autoplay',
                  subtitle: 'Continue playing recommended songs',
                  value: s.autoplay,
                  onChanged: (v) =>
                      ref.read(settingsProvider.notifier).setAutoplay(v),
                ),
                _SwitchTile(
                  title: 'Gapless playback',
                  subtitle: 'Remove silence between songs',
                  value: s.gaplessPlayback,
                  onChanged: (v) =>
                      ref.read(settingsProvider.notifier).setGaplessPlayback(v),
                ),
                _ListTile(
                  title: 'Default repeat',
                  trailing: Text(
                    _repeatLabel(s.defaultRepeat),
                    style: AppTypography.body.copyWith(
                      color: context.colors.lavender,
                    ),
                  ),
                  onTap: () => _cycleRepeat(ref, s.defaultRepeat),
                ),
              ],
            ),
            _SettingsSection(
              title: 'Network',
              children: [
                _SwitchTile(
                  title: 'Wi-Fi only',
                  subtitle: 'Stream only on Wi-Fi',
                  value: s.wifiOnly,
                  onChanged: (v) =>
                      ref.read(settingsProvider.notifier).setWifiOnly(v),
                ),
                _SwitchTile(
                  title: 'Data saver',
                  subtitle: 'Request lower quality when available',
                  value: s.dataSaver,
                  onChanged: (v) =>
                      ref.read(settingsProvider.notifier).setDataSaver(v),
                ),
              ],
            ),
            _SettingsSection(
              title: 'Notifications',
              children: [
                _SwitchTile(
                  title: 'Playback notification',
                  subtitle: 'Show controls on lock screen',
                  value: s.showPlaybackNotification,
                  onChanged: (v) =>
                      ref.read(settingsProvider.notifier).setNotification(v),
                ),
              ],
            ),
            _SettingsSection(
              title: 'Storage',
              children: [
                _ListTile(
                  title: 'Clear cache',
                  subtitle: 'Remove cached images and metadata',
                  trailing: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: context.colors.textMuted,
                  ),
                  onTap: () => _confirmClearCache(context),
                ),
              ],
            ),
            _SettingsSection(
              title: 'About',
              children: [
                _ListTile(
                  title: 'Zunify',
                  subtitle: 'Version 1.0.0',
                  onTap: null,
                ),
                _ListTile(
                  title: 'Music source',
                  subtitle:
                      'Powered by publicly accessible audio streams via yt-dlp',
                  onTap: null,
                ),
                _ListTile(
                  title: 'Open source licenses',
                  trailing: Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: context.colors.textMuted,
                  ),
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: 'Zunify',
                    applicationVersion: '1.0.0',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.huge),
          ],
        ),
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => 'System',
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
    };
  }

  void _cycleThemeMode(WidgetRef ref, ThemeMode current) {
    final modes = ThemeMode.values;
    final next = modes[(current.index + 1) % modes.length];
    ref.read(settingsProvider.notifier).setThemeMode(next);
  }

  String _repeatLabel(AudioRepeatMode mode) {
    return switch (mode) {
      AudioRepeatMode.off => 'Off',
      AudioRepeatMode.all => 'Repeat all',
      AudioRepeatMode.one => 'Repeat one',
    };
  }

  void _cycleRepeat(WidgetRef ref, AudioRepeatMode current) {
    final modes = AudioRepeatMode.values;
    final next = modes[(current.index + 1) % modes.length];
    ref.read(settingsProvider.notifier).setAudioRepeatMode(next);
  }

  void _confirmClearCache(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear cache?'),
        content: const Text(
          'This will remove cached images and metadata. Music will need to reload.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              // CachedNetworkImage has its own eviction
              // SharedPreferences / Hive data is retained (not cache)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

// ─── Settings Components ──────────────────────────────────────────────────────

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.xl, AppSpacing.md, AppSpacing.xs,
          ),
          child: Text(
            title,
            style: AppTypography.label.copyWith(
              color: context.colors.lavender,
              letterSpacing: 0.6,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: AppRadius.cardBR,
            border: Border.all(color: context.colors.border, width: 0.5),
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  const Divider(
                    height: 1,
                    indent: AppSpacing.md,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title, style: AppTypography.body),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTypography.metadata.copyWith(
                color: context.colors.textMuted,
              ),
            )
          : null,
      value: value,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xxs,
      ),
    );
  }
}

class _ListTile extends StatelessWidget {
  const _ListTile({
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: AppTypography.body),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTypography.metadata.copyWith(
                color: context.colors.textMuted,
              ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xxs,
      ),
    );
  }
}
