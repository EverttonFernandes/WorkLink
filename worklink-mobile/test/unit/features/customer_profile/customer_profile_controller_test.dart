import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/customer_profile/customer_profile_controller.dart';
import 'package:worklink_mobile/features/customer_profile/customer_profile_state.dart';

void main() {
  test(
      'GIVEN perfil cliente WHEN alterar preferencias THEN deve atualizar estado',
      () async {
    // GIVEN
    final customerProfileController = CustomerProfileController(
      initialState: customerProfileStateFixture(),
    );

    // WHEN
    await customerProfileController.changeWhatsappNotifications(false);
    await customerProfileController.changeProfilePersonalization(false);

    // THEN
    expect(
      customerProfileController.state.whatsappNotificationsEnabled,
      isFalse,
    );
    expect(
      customerProfileController.state.profilePersonalizationEnabled,
      isFalse,
    );
  });

  test('GIVEN perfil cliente WHEN sair da conta THEN deve marcar logout', () {
    // GIVEN
    final customerProfileController = CustomerProfileController(
      initialState: customerProfileStateFixture(),
    );

    // WHEN
    customerProfileController.logout();

    // THEN
    expect(customerProfileController.state.loggedOut, isTrue);
  });

  test(
      'GIVEN dados do perfil WHEN consultar derivados THEN deve expor resumo minimo',
      () {
    // GIVEN
    final customerProfileState = customerProfileStateFixture();

    // WHEN / THEN
    expect(customerProfileState.mainCityDisplayName, 'Canoas - RS');
    expect(customerProfileState.hasSelectedCities, isTrue);
    expect(customerProfileState.hasSavedProfessionals, isTrue);
    expect(customerProfileState.hasSubmittedReviews, isTrue);
    expect(
      customerProfileState.submittedReviews.single.publicVisibilityLabel,
      'Anonima publicamente',
    );
  });

  test(
      'GIVEN callback de persistencia WHEN alterar preferencias THEN deve sincronizar estado devolvido pelo backend',
      () async {
    // GIVEN
    final customerProfileController = CustomerProfileController(
      initialState: customerProfileStateFixture(),
      onPreferencesChanged: ({
        required bool whatsappNotificationsEnabled,
        required bool profilePersonalizationEnabled,
      }) async {
        return customerProfileStateFixture().copyWith(
          whatsappNotificationsEnabled: whatsappNotificationsEnabled,
          profilePersonalizationEnabled: profilePersonalizationEnabled,
          savedProfessionals: const [],
        );
      },
    );

    // WHEN
    await customerProfileController.changeWhatsappNotifications(false);

    // THEN
    expect(
      customerProfileController.state.whatsappNotificationsEnabled,
      isFalse,
    );
    expect(customerProfileController.state.savedProfessionals, isEmpty);
  });
}

CustomerProfileState customerProfileStateFixture() {
  return const CustomerProfileState(
    customerName: 'Cliente Exemplo',
    phoneNumber: '(51) 9 9999-1234',
    mainCity: CustomerProfileCity(cityName: 'Canoas', stateCode: 'RS'),
    selectedCities: [
      CustomerProfileCity(cityName: 'Canoas', stateCode: 'RS'),
      CustomerProfileCity(cityName: 'Porto Alegre', stateCode: 'RS'),
    ],
    savedProfessionals: [
      CustomerSavedProfessional(
        professionalIdentifier: 'maria-eletricista',
        professionalName: 'Maria Eletricista',
        categoryName: 'Eletricista',
        cityDisplayName: 'Canoas - RS',
      ),
    ],
    submittedReviews: [
      CustomerSubmittedReview(
        professionalName: 'Maria Eletricista',
        starRating: 5,
        publiclyAnonymous: true,
      ),
    ],
  );
}
