import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/utils/app_localizations.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    final t = AppLocalizations.tr;

    return Scaffold(
      appBar: AppBar(title: Text(t(locale, 'about_us'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFF0F1E3F), Color(0xFFCDAA80)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t(locale, 'about_title'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  t(locale, 'about_tagline'),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            t(locale, 'about_mission_title'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(t(locale, 'about_mission_body')),
          const SizedBox(height: 20),
          Text(
            t(locale, 'about_values_title'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _ValueTile(
            icon: Icons.favorite_border,
            title: t(locale, 'about_value_dignity'),
          ),
          _ValueTile(
            icon: Icons.shield_outlined,
            title: t(locale, 'about_value_trust'),
          ),
          _ValueTile(
            icon: Icons.flash_on_outlined,
            title: t(locale, 'about_value_speed'),
          ),
          const SizedBox(height: 20),
          Text(
            t(locale, 'about_contact_title'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(t(locale, 'about_contact_body')),
        ],
      ),
    );
  }
}

class _ValueTile extends StatelessWidget {
  const _ValueTile({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
      ),
    );
  }
}


