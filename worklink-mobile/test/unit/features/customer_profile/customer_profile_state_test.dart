import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/customer_profile/customer_profile_state.dart';

void main() {
  test(
      'GIVEN perfil sem cidade principal WHEN consultar exibicao THEN deve retornar fallback legivel',
      () {
    // GIVEN
    const customerProfileState = CustomerProfileState(
      customerName: 'Cliente Exemplo',
      phoneNumber: '(51) 9 9999-1234',
    );

    // WHEN / THEN
    expect(
      customerProfileState.mainCityDisplayName,
      'Cidade principal pendente',
    );
    expect(customerProfileState.hasSelectedCities, isFalse);
    expect(customerProfileState.hasSavedProfessionals, isFalse);
    expect(customerProfileState.hasSubmittedReviews, isFalse);
  });

  test(
      'GIVEN perfil existente WHEN copiar listas e cidade principal THEN deve substituir apenas campos informados',
      () {
    // GIVEN
    const originalState = CustomerProfileState(
      customerName: 'Cliente Exemplo',
      phoneNumber: '(51) 9 9999-1234',
      mainCity: CustomerProfileCity(cityName: 'Canoas', stateCode: 'RS'),
      selectedCities: [
        CustomerProfileCity(cityName: 'Canoas', stateCode: 'RS'),
      ],
    );

    // WHEN
    final copiedState = originalState.copyWith(
      mainCity: const CustomerProfileCity(
        cityName: 'Porto Alegre',
        stateCode: 'RS',
      ),
      selectedCities: const [
        CustomerProfileCity(cityName: 'Porto Alegre', stateCode: 'RS'),
      ],
      savedProfessionals: const [
        CustomerSavedProfessional(
          professionalIdentifier: 'professional-1',
          professionalName: 'Maria',
          categoryName: 'Eletricista',
          cityDisplayName: 'Porto Alegre - RS',
        ),
      ],
    );

    // THEN
    expect(copiedState.mainCityDisplayName, 'Porto Alegre - RS');
    expect(copiedState.selectedCities.single.displayName, 'Porto Alegre - RS');
    expect(copiedState.savedProfessionals.single.professionalName, 'Maria');
    expect(copiedState.phoneNumber, '(51) 9 9999-1234');
  });
}
