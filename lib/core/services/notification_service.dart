import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../firebase_options.dart';
import '../models/app_notification.dart';
import 'api_client.dart';

class NotificationService {
  NotificationService(this._client);

  final ApiClient _client;
  FirebaseMessaging? _messaging;

  Future<void> initialize() async {
    _messaging ??= FirebaseMessaging.instance;
    await _messaging!.requestPermission();
    FirebaseMessaging.onMessage.listen((message) {
      // Foreground handling can be customized by screens via listeners.
    });
  }

  Future<void> registerDeviceToken(String userId) async {
    _messaging ??= FirebaseMessaging.instance;
    final token = await _messaging!.getToken();
    if (token == null || token.isEmpty) {
      return;
    }
    await _client.dio.post(
      '/notifications/register',
      data: {'userId': userId, 'token': token},
    );
  }

  Future<List<AppNotification>> fetchNotifications() async {
    final response = await _client.dio.get('/notifications');
    final raw = (response.data as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    return raw.map(AppNotification.fromJson).toList();
  }

  Future<void> markAsRead(String notificationId) async {
    await _client.dio.post('/notifications/$notificationId/read');
  }

  Future<void> markAllRead() async {
    await _client.dio.post('/notifications/read-all');
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

