const {
  categories,
  cities,
  professionals,
} = require('../scripts/seedHomologationScenario');

describe('Massa regional de homologacao mobile', () => {
  test('GIVEN seed de homologacao WHEN validar cidades THEN deve cobrir regiao inicial da V1', () => {
    // GIVEN
    const expectedCityNames = [
      'Charqueadas',
      'Sao Jeronimo',
      'Triunfo',
      'Arroio dos Ratos',
      'Eldorado do Sul',
      'General Camara',
      'Butia',
    ];

    // WHEN
    const seededCityNames = cities.map((city) => city.cityName);

    // THEN
    expect(seededCityNames).toEqual(expectedCityNames);
  });

  test('GIVEN seed de homologacao WHEN validar profissionais THEN deve permitir descoberta regional com e sem resultado', () => {
    // GIVEN
    const seededCityKeys = new Set(cities.map((city) => city.key));
    const seededCategoryKeys = new Set(categories.map((category) => category.key));

    // WHEN
    const professionalCityKeys = new Set(professionals.map((professional) => professional.cityKey));
    const professionalsByCity = cities.map((city) =>
      professionals.filter((professional) => professional.cityKey === city.key),
    );

    // THEN
    for (const professional of professionals) {
      expect(seededCityKeys.has(professional.cityKey)).toBe(true);
      expect(seededCategoryKeys.has(professional.categoryKey)).toBe(true);
    }
    expect(professionals.length).toBeGreaterThanOrEqual(cities.length);
    expect(professionalsByCity.every((cityProfessionals) => cityProfessionals.length >= 1)).toBe(true);
    expect(professionalCityKeys.has('eldorado-do-sul')).toBe(true);
    expect(professionalCityKeys.has('general-camara')).toBe(true);
  });
});
