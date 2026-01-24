import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../shared/utils/app_localizations.dart';
import '../../shared/utils/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key, required this.role});

  final String role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    final t = AppLocalizations.tr;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t(locale, 'settings'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            value: themeMode == ThemeMode.dark,
            onChanged: (_) {
              ref.read(themeModeProvider.notifier).state =
                  themeMode == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark;
            },
            title: Text(t(locale, 'toggle_dark_mode')),
          ),
          SwitchListTile(
            value: true,
            onChanged: (_) {},
            title: Text(t(locale, 'notifications_tab')),
            subtitle: Text(t(locale, 'notifications_settings')),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: Text(t(locale, 'notifications_tab')),
            onTap: () => context.go('/notifications'),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(t(locale, 'language')),
            onTap: () {
              ref.read(appLocaleProvider.notifier).state =
                  locale.languageCode == 'en'
                      ? const Locale('am')
                      : const Locale('en');
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: Text(t(locale, 'change_password')),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(t(locale, 'about_us')),
            onTap: () => context.go('/about'),
          ),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: Text(t(locale, 'feedback')),
            onTap: () => context.go('/feedback'),
          ),
        ],
      ),
    );
  }
}


