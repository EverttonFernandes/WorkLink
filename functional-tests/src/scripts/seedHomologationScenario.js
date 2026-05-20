const { cleanFunctionalScenario } = require('../support/functionalTestLifecycle');
const {
  createCategoryWithAdministrator,
  createCityWithAdministrator,
  registerProfessional,
} = require('../support/worklinkScenarioSupport');

const resetBeforeSeed = process.env.WORKLINK_HOMOLOGATION_RESET === 'true';

const cities = [
  { key: 'charqueadas', cityName: 'Charqueadas', stateCode: 'RS' },
  { key: 'sao-jeronimo', cityName: 'Sao Jeronimo', stateCode: 'RS' },
  { key: 'butia', cityName: 'Butia', stateCode: 'RS' },
  { key: 'arroio-dos-ratos', cityName: 'Arroio dos Ratos', stateCode: 'RS' },
];

const categories = [
  { key: 'eletricista', categoryName: 'Eletricista' },
  { key: 'encanador', categoryName: 'Encanador' },
  { key: 'diarista', categoryName: 'Diarista' },
  { key: 'pedreiro', categoryName: 'Pedreiro' },
];

const professionals = [
  {
    professionalName: 'Ana Costa Energia Residencial',
    whatsappNumber: '51990001001',
    cityKey: 'charqueadas',
    categoryKey: 'eletricista',
    shortDescription: 'Instalacoes, disjuntores e manutencao eletrica residencial em Charqueadas.',
  },
  {
    professionalName: 'Bruno Silveira Hidraulica',
    whatsappNumber: '51990001002',
    cityKey: 'charqueadas',
    categoryKey: 'encanador',
    shortDescription: 'Consertos de vazamentos, caixas d agua, torneiras e encanamentos.',
  },
  {
    professionalName: 'Carla Mendes Limpeza',
    whatsappNumber: '51990001003',
    cityKey: 'sao-jeronimo',
    categoryKey: 'diarista',
    shortDescription: 'Diarista para residencias, pequenos escritorios e pos-obra leve.',
  },
  {
    professionalName: 'Diego Almeida Reformas',
    whatsappNumber: '51990001004',
    cityKey: 'butia',
    categoryKey: 'pedreiro',
    shortDescription: 'Reformas pequenas, alvenaria, reboco, pisos e reparos em geral.',
  },
  {
    professionalName: 'Elaine Rocha Eletrica Rapida',
    whatsappNumber: '51990001005',
    cityKey: 'arroio-dos-ratos',
    categoryKey: 'eletricista',
    shortDescription: 'Atendimento emergencial para curtos, tomadas e quadros de luz.',
  },
  {
    professionalName: 'Felipe Nunes Manutencao Hidraulica',
    whatsappNumber: '51990001006',
    cityKey: 'sao-jeronimo',
    categoryKey: 'encanador',
    shortDescription: 'Manutencao preventiva e corretiva para casas e comercios locais.',
  },
];

async function main() {
  if (resetBeforeSeed) {
    await cleanFunctionalScenario();
  }

  const createdCities = {};
  const createdCategories = {};

  for (const city of cities) {
    createdCities[city.key] = await createCityWithAdministrator(city.cityName, city.stateCode);
  }

  for (const category of categories) {
    createdCategories[category.key] = await createCategoryWithAdministrator(category.categoryName);
  }

  const createdProfessionals = [];
  for (const professional of professionals) {
    createdProfessionals.push(
      await registerProfessional({
        professionalName: professional.professionalName,
        whatsappNumber: professional.whatsappNumber,
        cityIdentifier: createdCities[professional.cityKey].cityIdentifier,
        categoryIdentifier: createdCategories[professional.categoryKey].categoryIdentifier,
        shortDescription: professional.shortDescription,
      }),
    );
  }

  console.log(
    JSON.stringify(
      {
        homologationScenario: 'worklink-carbonifera-v1',
        cities: Object.keys(createdCities).length,
        categories: Object.keys(createdCategories).length,
        professionals: createdProfessionals.length,
      },
      null,
      2,
    ),
  );
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
