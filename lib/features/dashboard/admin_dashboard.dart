import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/utils/app_localizations.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    final t = AppLocalizations.tr;

    return Scaffold(
      appBar: AppBar(
        title: Text(t(locale, 'admin_dashboard')),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.go('/profile/admin'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SummaryGrid(),
          const SizedBox(height: 16),
          Text(t(locale, 'urgent_actions'),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _ActionRow(
            title: 'Verify urgent food requests',
            subtitle: '4 pending',
            button: 'Review',
          ),
          _ActionRow(
            title: 'Match donors to requests',
            subtitle: '7 pending',
            button: 'Match',
          ),
          const SizedBox(height: 16),
          Text(t(locale, 'admin_tools'),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ToolCard(title: 'Export CSV'),
              _ToolCard(title: 'Export PDF'),
              _ToolCard(title: 'Export JSON'),
              _ToolCard(title: 'User Management'),
            ],
          ),
          const SizedBox(height: 16),
          Text(t(locale, 'audit_log'),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _AuditRow(
            title: 'Request verified',
            subtitle: 'Food assistance • 2h ago',
          ),
          _AuditRow(
            title: 'Aid matched',
            subtitle: 'Medical support • 5h ago',
          ),
          _AuditRow(
            title: 'User flagged',
            subtitle: 'Needs review • yesterday',
          ),
        ],
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: const [
        _SummaryCard(title: 'Requests', value: '128'),
        _SummaryCard(title: 'Completed', value: '74'),
        _SummaryCard(title: 'Urgent', value: '12'),
        _SummaryCard(title: 'Donors', value: '52'),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.title,
    required this.subtitle,
    required this.button,
  });

  final String title;
  final String subtitle;
  final String button;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.priority_high, color: Color(0xFFD32F2F)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: ElevatedButton(
          onPressed: () {},
          child: Text(button),
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const Icon(Icons.table_chart, color: Color(0xFF0F1E3F)),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuditRow extends StatelessWidget {
  const _AuditRow({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.history, color: Color(0xFF0F1E3F)),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}

