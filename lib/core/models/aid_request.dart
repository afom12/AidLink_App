import 'enums.dart';

class AidRequest {
  AidRequest({
    required this.id,
    required this.seekerId,
    required this.type,
    required this.urgency,
    required this.quantity,
    required this.description,
    required this.status,
    required this.createdAt,
    this.deadline,
    this.expiryTime,
    this.isPerishable,
    this.distanceKm,
  });

  final String id;
  final String seekerId;
  final AidType type;
  final UrgencyLevel urgency;
  final String quantity;
  final String description;
  final RequestStatus status;
  final DateTime createdAt;
  final DateTime? deadline;
  final DateTime? expiryTime;
  final bool? isPerishable;
  final double? distanceKm;

  bool get isUrgentFood =>
      type == AidType.food && (isPerishable ?? false) && expiryTime != null;

  bool get isExpired {
    final comparison = expiryTime ?? deadline;
    if (comparison == null) {
      return false;
    }
    return comparison.isBefore(DateTime.now());
  }

  Duration? get timeRemaining {
    final comparison = expiryTime ?? deadline;
    if (comparison == null) {
      return null;
    }
    final diff = comparison.difference(DateTime.now());
    if (diff.isNegative) {
      return Duration.zero;
    }
    return diff;
  }

  factory AidRequest.fromJson(Map<String, dynamic> json) {
    return AidRequest(
      id: json['id']?.toString() ?? '',
      seekerId: json['seekerId']?.toString() ?? '',
      type: enumFromApiString(
        AidType.values,
        json['type']?.toString(),
        AidType.other,
      ),
      urgency: enumFromApiString(
        UrgencyLevel.values,
        json['urgency']?.toString(),
        UrgencyLevel.medium,
      ),
      quantity: json['quantity']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: enumFromApiString(
        RequestStatus.values,
        json['status']?.toString(),
        RequestStatus.submitted,
      ),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      deadline: DateTime.tryParse(json['deadline']?.toString() ?? ''),
      expiryTime: DateTime.tryParse(json['expiryTime']?.toString() ?? ''),
      isPerishable: json['isPerishable'] == true,
      distanceKm: (json['distanceKm'] is num)
          ? (json['distanceKm'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seekerId': seekerId,
      'type': enumToApiString(type),
      'urgency': enumToApiString(urgency),
      'quantity': quantity,
      'description': description,
      'status': enumToApiString(status),
      'createdAt': createdAt.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'expiryTime': expiryTime?.toIso8601String(),
      'isPerishable': isPerishable,
      'distanceKm': distanceKm,
    };
  }
}




