import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/enums.dart';
import '../../shared/utils/app_localizations.dart';
import '../../shared/utils/role_provider.dart';
import '../../shared/widgets/primary_button.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    final t = AppLocalizations.tr;

    return Scaffold(
      appBar: AppBar(title: Text(t(locale, 'get_started'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            t(locale, 'choose_role'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(t(locale, 'role_explainer')),
          const SizedBox(height: 20),
          _RoleCard(
            icon: Icons.volunteer_activism,
            title: t(locale, 'seeker'),
            subtitle: t(locale, 'role_seeker_desc'),
            onTap: () => _openAuthChoice(context, ref, UserRole.seeker),
          ),
          const SizedBox(height: 12),
          _RoleCard(
            icon: Icons.handshake,
            title: t(locale, 'donor'),
            subtitle: t(locale, 'role_donor_desc'),
            onTap: () => _openAuthChoice(context, ref, UserRole.donor),
          ),
          const SizedBox(height: 12),
          _RoleCard(
            icon: Icons.apartment_outlined,
            title: t(locale, 'org_rep'),
            subtitle: t(locale, 'role_org_desc'),
            onTap: () => _openAuthChoice(context, ref, UserRole.orgRep),
          ),
        ],
      ),
    );
  }

  void _openAuthChoice(
    BuildContext context,
    WidgetRef ref,
    UserRole role,
  ) {
    ref.read(selectedRoleProvider.notifier).state = role;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final locale = ref.read(appLocaleProvider);
        final t = AppLocalizations.tr;
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t(locale, 'get_started'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: t(locale, 'sign_in'),
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/login');
                },
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/signup');
                },
                child: Text(t(locale, 'sign_up')),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF0F1E3F).withOpacity(0.1),
          child: Icon(icon, color: const Color(0xFF0F1E3F)),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

