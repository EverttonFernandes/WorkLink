import 'api_client.dart';
import 'models/customer_model.dart';

class CustomerService {
  const CustomerService({required WorkLinkHttpClient httpClient})
      : _httpClient = httpClient;

  final WorkLinkHttpClient _httpClient;

  Future<CustomerProfileModel> loadCustomerProfile() async {
    final response = await _httpClient.getObject('/api/v1/customers/me/profile');
    return CustomerProfileModel.fromJson(response);
  }

  Future<CustomerProfileModel> updateCustomerProfilePreferences({
    required bool whatsappNotificationsEnabled,
    required bool profilePersonalizationEnabled,
  }) async {
    final response = await _httpClient.patchObject(
      '/api/v1/customers/me/profile/preferences',
      data: {
        'whatsappNotificationsEnabled': whatsappNotificationsEnabled,
        'profilePersonalizationEnabled': profilePersonalizationEnabled,
      },
    );
    return CustomerProfileModel.fromJson(response);
  }

  Future<CustomerProfileModel> saveProfessional(String professionalIdentifier) async {
    final response = await _httpClient.postObject(
      '/api/v1/customers/me/saved-professionals/$professionalIdentifier',
    );
    return CustomerProfileModel.fromJson(response);
  }

  Future<CustomerProfileModel> removeSavedProfessional(
    String professionalIdentifier,
  ) async {
    final response = await _httpClient.deleteObject(
      '/api/v1/customers/me/saved-professionals/$professionalIdentifier',
    );
    return CustomerProfileModel.fromJson(response);
  }
}
