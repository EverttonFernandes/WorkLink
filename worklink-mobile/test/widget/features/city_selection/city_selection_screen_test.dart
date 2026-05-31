import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/city_selection/city_selection_city.dart';
import 'package:worklink_mobile/features/city_selection/city_selection_controller.dart';
import 'package:worklink_mobile/features/city_selection/city_selection_screen.dart';

void main() {
  const charqueadasCity = CitySelectionCity(
    cityIdentifier: 'charqueadas-rs',
    cityName: 'Charqueadas',
    stateCode: 'RS',
  );
  const saoJeronimoCity = CitySelectionCity(
    cityIdentifier: 'sao-jeronimo-rs',
    cityName: 'São Jerônimo',
    stateCode: 'RS',
  );
  const triunfoCity = CitySelectionCity(
    cityIdentifier: 'triunfo-rs',
    cityName: 'Triunfo',
    stateCode: 'RS',
  );
  const arroioDosRatosCity = CitySelectionCity(
    cityIdentifier: 'arroio-dos-ratos-rs',
    cityName: 'Arroio dos Ratos',
    stateCode: 'RS',
  );
  const eldoradoDoSulCity = CitySelectionCity(
    cityIdentifier: 'eldorado-do-sul-rs',
    cityName: 'Eldorado do Sul',
    stateCode: 'RS',
  );
  const generalCamaraCity = CitySelectionCity(
    cityIdentifier: 'general-camara-rs',
    cityName: 'General Câmara',
    stateCode: 'RS',
  );
  const butiaCity = CitySelectionCity(
    cityIdentifier: 'butia-rs',
    cityName: 'Butiá',
    stateCode: 'RS',
  );

  CitySelectionController createCitySelectionController() {
    return CitySelectionController(
      availableCities: const [
        charqueadasCity,
        saoJeronimoCity,
        triunfoCity,
        arroioDosRatosCity,
        eldoradoDoSulCity,
        generalCamaraCity,
        butiaCity,
      ],
      nearbySuggestedCities: const [saoJeronimoCity, triunfoCity],
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
        theme: ThemeData(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
        ),
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
    expect(find.text('Charqueadas - RS'), findsOneWidget);
    expect(find.text('São Jerônimo - RS'), findsOneWidget);
    expect(find.text('Triunfo - RS'), findsOneWidget);
    expect(find.text('Arroio dos Ratos - RS'), findsOneWidget);
    expect(find.text('Eldorado do Sul - RS'), findsOneWidget);
    expect(find.text('General Câmara - RS'), findsOneWidget);
    expect(find.text('Butiá - RS'), findsOneWidget);
  });

  testWidgets(
      'GIVEN cidade disponivel WHEN tocar na cidade THEN deve selecionar cidade',
      (widgetTester) async {
    // GIVEN
    final citySelectionController = createCitySelectionController();
    await pumpCitySelectionScreen(widgetTester, citySelectionController);

    // WHEN
    await widgetTester.tap(find.text('Charqueadas - RS'));
    await widgetTester.pump();

    // THEN
    expect(
      citySelectionController.state.selectedCityIdentifiers,
      contains(charqueadasCity.cityIdentifier),
    );
  });

  testWidgets(
      'GIVEN selecao ativa WHEN limpar selecao THEN deve limpar estado da tela',
      (widgetTester) async {
    // GIVEN
    final citySelectionController = createCitySelectionController();
    await pumpCitySelectionScreen(widgetTester, citySelectionController);
    await widgetTester.tap(find.text('Charqueadas - RS'));
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
    expect(
      find.text('Cidades proximas a sua localizacao atual'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.place_outlined), findsWidgets);
  });
}
