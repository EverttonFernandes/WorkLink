import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/city_selection/city_selection_city.dart';
import 'package:worklink_mobile/features/city_selection/city_selection_controller.dart';
import 'package:worklink_mobile/features/city_selection/city_selection_screen.dart';

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

  Future<void> pumpCitySelectionScreen(
    WidgetTester widgetTester,
    CitySelectionController citySelectionController,
  ) async {
    await widgetTester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => widgetTester.binding.setSurfaceSize(null));
    await widgetTester.pumpWidget(
      MaterialApp(
        home: CitySelectionScreen(
          citySelectionController: citySelectionController,
        ),
      ),
    );
  }

  testWidgets(
      'GIVEN tela de cidades WHEN renderizar THEN deve exibir cidades disponiveis',
      (widgetTester) async {
    // GIVEN
    final citySelectionController = createCitySelectionController();

    // WHEN
    await pumpCitySelectionScreen(widgetTester, citySelectionController);

    // THEN
    expect(find.text('Selecionar cidades'), findsOneWidget);
    expect(find.text('Usando minha localizacao atual'), findsOneWidget);
    expect(find.text('Canoas - RS'), findsOneWidget);
    expect(find.text('Porto Alegre - RS'), findsOneWidget);
  });

  testWidgets(
      'GIVEN cidade disponivel WHEN tocar na cidade THEN deve selecionar cidade',
      (widgetTester) async {
    // GIVEN
    final citySelectionController = createCitySelectionController();
    await pumpCitySelectionScreen(widgetTester, citySelectionController);

    // WHEN
    await widgetTester.tap(find.text('Canoas - RS'));
    await widgetTester.pump();

    // THEN
    expect(
      citySelectionController.state.selectedCityIdentifiers,
      contains(canoasCity.cityIdentifier),
    );
  });

  testWidgets(
      'GIVEN selecao ativa WHEN limpar selecao THEN deve limpar estado da tela',
      (widgetTester) async {
    // GIVEN
    final citySelectionController = createCitySelectionController();
    await pumpCitySelectionScreen(widgetTester, citySelectionController);
    await widgetTester.tap(find.text('Canoas - RS'));
    await widgetTester.pump();

    // WHEN
    await widgetTester.tap(find.byTooltip('Limpar cidades'));
    await widgetTester.pump();

    // THEN
    expect(citySelectionController.state.selectedCityIdentifiers, isEmpty);
  });

  testWidgets(
      'GIVEN localizacao inativa WHEN ativar localizacao THEN deve exibir cidades proximas',
      (widgetTester) async {
    // GIVEN
    final citySelectionController = createCitySelectionController();
    await pumpCitySelectionScreen(widgetTester, citySelectionController);

    // WHEN
    await widgetTester.tap(find.byType(Switch));
    await widgetTester.pump();

    // THEN
    expect(citySelectionController.state.currentLocationEnabled, isTrue);
    expect(find.text('Cidades proximas a sua localizacao atual'), findsOneWidget);
    expect(find.byIcon(Icons.place_outlined), findsOneWidget);
  });
}
