import 'enums.dart';

class UserProfile {
  UserProfile({
    required this.id,
    required this.phone,
    required this.name,
    required this.role,
    required this.isVerified,
    this.email,
    this.locale,
    this.roleData,
  });

  final String id;
  final String phone;
  final String name;
  final UserRole role;
  final bool isVerified;
  final String? email;
  final String? locale;
  final Map<String, dynamic>? roleData;

  bool get needsProfileCompletion => name.trim().isEmpty;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      role: enumFromApiString(
        UserRole.values,
        json['role']?.toString(),
        UserRole.seeker,
      ),
      isVerified: json['isVerified'] == true,
      email: json['email']?.toString(),
      locale: json['locale']?.toString(),
      roleData: (json['roleData'] as Map?)?.cast<String, dynamic>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'name': name,
      'role': enumToApiString(role),
      'isVerified': isVerified,
      'email': email,
      'locale': locale,
      'roleData': roleData,
    };
  }
}




