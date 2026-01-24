import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import 'aid_request_service.dart';
import 'api_client.dart';
import 'auth_controller.dart';
import 'auth_service.dart';
import 'feedback_service.dart';
import 'notification_service.dart';
import 'notifications_controller.dart';
import 'requests_controller.dart';
import 'secure_preferences.dart';
import 'token_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(ref.read(tokenStorageProvider)),
);

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(),
);

final securePreferencesProvider =
    Provider<SecurePreferences>((ref) => SecurePreferences());

final aidRequestServiceProvider = Provider<AidRequestService>(
  (ref) => AidRequestService(ref.read(apiClientProvider)),
);

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(ref.read(apiClientProvider)),
);

final feedbackServiceProvider = Provider<FeedbackService>(
  (ref) => FeedbackService(ref.read(apiClientProvider)),
);

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(
    ref.read(authServiceProvider),
    ref.read(tokenStorageProvider),
    ref.read(notificationServiceProvider),
    ref.read(securePreferencesProvider),
    LocalAuthentication(),
  ),
);

final requestsControllerProvider =
    StateNotifierProvider<RequestsController, RequestsState>(
  (ref) => RequestsController(ref.read(aidRequestServiceProvider)),
);

final notificationsControllerProvider =
    StateNotifierProvider<NotificationsController, NotificationsState>(
  (ref) => NotificationsController(ref.read(notificationServiceProvider)),
);



