import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/services/customer_service.dart';

import 'fake_worklink_http_client.dart';

void main() {
  late FakeWorkLinkHttpClient httpClient;
  late CustomerService customerService;

  setUp(() {
    httpClient = FakeWorkLinkHttpClient();
    customerService = CustomerService(httpClient: httpClient);
  });

  test(
      'GIVEN backend profile WHEN carregar perfil do cliente THEN deve mapear resposta agregada',
      () async {
    // GIVEN
    httpClient.objectResponses['/api/v1/customers/me/profile'] =
        customerProfileJson();

    // WHEN
    final customerProfile = await customerService.loadCustomerProfile();

    // THEN
    expect(customerProfile.customerName, 'Cliente Exemplo');
    expect(customerProfile.savedProfessionals.single.professionalName, 'Maria');
    expect(customerProfile.submittedReviews.single.publiclyAnonymous, isTrue);
  });

  test(
      'GIVEN alteracao de preferencias e favoritos WHEN chamar servico THEN deve usar contratos privados corretos',
      () async {
    // GIVEN
    httpClient.objectResponses['/api/v1/customers/me/profile/preferences'] =
        customerProfileJson(whatsappNotificationsEnabled: false);
    httpClient.objectResponses[
            '/api/v1/customers/me/saved-professionals/professional-1'] =
        customerProfileJson();

    // WHEN
    final updatedPreferences =
        await customerService.updateCustomerProfilePreferences(
      whatsappNotificationsEnabled: false,
      profilePersonalizationEnabled: true,
    );
    await customerService.saveProfessional('professional-1');
    await customerService.removeSavedProfessional('professional-1');

    // THEN
    expect(updatedPreferences.whatsappNotificationsEnabled, isFalse);
    expect(
      httpClient.requests[0].path,
      '/api/v1/customers/me/profile/preferences',
    );
    expect(
      httpClient.requests[1].path,
      '/api/v1/customers/me/saved-professionals/professional-1',
    );
    expect(httpClient.requests[2].method, 'DELETE');
  });
}

Map<String, dynamic> customerProfileJson({
  bool whatsappNotificationsEnabled = true,
}) {
  return {
    'customerIdentifier': 'customer-1',
    'customerName': 'Cliente Exemplo',
    'phoneNumber': '51999991234',
    'mainCity': {
      'cityIdentifier': 'city-1',
      'cityName': 'Canoas',
      'stateCode': 'RS',
    },
    'selectedCities': [
      {
        'cityIdentifier': 'city-1',
        'cityName': 'Canoas',
        'stateCode': 'RS',
      },
    ],
    'savedProfessionals': [
      {
        'professionalIdentifier': 'professional-1',
        'professionalName': 'Maria',
        'categoryName': 'Eletricista',
        'city': {
          'cityIdentifier': 'city-1',
          'cityName': 'Canoas',
          'stateCode': 'RS',
        },
      },
    ],
    'submittedReviews': [
      {
        'professionalReviewIdentifier': 'review-1',
        'professionalIdentifier': 'professional-1',
        'professionalName': 'Maria',
        'starRating': 5,
        'publiclyAnonymous': true,
        'comment': 'Excelente atendimento.',
      },
    ],
    'whatsappNotificationsEnabled': whatsappNotificationsEnabled,
    'profilePersonalizationEnabled': true,
  };
}
