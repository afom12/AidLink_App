import 'enums.dart';

class AidOffer {
  AidOffer({
    required this.id,
    required this.requestId,
    required this.donorId,
    required this.type,
    required this.status,
    required this.createdAt,
    this.availabilityTime,
    this.note,
  });

  final String id;
  final String requestId;
  final String donorId;
  final AidType type;
  final OfferStatus status;
  final DateTime createdAt;
  final DateTime? availabilityTime;
  final String? note;

  factory AidOffer.fromJson(Map<String, dynamic> json) {
    return AidOffer(
      id: json['id']?.toString() ?? '',
      requestId: json['requestId']?.toString() ?? '',
      donorId: json['donorId']?.toString() ?? '',
      type: enumFromApiString(
        AidType.values,
        json['type']?.toString(),
        AidType.other,
      ),
      status: enumFromApiString(
        OfferStatus.values,
        json['status']?.toString(),
        OfferStatus.offered,
      ),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      availabilityTime:
          DateTime.tryParse(json['availabilityTime']?.toString() ?? ''),
      note: json['note']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requestId': requestId,
      'donorId': donorId,
      'type': enumToApiString(type),
      'status': enumToApiString(status),
      'createdAt': createdAt.toIso8601String(),
      'availabilityTime': availabilityTime?.toIso8601String(),
      'note': note,
    };
  }
}




