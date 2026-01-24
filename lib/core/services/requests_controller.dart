import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/aid_offer.dart';
import '../models/aid_request.dart';
import '../models/enums.dart';
import 'aid_request_service.dart';

class RequestsState {
  const RequestsState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  final List<AidRequest> items;
  final bool isLoading;
  final String? error;

  RequestsState copyWith({
    List<AidRequest>? items,
    bool? isLoading,
    String? error,
  }) {
    return RequestsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class RequestsController extends StateNotifier<RequestsState> {
  RequestsController(this._service) : super(const RequestsState());

  final AidRequestService _service;

  Future<void> loadForDonor({AidType? filter}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final requests =
          await _service.fetchRequests(type: filter, urgentFirst: true);
      state = state.copyWith(items: requests, isLoading: false);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: '$error');
    }
  }

  Future<void> loadForSeeker() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final requests = await _service.fetchMyRequests();
      state = state.copyWith(items: requests, isLoading: false);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: '$error');
    }
  }

  Future<AidRequest?> createRequest(AidRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final created = await _service.createRequest(request);
      state = state.copyWith(
        items: [created, ...state.items],
        isLoading: false,
      );
      return created;
    } catch (error) {
      state = state.copyWith(isLoading: false, error: '$error');
      return null;
    }
  }

  Future<void> confirmReceipt(String requestId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updated =
          await _service.updateStatus(requestId, RequestStatus.completed);
      state = state.copyWith(
        items: state.items
            .map((item) => item.id == requestId ? updated : item)
            .toList(),
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, error: '$error');
    }
  }

  Future<AidOffer?> offerAid({
    required String requestId,
    required AidType type,
    DateTime? availabilityTime,
    String? note,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final offer = await _service.createOffer(
        requestId: requestId,
        type: type,
        availabilityTime: availabilityTime,
        note: note,
      );
      state = state.copyWith(isLoading: false);
      return offer;
    } catch (error) {
      state = state.copyWith(isLoading: false, error: '$error');
      return null;
    }
  }
}




