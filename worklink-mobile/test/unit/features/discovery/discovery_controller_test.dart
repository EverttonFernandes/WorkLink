import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/discovery/discovery_controller.dart';
import 'package:worklink_mobile/features/discovery/discovery_professional.dart';

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
      availableProfessionals: const [
        electricianProfessional,
        painterProfessional,
      ],
    );
  }

  test(
      'GIVEN profissionais disponiveis WHEN filtrar por categoria THEN deve retornar categoria selecionada',
      () {
    // GIVEN
    final discoveryController = createDiscoveryController();

    // WHEN
    discoveryController.selectCategory('Eletricista');

    // THEN
    expect(
      discoveryController.state.filteredProfessionals,
      contains(electricianProfessional),
    );
    expect(
      discoveryController.state.filteredProfessionals,
      isNot(contains(painterProfessional)),
    );
  });

  test(
      'GIVEN profissionais disponiveis WHEN filtrar por cidade THEN deve retornar cidade selecionada',
      () {
    // GIVEN
    final discoveryController = createDiscoveryController();

    // WHEN
    discoveryController.selectCity('Porto Alegre - RS');

    // THEN
    expect(
      discoveryController.state.filteredProfessionals,
      contains(painterProfessional),
    );
    expect(
      discoveryController.state.filteredProfessionals,
      isNot(contains(electricianProfessional)),
    );
  });

  test(
      'GIVEN profissionais disponiveis WHEN buscar por palavra-chave THEN deve buscar em nome e descricao',
      () {
    // GIVEN
    final discoveryController = createDiscoveryController();

    // WHEN
    discoveryController.searchByKeyword('acabamento');

    // THEN
    expect(
      discoveryController.state.filteredProfessionals,
      contains(painterProfessional),
    );
    expect(
      discoveryController.state.filteredProfessionals,
      isNot(contains(electricianProfessional)),
    );
  });

  test(
      'GIVEN filtros ativos WHEN limpar filtros THEN deve restaurar busca padrao',
      () {
    // GIVEN
    final discoveryController = createDiscoveryController();
    discoveryController.selectCategory('Eletricista');
    discoveryController.searchByKeyword('residencial');

    // WHEN
    discoveryController.clearFilters();

    // THEN
    expect(discoveryController.state.hasActiveFilters, isFalse);
    expect(
      discoveryController.state.filteredProfessionals,
      contains(electricianProfessional),
    );
    expect(
      discoveryController.state.filteredProfessionals,
      contains(painterProfessional),
    );
  });
}
