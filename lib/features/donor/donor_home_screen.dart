import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/enums.dart';
import '../../core/services/service_providers.dart';
import '../../shared/utils/app_localizations.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/request_card.dart';
import '../donor/impact_history_screen.dart';
import '../requests/request_detail_screen.dart';

class DonorHomeScreen extends ConsumerStatefulWidget {
  const DonorHomeScreen({super.key});

  @override
  ConsumerState<DonorHomeScreen> createState() => _DonorHomeScreenState();
}

class _DonorHomeScreenState extends ConsumerState<DonorHomeScreen> {
  AidType? _filter;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(requestsControllerProvider.notifier).loadForDonor();
    });
  }

  @override
  Widget build(BuildContext context) {
    final requestsState = ref.watch(requestsControllerProvider);
    final locale = ref.watch(appLocaleProvider);
    final t = AppLocalizations.tr;
    final authState = ref.watch(authControllerProvider);
    final name = authState.user?.name ?? t(locale, 'unknown_user');
    final totalRequests = requestsState.items.length;
    final urgentRequests = requestsState.items
        .where((request) =>
            request.isUrgentFood ||
            request.urgency == UrgencyLevel.high ||
            request.urgency == UrgencyLevel.critical)
        .toList();
    final nearbyCount = requestsState.items
        .where((request) => (request.distanceKm ?? 99) <= 5)
        .length;
    final recentRequests = requestsState.items.take(6).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(t(locale, 'browse_requests')),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => context.go('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.insights),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ImpactHistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
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
                  '${t(locale, 'greeting')}, $name',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  t(locale, 'donor_header_subtitle'),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(t(locale, 'impact_snapshot'),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: t(locale, 'total_requests'),
                  value: totalRequests.toString(),
                  icon: Icons.assignment_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  label: t(locale, 'urgent_requests'),
                  value: urgentRequests.length.toString(),
                  icon: Icons.warning_amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _StatTile(
            label: t(locale, 'nearby_requests'),
            value: nearbyCount.toString(),
            icon: Icons.place_outlined,
          ),
          const SizedBox(height: 16),
          Text(t(locale, 'filters'),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              children: [
                _buildFilterChip(null, t(locale, 'all')),
                for (final type in AidType.values)
                  _buildFilterChip(type, _typeLabel(locale, type)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(t(locale, 'urgent_requests'),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (requestsState.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (urgentRequests.isEmpty)
            EmptyState(
              title: t(locale, 'no_urgent_requests'),
              subtitle: t(locale, 'urgent_food_help'),
            )
          else
            ...urgentRequests.take(3).map(
                  (request) => RequestCard(
                    request: request,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RequestDetailScreen(
                            request: request,
                            isSeeker: false,
                          ),
                        ),
                      );
                    },
                  ),
                ),
          const SizedBox(height: 16),
          Text(t(locale, 'recent_requests'),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (requestsState.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (recentRequests.isEmpty)
            EmptyState(
              title: t(locale, 'no_requests'),
              subtitle: t(locale, 'urgent_food_help'),
            )
          else
            ...recentRequests.map(
              (request) => RequestCard(
                request: request,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RequestDetailScreen(
                        request: request,
                        isSeeker: false,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(AidType? type, String label) {
    final isSelected = _filter == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() => _filter = type);
          ref.read(requestsControllerProvider.notifier).loadForDonor(
                filter: type,
              );
        },
      ),
    );
  }

  String _typeLabel(Locale locale, AidType type) {
    switch (type) {
      case AidType.food:
        return AppLocalizations.tr(locale, 'aid_food');
      case AidType.clothing:
        return AppLocalizations.tr(locale, 'aid_clothing');
      case AidType.medical:
        return AppLocalizations.tr(locale, 'aid_medical');
      case AidType.cash:
        return AppLocalizations.tr(locale, 'aid_cash');
      case AidType.school:
        return AppLocalizations.tr(locale, 'aid_school');
      case AidType.housing:
        return AppLocalizations.tr(locale, 'aid_housing');
      case AidType.ceremony:
        return AppLocalizations.tr(locale, 'aid_ceremony');
      case AidType.other:
        return AppLocalizations.tr(locale, 'aid_other');
    }
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.12),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

