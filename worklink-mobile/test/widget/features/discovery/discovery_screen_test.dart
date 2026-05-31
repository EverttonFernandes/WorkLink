import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/discovery/discovery_controller.dart';
import 'package:worklink_mobile/features/discovery/discovery_professional.dart';
import 'package:worklink_mobile/features/discovery/discovery_screen.dart';
import 'package:worklink_mobile/features/professional_availability/professional_availability_status.dart';

void main() {
  const electricianProfessional = DiscoveryProfessional(
    professionalIdentifier: 'maria-eletricista',
    professionalName: 'Maria Eletricista',
    categoryName: 'Eletricista',
    cityName: 'Canoas',
    stateCode: 'RS',
    shortDescription: 'Atendimento residencial.',
    profileBadgeLabel: 'Perfil básico',
    availabilityStatus: ProfessionalAvailabilityStatus.availableToday,
    recentActivityLabel: 'Ativo recentemente',
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
      availableProfessionals: const [
        electricianProfessional,
        painterProfessional,
      ],
    );
  }

  Future<void> pumpDiscoveryScreen(
    WidgetTester widgetTester,
    DiscoveryController discoveryController, {
    ValueChanged<String>? onOpenProfessionalProfile,
    VoidCallback? onOpenAdministrativeConsole,
  }) async {
    widgetTester.view.physicalSize = const Size(900, 1800);
    widgetTester.view.devicePixelRatio = 1;
    addTearDown(widgetTester.view.resetPhysicalSize);
    addTearDown(widgetTester.view.resetDevicePixelRatio);
    await widgetTester.pumpWidget(
      MaterialApp(
        theme: ThemeData(splashFactory: InkRipple.splashFactory),
        home: DiscoveryScreen(
          discoveryController: discoveryController,
          onOpenProfessionalProfile: onOpenProfessionalProfile,
          onOpenAdministrativeConsole: onOpenAdministrativeConsole,
        ),
      ),
    );
  }

  testWidgets(
      'GIVEN tela de descoberta WHEN renderizar THEN deve exibir profissionais',
      (widgetTester) async {
    // GIVEN
    final discoveryController = createDiscoveryController();

    // WHEN
    await pumpDiscoveryScreen(widgetTester, discoveryController);
    await widgetTester.pumpAndSettle();

    // THEN
    expect(find.text('Buscar profissionais'), findsOneWidget);
    expect(find.text('Maria Eletricista'), findsOneWidget);
    expect(find.text('Ana Pintora'), findsOneWidget);
  });

  testWidgets(
      'GIVEN profissional com sinais WHEN renderizar card THEN deve exibir somente badges justificados',
      (widgetTester) async {
    // GIVEN
    final discoveryController = createDiscoveryController();

    // WHEN
    await pumpDiscoveryScreen(widgetTester, discoveryController);
    await widgetTester.pumpAndSettle();

    // THEN
    expect(find.text('Eletricista - Canoas - RS'), findsOneWidget);
    expect(find.text('Atendimento residencial.'), findsOneWidget);
    expect(find.text('Perfil básico'), findsOneWidget);
    expect(find.text('Disponível hoje'), findsOneWidget);
    expect(find.text('Ativo recentemente'), findsOneWidget);
    expect(find.text('Disponível agora'), findsNothing);
    expect(find.text('Garantia de atendimento'), findsNothing);
  });

  testWidgets(
      'GIVEN profissionais disponiveis WHEN buscar sem resultado THEN deve exibir estado vazio',
      (widgetTester) async {
    // GIVEN
    final discoveryController = createDiscoveryController();
    await pumpDiscoveryScreen(widgetTester, discoveryController);

    // WHEN
    await widgetTester.enterText(
      find.byKey(const ValueKey('keyword-search-field')),
      'jardinagem',
    );
    await widgetTester.pump();

    // THEN
    expect(find.text('Nenhum profissional encontrado'), findsOneWidget);
    expect(find.text('Buscar em cidades proximas'), findsOneWidget);
  });

  testWidgets(
      'GIVEN filtro ativo WHEN limpar filtros THEN deve restaurar resultados',
      (widgetTester) async {
    // GIVEN
    final discoveryController = createDiscoveryController();
    await pumpDiscoveryScreen(widgetTester, discoveryController);
    await widgetTester.enterText(
      find.byKey(const ValueKey('keyword-search-field')),
      'jardinagem',
    );
    await widgetTester.pump();

    // WHEN
    await widgetTester.tap(find.byTooltip('Limpar filtros'));
    await widgetTester.pump();

    // THEN
    expect(discoveryController.state.hasActiveFilters, isFalse);
    expect(find.text('Maria Eletricista'), findsOneWidget);
    expect(find.text('Ana Pintora'), findsOneWidget);
  });

  testWidgets(
      'GIVEN card de profissional WHEN tocar em abrir perfil THEN deve emitir identificador',
      (widgetTester) async {
    // GIVEN
    final openedProfessionalIdentifiers = <String>[];
    final discoveryController = createDiscoveryController();
    await pumpDiscoveryScreen(
      widgetTester,
      discoveryController,
      onOpenProfessionalProfile: openedProfessionalIdentifiers.add,
    );

    // WHEN
    await widgetTester.ensureVisible(
      find.byKey(const ValueKey('open-professional-profile-maria-eletricista')),
    );
    await widgetTester.tap(
      find.byKey(const ValueKey('open-professional-profile-maria-eletricista')),
    );
    await widgetTester.pump();

    // THEN
    expect(openedProfessionalIdentifiers, ['maria-eletricista']);
  });

  testWidgets(
      'GIVEN console administrativo habilitado WHEN tocar no atalho THEN deve executar callback',
      (widgetTester) async {
    // GIVEN
    var administrativeConsoleOpened = false;
    final discoveryController = createDiscoveryController();
    await pumpDiscoveryScreen(
      widgetTester,
      discoveryController,
      onOpenAdministrativeConsole: () {
        administrativeConsoleOpened = true;
      },
    );

    // WHEN
    await widgetTester.tap(
      find.byKey(const ValueKey('open-administrative-console-button')),
    );
    await widgetTester.pump();

    // THEN
    expect(administrativeConsoleOpened, isTrue);
  });
}
