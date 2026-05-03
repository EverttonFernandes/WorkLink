import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/city_selection/city_selection_city.dart';
import 'package:worklink_mobile/features/city_selection/city_selection_state.dart';

void main() {
  const canoasCity = CitySelectionCity(
    cityIdentifier: 'canoas-rs',
    cityName: 'Canoas',
    stateCode: 'RS',
  );
  const esteioCity = CitySelectionCity(
    cityIdentifier: 'esteio-rs',
    cityName: 'Esteio',
    stateCode: 'RS',
  );

  test('GIVEN cidade WHEN obter nome de exibicao THEN deve combinar cidade e UF', () {
    // GIVEN / WHEN
    final displayName = canoasCity.displayName;

    // THEN
    expect(displayName, 'Canoas - RS');
  });

  test('GIVEN estado com cidade selecionada WHEN consultar cidade THEN deve retornar selecao correta', () {
    // GIVEN
    const citySelectionState = CitySelectionState(
      availableCities: [canoasCity, esteioCity],
      selectedCityIdentifiers: {'canoas-rs'},
    );

    // WHEN / THEN
    expect(citySelectionState.isCitySelected(canoasCity), isTrue);
    expect(citySelectionState.isCitySelected(esteioCity), isFalse);
  });

  test('GIVEN estado existente WHEN copiar com novos campos THEN deve substituir apenas campos informados', () {
    // GIVEN
    const citySelectionState = CitySelectionState(
      availableCities: [canoasCity],
      selectedCityIdentifiers: {'canoas-rs'},
    );

    // WHEN
    final copiedCitySelectionState = citySelectionState.copyWith(
      availableCities: const [esteioCity],
      selectedCityIdentifiers: const {'esteio-rs'},
      currentLocationEnabled: true,
      nearbySuggestedCities: const [esteioCity],
    );

    // THEN
    expect(copiedCitySelectionState.availableCities, contains(esteioCity));
    expect(copiedCitySelectionState.selectedCityIdentifiers, contains('esteio-rs'));
    expect(copiedCitySelectionState.currentLocationEnabled, isTrue);
    expect(copiedCitySelectionState.nearbySuggestedCities, contains(esteioCity));
  });

  test('GIVEN estado existente WHEN copiar sem novos campos THEN deve preservar estado original', () {
    // GIVEN
    const citySelectionState = CitySelectionState(
      availableCities: [canoasCity],
      selectedCityIdentifiers: {'canoas-rs'},
      currentLocationEnabled: true,
      nearbySuggestedCities: [esteioCity],
    );

    // WHEN
    final copiedCitySelectionState = citySelectionState.copyWith();

    // THEN
    expect(copiedCitySelectionState.availableCities, citySelectionState.availableCities);
    expect(copiedCitySelectionState.selectedCityIdentifiers, citySelectionState.selectedCityIdentifiers);
    expect(copiedCitySelectionState.currentLocationEnabled, citySelectionState.currentLocationEnabled);
    expect(copiedCitySelectionState.nearbySuggestedCities, citySelectionState.nearbySuggestedCities);
  });
}
