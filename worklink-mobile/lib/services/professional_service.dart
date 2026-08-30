import 'api_client.dart';
import 'models/discovery_model.dart';
import 'models/professional_model.dart';

class ProfessionalService {
  const ProfessionalService({required WorkLinkHttpClient httpClient})
      : _httpClient = httpClient;

  final WorkLinkHttpClient _httpClient;

  Future<List<ProfessionalSummary>> listProfessionals({
    DiscoveryRequest request = const DiscoveryRequest(),
  }) async {
    final response = await _httpClient.getList(
      '/api/v1/professionals',
      queryParameters: request.toQueryParameters(),
    );
    return response
        .map(
          (json) => ProfessionalSummary.fromJson(
            Map<String, dynamic>.from(json as Map),
          ),
        )
        .toList();
  }

  Future<Professional> loadProfessionalDetail(
    String professionalIdentifier,
  ) async {
    final response = await _httpClient.getObject(
      '/api/v1/professionals/$professionalIdentifier',
    );
    return Professional.fromJson(response);
  }

  Future<void> recordAnonymousProfessionalDetailAttempt(
    String professionalIdentifier,
  ) async {
    await _httpClient.postEmpty(
      '/api/v1/professionals/$professionalIdentifier/detail-access-attempts',
    );
  }

  Future<Professional> registerBasicProfessional(
    RegisterBasicProfessionalRequest request,
  ) async {
    final response = await _httpClient.postObject(
      '/api/v1/professionals',
      data: request.toJson(),
    );
    return Professional.fromJson(response);
  }

  Future<Professional> completeProfessionalProfile({
    required String professionalIdentifier,
    required CompleteProfessionalProfileRequest request,
  }) async {
    final response = await _httpClient.patchObject(
      '/api/v1/professionals/$professionalIdentifier/profile',
      data: request.toJson(),
    );
    return Professional.fromJson(response);
  }

  Future<ProfessionalPhoneVerificationRequestResult>
      requestProfessionalPhoneVerification(
    String professionalIdentifier,
  ) async {
    final response = await _httpClient.postObject(
      '/api/v1/professionals/$professionalIdentifier/phone-verification/request',
    );
    return ProfessionalPhoneVerificationRequestResult.fromJson(response);
  }

  Future<Professional> confirmProfessionalPhoneVerification({
    required String professionalIdentifier,
    required String verificationCode,
  }) async {
    final response = await _httpClient.postObject(
      '/api/v1/professionals/$professionalIdentifier/phone-verification/confirm',
      data: ConfirmProfessionalPhoneVerificationRequest(
        verificationCode: verificationCode,
      ).toJson(),
    );
    return Professional.fromJson(response);
  }

  Future<List<ProfessionalPortfolioItem>> listProfessionalPortfolioItems(
    String professionalIdentifier,
  ) async {
    final response = await _httpClient.getList(
      '/api/v1/professionals/$professionalIdentifier/portfolio-items',
    );
    return response
        .map(
          (json) => ProfessionalPortfolioItem.fromJson(
            Map<String, dynamic>.from(json as Map),
          ),
        )
        .toList();
  }

  Future<ProfessionalPortfolioItem> addProfessionalPortfolioItem({
    required String professionalIdentifier,
    required AddProfessionalPortfolioItemRequest request,
  }) async {
    final response = await _httpClient.postObject(
      '/api/v1/professionals/$professionalIdentifier/portfolio-items',
      data: request.toJson(),
    );
    return ProfessionalPortfolioItem.fromJson(response);
  }
}
