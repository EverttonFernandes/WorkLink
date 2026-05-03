import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/discovery/discovery_filter_state.dart';
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

  test('GIVEN profissional WHEN obter cidade de exibicao THEN deve combinar cidade e UF', () {
    // GIVEN / WHEN
    final cityDisplayName = electricianProfessional.cityDisplayName;

    // THEN
    expect(cityDisplayName, 'Canoas - RS');
  });

  test('GIVEN estado com filtro ativo WHEN limpar categoria e cidade THEN deve preservar demais campos', () {
    // GIVEN
    const discoveryFilterState = DiscoveryFilterState(
      availableProfessionals: [electricianProfessional],
      selectedCategoryName: 'Eletricista',
      selectedCityDisplayName: 'Canoas - RS',
      keyword: 'residencial',
    );

    // WHEN
    final copiedDiscoveryFilterState = discoveryFilterState.copyWith(
      clearCategory: true,
      clearCity: true,
    );

    // THEN
    expect(copiedDiscoveryFilterState.selectedCategoryName, isNull);
    expect(copiedDiscoveryFilterState.selectedCityDisplayName, isNull);
    expect(copiedDiscoveryFilterState.keyword, 'residencial');
  });

  test('GIVEN profissionais disponiveis WHEN listar filtros disponiveis THEN deve retornar categorias e cidades ordenadas', () {
    // GIVEN
    const painterProfessional = DiscoveryProfessional(
      professionalIdentifier: 'ana-pintora',
      professionalName: 'Ana Pintora',
      categoryName: 'Pintora',
      cityName: 'Porto Alegre',
      stateCode: 'RS',
      shortDescription: 'Pintura interna e acabamento.',
    );
    const discoveryFilterState = DiscoveryFilterState(
      availableProfessionals: [painterProfessional, electricianProfessional],
    );

    // WHEN / THEN
    expect(discoveryFilterState.availableCategoryNames, ['Eletricista', 'Pintora']);
    expect(discoveryFilterState.availableCityDisplayNames, ['Canoas - RS', 'Porto Alegre - RS']);
  });

  test('GIVEN estado com filtros WHEN consultar filtros ativos THEN deve indicar filtros ativos', () {
    // GIVEN
    const discoveryFilterState = DiscoveryFilterState(
      availableProfessionals: [electricianProfessional],
      keyword: 'residencial',
    );

    // WHEN / THEN
    expect(discoveryFilterState.hasActiveFilters, isTrue);
  });
}
