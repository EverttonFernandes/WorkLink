import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/discovery/discovery_controller.dart';
import 'package:worklink_mobile/features/discovery/discovery_professional.dart';
import 'package:worklink_mobile/features/discovery/discovery_screen.dart';

void main() {
  const electricianProfessional = DiscoveryProfessional(
    professionalIdentifier: 'maria-eletricista',
    professionalName: 'Maria Eletricista',
    categoryName: 'Eletricista',
    cityName: 'Canoas',
    stateCode: 'RS',
    shortDescription: 'Atendimento residencial.',
  );
  const painterProfessional = DiscoveryProfessional(
    professionalIdentifier: 'ana-pintora',
    professionalName: 'Ana Pintora',
    categoryName: 'Pintora',
    cityName: 'Porto Alegre',
    stateCode: 'RS',
    shortDescription: 'Pintura interna e acabamento.',
  );

  DiscoveryController createDiscoveryController() {
    return DiscoveryController(
      availableProfessionals: const [electricianProfessional, painterProfessional],
    );
  }

  Future<void> pumpDiscoveryScreen(
    WidgetTester widgetTester,
    DiscoveryController discoveryController,
  ) async {
    await widgetTester.pumpWidget(
      MaterialApp(
        home: DiscoveryScreen(discoveryController: discoveryController),
      ),
    );
  }

  testWidgets('GIVEN tela de descoberta WHEN renderizar THEN deve exibir profissionais', (widgetTester) async {
    // GIVEN
    final discoveryController = createDiscoveryController();

    // WHEN
    await pumpDiscoveryScreen(widgetTester, discoveryController);

    // THEN
    expect(find.text('Descobrir profissionais'), findsOneWidget);
    expect(find.text('Maria Eletricista'), findsOneWidget);
    expect(find.text('Ana Pintora'), findsOneWidget);
  });

  testWidgets('GIVEN profissionais disponiveis WHEN buscar sem resultado THEN deve exibir estado vazio', (widgetTester) async {
    // GIVEN
    final discoveryController = createDiscoveryController();
    await pumpDiscoveryScreen(widgetTester, discoveryController);

    // WHEN
    await widgetTester.enterText(find.byKey(const ValueKey('keyword-search-field')), 'jardinagem');
    await widgetTester.pump();

    // THEN
    expect(find.text('Nenhum profissional encontrado'), findsOneWidget);
    expect(find.byIcon(Icons.search_off), findsOneWidget);
  });

  testWidgets('GIVEN filtro ativo WHEN limpar filtros THEN deve restaurar resultados', (widgetTester) async {
    // GIVEN
    final discoveryController = createDiscoveryController();
    await pumpDiscoveryScreen(widgetTester, discoveryController);
    await widgetTester.enterText(find.byKey(const ValueKey('keyword-search-field')), 'jardinagem');
    await widgetTester.pump();

    // WHEN
    await widgetTester.tap(find.byTooltip('Limpar filtros'));
    await widgetTester.pump();

    // THEN
    expect(discoveryController.state.hasActiveFilters, isFalse);
    expect(find.text('Maria Eletricista'), findsOneWidget);
    expect(find.text('Ana Pintora'), findsOneWidget);
  });
}
