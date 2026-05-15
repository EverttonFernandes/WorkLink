const { cleanFunctionalScenario, prepareFunctionalScenario } = require('../support/functionalTestLifecycle');
const {
  assertStatus,
  authenticateCustomerByPhone,
  createCategoryWithAdministrator,
  createCityWithAdministrator,
  listProfessionalsByCategoryAndCity,
  registerProfessional,
  uniquePhoneNumber,
  uniqueText,
} = require('../support/worklinkScenarioSupport');

describe('Specs funcionais E2E reais - autenticacao e catalogo', () => {
  beforeEach(async () => {
    await prepareFunctionalScenario();
  });

  afterEach(async () => {
    await cleanFunctionalScenario();
  });

  test('GIVEN cliente por telefone WHEN solicitar e validar OTP THEN deve receber sessao autenticada', async () => {
    const phoneNumber = uniquePhoneNumber();

    const authenticationResponse = await authenticateCustomerByPhone(phoneNumber);

    expect(authenticationResponse.customerIdentifier).toBeTruthy();
    expect(authenticationResponse.accessToken).toBeTruthy();
    expect(authenticationResponse.refreshToken).toBeTruthy();
  });

  test('GIVEN categoria cidade e profissional cadastrados WHEN buscar por categoria e cidade THEN deve retornar o profissional correto', async () => {
    const category = await createCategoryWithAdministrator(uniqueText('Categoria funcional'));
    const city = await createCityWithAdministrator(uniqueText('Cidade funcional'), 'RS');
    const professional = await registerProfessional({
      professionalName: uniqueText('Profissional funcional'),
      whatsappNumber: uniquePhoneNumber(),
      cityIdentifier: city.cityIdentifier,
      categoryIdentifier: category.categoryIdentifier,
      shortDescription: 'Atendimento funcional para testes.',
    });

    const searchResult = await listProfessionalsByCategoryAndCity(
      category.categoryIdentifier,
      city.cityIdentifier,
    );

    expect(searchResult).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          professionalIdentifier: professional.professionalIdentifier,
          professionalName: professional.professionalName,
          cityIdentifier: city.cityIdentifier,
          categoryIdentifier: category.categoryIdentifier,
        }),
      ]),
    );
  });
});
