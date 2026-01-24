import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/enums.dart';
import '../../shared/utils/app_localizations.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/skeleton_loader.dart';
import '../../shared/widgets/status_timeline.dart';

class SeekerDashboard extends ConsumerWidget {
  const SeekerDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    final t = AppLocalizations.tr;
    return Scaffold(
      appBar: AppBar(
        title: Text(t(locale, 'seeker_dashboard')),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.go('/profile/seeker'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _UrgentNotice(title: t(locale, 'urgent_aid')),
          const SizedBox(height: 16),
          Text(t(locale, 'my_requests'),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t(locale, 'aid_food'),
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  StatusTimeline(
                    steps: [
                      t(locale, 'status_draft'),
                      t(locale, 'status_submitted'),
                      t(locale, 'status_verified'),
                      t(locale, 'status_matched'),
                      t(locale, 'status_in_progress'),
                      t(locale, 'status_completed'),
                    ],
                    currentIndex: 2,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _Badge(text: t(locale, 'urgent_food')),
                      const SizedBox(width: 8),
                      _Badge(text: t(locale, 'delivery_pickup')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(t(locale, 'pending_support'),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const SkeletonLoader(height: 20),
          const SizedBox(height: 8),
          const SkeletonLoader(height: 20),
          const SizedBox(height: 16),
          const EmptyState(
            title: 'No received aid yet',
            subtitle: 'When aid arrives it will appear here.',
          ),
          const SizedBox(height: 16),
          Text(t(locale, 'request_types'),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: AidType.values.map((type) {
              return _TypeTile(type: type, locale: locale);
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _UrgentNotice extends StatelessWidget {
  const _UrgentNotice({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFF1F2),
      child: ListTile(
        leading: const Icon(Icons.warning_amber, color: Color(0xFFD32F2F)),
        title: Text(title),
        subtitle: const Text('Immediate help available nearby.'),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: const Color(0xFF0F1E3F).withOpacity(0.08),
      label: Text(text),
    );
  }
}

class _TypeTile extends StatelessWidget {
  const _TypeTile({required this.type, required this.locale});

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
              Text(_labelFor(t, locale, type)),
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

  String _labelFor(Function tr, Locale locale, AidType type) {
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

