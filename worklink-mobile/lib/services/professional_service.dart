import 'api_client.dart';
import 'models/discovery_model.dart';
import 'models/professional_model.dart';

class ProfessionalService {
  const ProfessionalService({required WorkLinkHttpClient httpClient})
      : _httpClient = httpClient;

  final WorkLinkHttpClient _httpClient;

  Future<List<Professional>> listProfessionals({
    DiscoveryRequest request = const DiscoveryRequest(),
  }) async {
    final response = await _httpClient.getList(
      '/api/v1/professionals',
      queryParameters: request.toQueryParameters(),
    );
    return response
        .map(
          (json) =>
              Professional.fromJson(Map<String, dynamic>.from(json as Map)),
        )
        .toList();
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
}
