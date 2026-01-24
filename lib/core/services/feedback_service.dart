import 'api_client.dart';

class FeedbackService {
  FeedbackService(this._client);

  final ApiClient _client;

  Future<void> submitFeedback({
    required String message,
    required int rating,
    required String category,
    String? userId,
    String? email,
  }) async {
    await _client.dio.post(
      '/feedback',
      data: {
        'message': message,
        'rating': rating,
        'category': category,
        if (userId != null) 'userId': userId,
        if (email != null) 'email': email,
      },
    );
  }
}


