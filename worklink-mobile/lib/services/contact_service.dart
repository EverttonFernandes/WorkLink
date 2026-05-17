import 'api_client.dart';
import 'models/contact_model.dart';

class ContactService {
  const ContactService({required WorkLinkHttpClient httpClient})
      : _httpClient = httpClient;

  final WorkLinkHttpClient _httpClient;

  Future<ContactIntention> startProfessionalContact(
    String professionalIdentifier,
  ) async {
    final response = await _httpClient.postObject(
      '/api/v1/contact-intentions',
      data: {'professionalIdentifier': professionalIdentifier},
    );
    return ContactIntention.fromJson(response);
  }

  Future<PostContactFeedback> registerPostContactFeedback(
    RegisterPostContactFeedbackRequest request,
  ) async {
    final response = await _httpClient.postObject(
      '/api/v1/post-contact-feedbacks',
      data: request.toJson(),
    );
    return PostContactFeedback.fromJson(response);
  }

  Future<List<PendingPostContactFeedbackRequestModel>>
      listPendingPostContactFeedbackRequests() async {
    final response = await _httpClient.getList(
      '/api/v1/customers/me/post-contact-feedback-requests',
    );
    return response
        .map(
          (item) => PendingPostContactFeedbackRequestModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<void> dismissPostContactFeedbackRequest(
    String contactIntentIdentifier,
  ) async {
    await _httpClient.postEmpty(
      '/api/v1/customers/me/post-contact-feedback-requests/'
      '$contactIntentIdentifier/dismiss',
    );
  }
}
