import '../models/aid_offer.dart';
import '../models/aid_request.dart';
import '../models/enums.dart';
import 'api_client.dart';

class AidRequestService {
  AidRequestService(this._client);

  final ApiClient _client;

  Future<List<AidRequest>> fetchRequests({
    AidType? type,
    bool urgentFirst = false,
  }) async {
    final response = await _client.dio.get(
      '/requests',
      queryParameters: {
        if (type != null) 'type': enumToApiString(type),
      },
    );
    final raw = (response.data as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    final requests = raw.map(AidRequest.fromJson).toList();
    if (urgentFirst) {
      requests.sort((a, b) {
        final aUrgent = a.isUrgentFood ? 1 : 0;
        final bUrgent = b.isUrgentFood ? 1 : 0;
        if (aUrgent != bUrgent) {
          return bUrgent.compareTo(aUrgent);
        }
        return (a.deadline ?? DateTime.now())
            .compareTo(b.deadline ?? DateTime.now());
      });
    }
    return requests;
  }

  Future<List<AidRequest>> fetchMyRequests() async {
    final response = await _client.dio.get('/requests/mine');
    final raw = (response.data as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    return raw.map(AidRequest.fromJson).toList();
  }

  Future<AidRequest> createRequest(AidRequest request) async {
    final response = await _client.dio.post(
      '/requests',
      data: request.toJson(),
    );
    return AidRequest.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AidRequest> updateStatus(
    String requestId,
    RequestStatus status,
  ) async {
    final response = await _client.dio.patch(
      '/requests/$requestId/status',
      data: {'status': enumToApiString(status)},
    );
    return AidRequest.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AidOffer> createOffer({
    required String requestId,
    required AidType type,
    DateTime? availabilityTime,
    String? note,
  }) async {
    final response = await _client.dio.post(
      '/requests/$requestId/offers',
      data: {
        'type': enumToApiString(type),
        'availabilityTime': availabilityTime?.toIso8601String(),
        'note': note,
      },
    );
    return AidOffer.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<AidOffer>> fetchMyOffers() async {
    final response = await _client.dio.get('/offers/mine');
    final raw = (response.data as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    return raw.map(AidOffer.fromJson).toList();
  }
}




