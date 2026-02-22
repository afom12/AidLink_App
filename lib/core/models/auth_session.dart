import 'user_profile.dart';
class AuthSession {
  AuthSession({
    required this.accessToken,
    required this.user,
  });

  final String accessToken;
  final UserProfile user;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: json['accessToken']?.toString() ?? '',
      user: UserProfile.fromJson(json['user'] ?? const {}),
    );
  }
}




