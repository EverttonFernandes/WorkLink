import 'api_client.dart';
import 'models/review_model.dart';

class ReviewService {
  const ReviewService({required WorkLinkHttpClient httpClient})
      : _httpClient = httpClient;

  final WorkLinkHttpClient _httpClient;

  Future<ProfessionalReviewProfile> listProfessionalReviewProfile(
    String professionalIdentifier,
  ) async {
    final response = await _httpClient.getObject(
      '/api/v1/professional-reviews/professionals/$professionalIdentifier',
    );
    return ProfessionalReviewProfile.fromJson(response);
  }

  Future<ProfessionalReview> registerProfessionalReview(
    RegisterProfessionalReviewRequest request,
  ) async {
    final response = await _httpClient.postObject(
      '/api/v1/professional-reviews',
      data: request.toJson(),
    );
    return ProfessionalReview.fromJson(response);
  }

  Future<ReviewAnalysisRequest> requestProfessionalReviewAnalysis({
    required String professionalReviewIdentifier,
    required String reason,
  }) async {
    final response = await _httpClient.postObject(
      '/api/v1/professional-reviews/$professionalReviewIdentifier/'
      'analysis-requests',
      data: {'reason': reason},
    );
    return ReviewAnalysisRequest.fromJson(response);
  }
}
