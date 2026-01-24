import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/enums.dart';
import '../../core/services/service_providers.dart';
import '../../shared/utils/app_localizations.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/request_card.dart';
import '../notifications/notifications_screen.dart';
import '../requests/create_request_screen.dart';
import '../requests/request_detail_screen.dart';

class SeekerHomeScreen extends ConsumerStatefulWidget {
  const SeekerHomeScreen({super.key});

  @override
  ConsumerState<SeekerHomeScreen> createState() => _SeekerHomeScreenState();
}

class _SeekerHomeScreenState extends ConsumerState<SeekerHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(requestsControllerProvider.notifier).loadForSeeker();
    });
  }

  @override
  Widget build(BuildContext context) {
    final requestsState = ref.watch(requestsControllerProvider);
    final locale = ref.watch(appLocaleProvider);
    final t = AppLocalizations.tr;
    final authState = ref.watch(authControllerProvider);
    final name = authState.user?.name ?? t(locale, 'unknown_user');
    final activeRequests = requestsState.items
        .where((item) =>
            item.status != RequestStatus.completed &&
            item.status != RequestStatus.expired)
        .toList();
    final pendingCount = requestsState.items
        .where((item) => item.status == RequestStatus.submitted)
        .length;
    final inProgressCount = requestsState.items
        .where((item) => item.status == RequestStatus.inProgress)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Text(t(locale, 'my_requests')),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateRequestScreen()),
          );
        },
        child: const Icon(Icons.add),
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
                  t(locale, 'seeker_header_subtitle'),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CreateRequestScreen()),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: Text(t(locale, 'create_request_cta')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(t(locale, 'my_activity'),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: t(locale, 'pending_support'),
                  value: pendingCount.toString(),
                  icon: Icons.hourglass_top,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  label: t(locale, 'status_in_progress'),
                  value: inProgressCount.toString(),
                  icon: Icons.local_shipping_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(t(locale, 'active_requests'),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (requestsState.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (activeRequests.isEmpty)
            EmptyState(
              title: t(locale, 'no_active_requests'),
              subtitle: t(locale, 'new_request'),
            )
          else
            ...activeRequests.map(
              (request) => RequestCard(
                request: request,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RequestDetailScreen(
                        request: request,
                        isSeeker: true,
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



