const { cleanFunctionalScenario, prepareFunctionalScenario } = require('../support/functionalTestLifecycle');
const {
  assertStatus,
  authenticateCustomerWithLocalAccount,
  blockProfessionalAsAdministrator,
  createCategoryWithAdministrator,
  createCityWithAdministrator,
  listProfessionalsByCategoryAndCity,
  loadCustomerProfile,
  professionalAuthorizationHeader,
  registerProfessional,
  saveProfessionalAsCustomer,
  uniquePhoneNumber,
  uniqueText,
  worklinkHttpClient,
} = require('../support/worklinkScenarioSupport');

describe('Specs funcionais E2E reais - autorizacao e bloqueios', () => {
  beforeEach(async () => {
    await prepareFunctionalScenario();
  });

  afterEach(async () => {
    await cleanFunctionalScenario();
  });

  test('GIVEN profissional bloqueado WHEN buscar na vitrine THEN ele nao deve aparecer', async () => {
    const category = await createCategoryWithAdministrator(uniqueText('Categoria bloqueio'));
    const city = await createCityWithAdministrator(uniqueText('Cidade bloqueio'), 'RS');
    const professional = await registerProfessional({
      professionalName: uniqueText('Profissional bloqueado'),
      whatsappNumber: uniquePhoneNumber(),
      cityIdentifier: city.cityIdentifier,
      categoryIdentifier: category.categoryIdentifier,
      shortDescription: 'Profissional para teste de bloqueio.',
    });

    const blockResponse = await blockProfessionalAsAdministrator(professional.professionalIdentifier);
    assertStatus(blockResponse, 200);

    const searchResult = await listProfessionalsByCategoryAndCity(
      category.categoryIdentifier,
      city.cityIdentifier,
    );

    expect(searchResult.find(
      (listedProfessional) => listedProfessional.professionalIdentifier === professional.professionalIdentifier,
    )).toBeUndefined();
  });

  test('GIVEN profissional autenticado WHEN acessar endpoint administrativo THEN deve receber 403', async () => {
    const category = await createCategoryWithAdministrator(uniqueText('Categoria admin'));
    const city = await createCityWithAdministrator(uniqueText('Cidade admin'), 'RS');
    const professional = await registerProfessional({
      professionalName: uniqueText('Profissional admin'),
      whatsappNumber: uniquePhoneNumber(),
      cityIdentifier: city.cityIdentifier,
      categoryIdentifier: category.categoryIdentifier,
      shortDescription: 'Profissional sem acesso administrativo.',
    });

    const response = await worklinkHttpClient.get('/api/v1/admin/professionals', {
      headers: professionalAuthorizationHeader(professional.professionalIdentifier),
    });

    assertStatus(response, 403);
    expect(response.data.message).toBe('Acesso negado para este recurso.');
  });

  test('GIVEN dois clientes WHEN cada um consultar seu proprio perfil THEN dados privados nao devem vazar entre usuarios', async () => {
    const category = await createCategoryWithAdministrator(uniqueText('Categoria privacidade'));
    const city = await createCityWithAdministrator(uniqueText('Cidade privacidade'), 'RS');
    const professional = await registerProfessional({
      professionalName: uniqueText('Profissional privacidade'),
      whatsappNumber: uniquePhoneNumber(),
      cityIdentifier: city.cityIdentifier,
      categoryIdentifier: category.categoryIdentifier,
      shortDescription: 'Profissional salvo apenas por um cliente.',
    });
    const firstCustomerAuthentication = await authenticateCustomerWithLocalAccount(uniquePhoneNumber());
    const secondCustomerAuthentication = await authenticateCustomerWithLocalAccount(uniquePhoneNumber());

    const saveResponse = await saveProfessionalAsCustomer(
      firstCustomerAuthentication.accessToken,
      professional.professionalIdentifier,
    );
    assertStatus(saveResponse, 200);

    const firstCustomerProfileResponse = await loadCustomerProfile(firstCustomerAuthentication.accessToken);
    const secondCustomerProfileResponse = await loadCustomerProfile(secondCustomerAuthentication.accessToken);

    assertStatus(firstCustomerProfileResponse, 200);
    assertStatus(secondCustomerProfileResponse, 200);
    expect(firstCustomerProfileResponse.data.savedProfessionals).toHaveLength(1);
    expect(secondCustomerProfileResponse.data.savedProfessionals).toHaveLength(0);
  });
});
