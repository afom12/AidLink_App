import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/enums.dart';
import '../../shared/utils/app_localizations.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/skeleton_loader.dart';

class DashboardShell extends ConsumerStatefulWidget {
  const DashboardShell({super.key});

  @override
  ConsumerState<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends ConsumerState<DashboardShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(appLocaleProvider);
    final t = AppLocalizations.tr;

    return Scaffold(
      appBar: AppBar(
        title: Text(t(locale, 'dashboard')),
      ),
      body: IndexedStack(
        index: _index,
        children: [
          _HomeTab(locale: locale),
          const _RequestsTab(),
          const _NotificationsTab(),
          const _ProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (value) => setState(() => _index = value),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            label: t(locale, 'home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.assignment_outlined),
            label: t(locale, 'requests_tab'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.notifications_none),
            label: t(locale, 'notifications_tab'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            label: t(locale, 'profile_tab'),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Text(t(locale, 'app_name')),
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
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.locale});

  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.tr;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.warning_amber, color: Color(0xFFD32F2F)),
            title: Text(t(locale, 'urgent_aid')),
            subtitle: Text(t(locale, 'see_nearby')),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
        const SizedBox(height: 12),
        Text(t(locale, 'explore_aid_types'),
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: AidType.values.map((type) {
            return _AidTypeCard(type: type, locale: locale);
          }).toList(),
        ),
        const SizedBox(height: 20),
        Text('Loading preview',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        const SkeletonLoader(height: 20),
        const SizedBox(height: 8),
        const SkeletonLoader(height: 20),
      ],
    );
  }
}

class _AidTypeCard extends StatelessWidget {
  const _AidTypeCard({required this.type, required this.locale});

  final AidType type;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.tr;
    return SizedBox(
      width: 150,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(_iconFor(type), color: const Color(0xFF0F1E3F)),
              const SizedBox(height: 8),
              Text(_labelFor(type, t, locale)),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(AidType type) {
    switch (type) {
      case AidType.food:
        return Icons.fastfood;
      case AidType.clothing:
        return Icons.checkroom;
      case AidType.medical:
        return Icons.medical_services;
      case AidType.cash:
        return Icons.payments;
      case AidType.school:
        return Icons.school;
      case AidType.housing:
        return Icons.home;
      case AidType.ceremony:
        return Icons.celebration;
      case AidType.other:
        return Icons.volunteer_activism;
    }
  }

  String _labelFor(AidType type, Function tr, Locale locale) {
    switch (type) {
      case AidType.food:
        return tr(locale, 'aid_food');
      case AidType.clothing:
        return tr(locale, 'aid_clothing');
      case AidType.medical:
        return tr(locale, 'aid_medical');
      case AidType.cash:
        return tr(locale, 'aid_cash');
      case AidType.school:
        return tr(locale, 'aid_school');
      case AidType.housing:
        return tr(locale, 'aid_housing');
      case AidType.ceremony:
        return tr(locale, 'aid_ceremony');
      case AidType.other:
        return tr(locale, 'aid_other');
    }
  }
}

class _RequestsTab extends StatelessWidget {
  const _RequestsTab();

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      title: 'No requests yet',
      subtitle: 'Create or accept requests to see activity here.',
    );
  }
}

class _NotificationsTab extends StatelessWidget {
  const _NotificationsTab();

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      title: 'No notifications',
      subtitle: 'You will receive updates here.',
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      title: 'Profile setup',
      subtitle: 'Complete your profile to build trust.',
    );
  }
}

