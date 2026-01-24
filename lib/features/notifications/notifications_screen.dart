import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/service_providers.dart';
import '../../shared/utils/app_localizations.dart';
import '../../shared/utils/formatters.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(notificationsControllerProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(appLocaleProvider);
    final t = AppLocalizations.tr;
    final notificationsState = ref.watch(notificationsControllerProvider);
    final unreadCount =
        notificationsState.items.where((item) => !item.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(t(locale, 'notifications_tab')),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () => ref
                  .read(notificationsControllerProvider.notifier)
                  .markAllRead(),
              child: Text(t(locale, 'mark_all_read')),
            ),
        ],
      ),
      body: notificationsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notificationsState.error != null
              ? Center(child: Text(t(locale, 'auth_error')))
              : notificationsState.items.isEmpty
                  ? Center(child: Text(t(locale, 'no_notifications')))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: notificationsState.items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = notificationsState.items[index];
                        return Card(
                          child: ListTile(
                            leading: _NotificationLeading(isRead: item.isRead),
                            title: Text(item.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(item.body),
                                const SizedBox(height: 6),
                                Text(
                                  Formatters.formatDateTime(item.createdAt),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            trailing: item.isRead
                                ? null
                                : Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F1E3F)
                                          .withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      t(locale, 'notification_new'),
                                      style: const TextStyle(
                                        color: Color(0xFF0F1E3F),
                                      ),
                                    ),
                                  ),
                            onTap: () {
                              if (!item.isRead) {
                                ref
                                    .read(notificationsControllerProvider.notifier)
                                    .markAsRead(item.id);
                              }
                              final link = item.deepLink;
                              if (link != null && link.startsWith('/')) {
                                context.go(link);
                              }
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}

class _NotificationLeading extends StatelessWidget {
  const _NotificationLeading({required this.isRead});

  final bool isRead;

  @override
  Widget build(BuildContext context) {
    final color =
        isRead ? Colors.grey : Theme.of(context).colorScheme.primary;
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          isRead ? Icons.notifications_none : Icons.notifications_active,
          color: color,
        ),
        if (!isRead)
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              height: 8,
              width: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

