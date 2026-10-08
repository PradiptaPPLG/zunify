/// Zunify main app widget.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router/router.dart';
import 'theme/theme.dart';

import '../features/settings/settings_provider.dart';

class ZunifyApp extends ConsumerWidget {
  const ZunifyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).valueOrNull;
    
    return MaterialApp.router(
      title: 'Zunify',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings?.themeMode ?? ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
