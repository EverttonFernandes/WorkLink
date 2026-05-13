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
}
