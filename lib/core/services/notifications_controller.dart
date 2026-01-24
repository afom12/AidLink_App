import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_notification.dart';
import 'notification_service.dart';

class NotificationsState {
  const NotificationsState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  final List<AppNotification> items;
  final bool isLoading;
  final String? error;

  NotificationsState copyWith({
    List<AppNotification>? items,
    bool? isLoading,
    String? error,
  }) {
    return NotificationsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class NotificationsController extends StateNotifier<NotificationsState> {
  NotificationsController(this._service) : super(const NotificationsState());

  final NotificationService _service;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = await _service.fetchNotifications();
      state = state.copyWith(items: items, isLoading: false);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: '$error');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final items = state.items
        .map((item) => item.id == notificationId
            ? item.copyWith(isRead: true)
            : item)
        .toList();
    state = state.copyWith(items: items);
    try {
      await _service.markAsRead(notificationId);
    } catch (error) {
      state = state.copyWith(error: '$error');
    }
  }

  Future<void> markAllRead() async {
    final items = state.items.map((item) => item.copyWith(isRead: true)).toList();
    state = state.copyWith(items: items);
    try {
      await _service.markAllRead();
    } catch (error) {
      state = state.copyWith(error: '$error');
    }
  }
}

