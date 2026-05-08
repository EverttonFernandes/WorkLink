import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/city_selection/city_selection_city.dart';
import 'package:worklink_mobile/features/city_selection/city_selection_controller.dart';

void main() {
  const canoasCity = CitySelectionCity(
    cityIdentifier: 'canoas-rs',
    cityName: 'Canoas',
    stateCode: 'RS',
  );
  const portoAlegreCity = CitySelectionCity(
    cityIdentifier: 'porto-alegre-rs',
    cityName: 'Porto Alegre',
    stateCode: 'RS',
  );

  CitySelectionController createCitySelectionController() {
    return CitySelectionController(
      availableCities: const [canoasCity, portoAlegreCity],
      nearbySuggestedCities: const [portoAlegreCity],
    );
  }

  test(
      'GIVEN cidade disponivel WHEN selecionar cidade THEN deve manter cidade selecionada',
      () {
    // GIVEN
    final citySelectionController = createCitySelectionController();

    // WHEN
    citySelectionController.toggleCitySelection(canoasCity);

    // THEN
    expect(
      citySelectionController.state.selectedCityIdentifiers,
      contains(canoasCity.cityIdentifier),
    );
  });

  test(
      'GIVEN cidade selecionada WHEN tocar novamente THEN deve remover cidade selecionada',
      () {
    // GIVEN
    final citySelectionController = createCitySelectionController();
    citySelectionController.toggleCitySelection(canoasCity);

    // WHEN
    citySelectionController.toggleCitySelection(canoasCity);

    // THEN
    expect(
      citySelectionController.state.selectedCityIdentifiers,
      isNot(contains(canoasCity.cityIdentifier)),
    );
  });

  test(
      'GIVEN duas cidades disponiveis WHEN selecionar ambas THEN deve manter selecao multipla',
      () {
    // GIVEN
    final citySelectionController = createCitySelectionController();

    // WHEN
    citySelectionController.toggleCitySelection(canoasCity);
    citySelectionController.toggleCitySelection(portoAlegreCity);

    // THEN
    expect(
      citySelectionController.state.selectedCityIdentifiers,
      contains(canoasCity.cityIdentifier),
    );
    expect(
      citySelectionController.state.selectedCityIdentifiers,
      contains(portoAlegreCity.cityIdentifier),
    );
  });

  test(
      'GIVEN selecao e localizacao ativa WHEN limpar selecao THEN deve limpar cidades e localizacao',
      () {
    // GIVEN
    final citySelectionController = createCitySelectionController();
    citySelectionController.toggleCitySelection(canoasCity);
    citySelectionController.toggleCurrentLocationUsage(true);

    // WHEN
    citySelectionController.clearCitySelection();

    // THEN
    expect(citySelectionController.state.selectedCityIdentifiers, isEmpty);
    expect(citySelectionController.state.currentLocationEnabled, isFalse);
  });

  test(
      'GIVEN localizacao opcional WHEN ativar localizacao THEN deve habilitar sugestoes proximas',
      () {
    // GIVEN
    final citySelectionController = createCitySelectionController();

    // WHEN
    citySelectionController.toggleCurrentLocationUsage(true);

    // THEN
    expect(citySelectionController.state.currentLocationEnabled, isTrue);
    expect(
      citySelectionController.state.nearbySuggestedCities,
      contains(portoAlegreCity),
    );
  });
}
