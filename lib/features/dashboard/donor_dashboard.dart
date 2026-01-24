import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/utils/app_localizations.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/skeleton_loader.dart';

class DonorDashboard extends ConsumerWidget {
  const DonorDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    final t = AppLocalizations.tr;

    return Scaffold(
      appBar: AppBar(
        title: Text(t(locale, 'donor_dashboard')),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.go('/profile/donor'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.campaign, color: Color(0xFFD32F2F)),
              title: Text(t(locale, 'urgent_aid')),
              subtitle: const Text('Perishable food and urgent medicine'),
              trailing: OutlinedButton(
                onPressed: () {},
                child: Text(t(locale, 'see_nearby')),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(t(locale, 'filters'),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _FilterChip(label: t(locale, 'aid_food')),
              _FilterChip(label: t(locale, 'aid_medical')),
              _FilterChip(label: t(locale, 'aid_ceremony')),
              _FilterChip(label: t(locale, 'aid_cash')),
            ],
          ),
          const SizedBox(height: 16),
          Text(t(locale, 'requests_tab'),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _RequestCard(
            title: t(locale, 'aid_food'),
            subtitle: 'Needs: 20 meals, expiring today',
            urgent: true,
            onOffer: () {},
          ),
          _RequestCard(
            title: t(locale, 'aid_medical'),
            subtitle: 'Insulin refill needed within 24h',
            urgent: true,
            onOffer: () {},
          ),
          _RequestCard(
            title: t(locale, 'aid_school'),
            subtitle: 'School supplies for 3 students',
            urgent: false,
            onOffer: () {},
          ),
          const SizedBox(height: 16),
          Text(t(locale, 'history'),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const SkeletonLoader(height: 18),
          const SizedBox(height: 8),
          const SkeletonLoader(height: 18),
          const SizedBox(height: 16),
          const EmptyState(
            title: 'No contributions yet',
            subtitle: 'Offer aid to start making impact.',
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: const Color(0xFFCDAA80).withOpacity(0.12),
      label: Text(label),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.title,
    required this.subtitle,
    required this.urgent,
    required this.onOffer,
  });

  final String title;
  final String subtitle;
  final bool urgent;
  final VoidCallback onOffer;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          urgent ? Icons.warning_amber : Icons.check_circle_outline,
          color: urgent ? const Color(0xFFD32F2F) : const Color(0xFFCDAA80),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: ElevatedButton(
          onPressed: onOffer,
          child: const Text('Offer this aid'),
        ),
      ),
    );
  }
}

