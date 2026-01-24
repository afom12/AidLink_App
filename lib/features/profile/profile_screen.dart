import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/enums.dart';
import '../../core/models/user_profile.dart';
import '../../core/services/service_providers.dart';
import '../../shared/utils/app_localizations.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/request_card.dart';
import '../../shared/widgets/status_timeline.dart';
import '../requests/request_detail_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key, required this.role});

  final String role;

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final authState = ref.read(authControllerProvider);
    final role = authState.user?.role ?? _roleFromRoute(widget.role);
    if (role == UserRole.donor) {
      ref.read(requestsControllerProvider.notifier).loadForDonor();
    } else if (role == UserRole.seeker) {
      ref.read(requestsControllerProvider.notifier).loadForSeeker();
    }
  }

  UserRole _roleFromRoute(String role) {
    switch (role) {
      case 'donor':
        return UserRole.donor;
      case 'admin':
        return UserRole.orgRep;
      default:
        return UserRole.seeker;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(appLocaleProvider);
    final t = AppLocalizations.tr;
    final authState = ref.watch(authControllerProvider);
    final userRole = authState.user?.role ?? _roleFromRoute(widget.role);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(t(locale, 'profile')),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go('/profile/${userRole.name}/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.go('/profile/${userRole.name}/edit'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProfileHeader(role: userRole, locale: locale, user: user),
          const SizedBox(height: 16),
          _ProfileInfo(locale: locale, user: user),
          const SizedBox(height: 16),
          if (userRole == UserRole.seeker) _SeekerProfile(locale: locale),
          if (userRole == UserRole.donor) _DonorProfile(locale: locale),
          if (userRole == UserRole.orgRep) _AdminProfile(locale: locale),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.role,
    required this.locale,
    required this.user,
  });

  final UserRole role;
  final Locale locale;
  final UserProfile? user;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.tr;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFF0F1E3F).withOpacity(0.1),
              child: const Icon(Icons.person, color: Color(0xFF0F1E3F)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (user?.name ?? '').trim().isNotEmpty
                        ? user!.name
                        : t(locale, 'unknown_user'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role == UserRole.seeker
                        ? t(locale, 'seeker')
                        : role == UserRole.donor
                            ? t(locale, 'donor')
                            : t(locale, 'org_rep'),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileInfo extends StatelessWidget {
  const _ProfileInfo({
    required this.locale,
    required this.user,
  });

  final Locale locale;
  final UserProfile? user;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.tr;
    final email = (user?.email ?? '').trim();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (email.isNotEmpty)
              _InfoRow(label: t(locale, 'email'), value: email),
            _InfoRow(
              label: t(locale, 'phone'),
              value: user?.phone ?? t(locale, 'not_available'),
            ),
            _InfoRow(
              label: t(locale, 'language'),
              value: locale.languageCode == 'am'
                  ? t(locale, 'language_amharic')
                  : t(locale, 'language_english'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value),
        ],
      ),
    );
  }
}

class _SeekerProfile extends ConsumerWidget {
  const _SeekerProfile({required this.locale});

  final Locale locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.tr;
    final requestsState = ref.watch(requestsControllerProvider);
    final recent = requestsState.items.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t(locale, 'my_requests'),
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (requestsState.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (recent.isEmpty)
          EmptyState(
            title: t(locale, 'no_received_aid_yet'),
            subtitle: t(locale, 'aid_arrives_here'),
          )
        else
          ...recent.map(
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
        const SizedBox(height: 16),
        Text(t(locale, 'status_timeline'),
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: StatusTimeline(
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
          ),
        ),
      ],
    );
  }
}

class _DonorProfile extends ConsumerWidget {
  const _DonorProfile({required this.locale});

  final Locale locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.tr;
    final requestsState = ref.watch(requestsControllerProvider);
    final recent = requestsState.items.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t(locale, 'urgent_aid'),
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (requestsState.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (recent.isEmpty)
          EmptyState(
            title: t(locale, 'no_requests'),
            subtitle: t(locale, 'urgent_food_help'),
          )
        else
          ...recent.map(
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
    );
  }
}

class _AdminProfile extends StatelessWidget {
  const _AdminProfile({required this.locale});

  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.tr;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t(locale, 'admin_tools'),
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        EmptyState(
          title: t(locale, 'admin_tools'),
          subtitle: t(locale, 'admin_tools_desc'),
        ),
      ],
    );
  }
}


