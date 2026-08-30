const { cleanFunctionalScenario, prepareFunctionalScenario } = require('../support/functionalTestLifecycle');
const {
  assertStatus,
  authenticateCustomerWithLocalAccount,
  blockProfessionalAsAdministrator,
  createCategoryWithAdministrator,
  createCityWithAdministrator,
  listProfessionalsByCategoryAndCity,
  loadCustomerProfile,
  loadProfessionalDetail,
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

  test('GIVEN profissional ativo WHEN listar anonimamente THEN deve retornar somente resumo publico minimo', async () => {
    // GIVEN
    const category = await createCategoryWithAdministrator(uniqueText('Categoria vitrine publica'));
    const city = await createCityWithAdministrator(uniqueText('Cidade vitrine publica'), 'RS');
    const professional = await registerProfessional({
      professionalName: uniqueText('Profissional vitrine publica'),
      whatsappNumber: uniquePhoneNumber(),
      cityIdentifier: city.cityIdentifier,
      categoryIdentifier: category.categoryIdentifier,
      shortDescription: 'Resumo publico funcional.',
    });

    // WHEN
    const searchResult = await listProfessionalsByCategoryAndCity(
      category.categoryIdentifier,
      city.cityIdentifier,
    );

    // THEN
    expect(searchResult).toHaveLength(1);
    expect(searchResult[0].professionalIdentifier).toBe(professional.professionalIdentifier);
    expect(searchResult[0].professionalName).toBe(professional.professionalName);
    expect(searchResult[0].shortDescription).toBe('Resumo publico funcional.');
    expect(searchResult[0].whatsappNumber).toBeUndefined();
    expect(searchResult[0].usefulLink).toBeUndefined();
    expect(searchResult[0].portfolioDescription).toBeUndefined();
    expect(searchResult[0].serviceDescription).toBeUndefined();
    expect(searchResult[0].profileClassification).toBeUndefined();
  });

  test('GIVEN profissional ativo WHEN abrir detalhe anonimamente THEN deve exigir autenticacao com 401', async () => {
    // GIVEN
    const category = await createCategoryWithAdministrator(uniqueText('Categoria detalhe anonimo'));
    const city = await createCityWithAdministrator(uniqueText('Cidade detalhe anonimo'), 'RS');
    const professional = await registerProfessional({
      professionalName: uniqueText('Profissional detalhe anonimo'),
      whatsappNumber: uniquePhoneNumber(),
      cityIdentifier: city.cityIdentifier,
      categoryIdentifier: category.categoryIdentifier,
      shortDescription: 'Detalhe protegido de acesso anonimo.',
    });

    // WHEN
    const detailResponse = await loadProfessionalDetail(professional.professionalIdentifier);

    // THEN
    assertStatus(detailResponse, 401);
    expect(detailResponse.data.message).toBe('Autenticacao obrigatoria para este recurso.');
  });

  test('GIVEN cliente autenticado WHEN abrir detalhe ativo THEN deve retornar perfil protegido com 200', async () => {
    // GIVEN
    const category = await createCategoryWithAdministrator(uniqueText('Categoria detalhe autenticado'));
    const city = await createCityWithAdministrator(uniqueText('Cidade detalhe autenticado'), 'RS');
    const professional = await registerProfessional({
      professionalName: uniqueText('Profissional detalhe autenticado'),
      whatsappNumber: uniquePhoneNumber(),
      cityIdentifier: city.cityIdentifier,
      categoryIdentifier: category.categoryIdentifier,
      shortDescription: 'Detalhe protegido para cliente autenticado.',
    });
    const customerAuthentication = await authenticateCustomerWithLocalAccount(uniquePhoneNumber());

    // WHEN
    const detailResponse = await loadProfessionalDetail(
      professional.professionalIdentifier,
      customerAuthentication.accessToken,
    );

    // THEN
    assertStatus(detailResponse, 200);
    expect(detailResponse.data.professionalIdentifier).toBe(professional.professionalIdentifier);
    expect(detailResponse.data.professionalName).toBe(professional.professionalName);
    expect(detailResponse.data.shortDescription).toBe('Detalhe protegido para cliente autenticado.');
    expect(detailResponse.data.whatsappNumber).toBeUndefined();
    expect(detailResponse.data.documentNumberHash).toBeUndefined();
    expect(detailResponse.data.documentProvided).toBeUndefined();
  });

  test('GIVEN profissional bloqueado WHEN cliente autenticado abrir detalhe THEN deve responder 404', async () => {
    // GIVEN
    const category = await createCategoryWithAdministrator(uniqueText('Categoria detalhe bloqueado'));
    const city = await createCityWithAdministrator(uniqueText('Cidade detalhe bloqueado'), 'RS');
    const professional = await registerProfessional({
      professionalName: uniqueText('Profissional detalhe bloqueado'),
      whatsappNumber: uniquePhoneNumber(),
      cityIdentifier: city.cityIdentifier,
      categoryIdentifier: category.categoryIdentifier,
      shortDescription: 'Detalhe indisponivel depois do bloqueio.',
    });
    const customerAuthentication = await authenticateCustomerWithLocalAccount(uniquePhoneNumber());
    const blockResponse = await blockProfessionalAsAdministrator(professional.professionalIdentifier);
    assertStatus(blockResponse, 200);

    // WHEN
    const detailResponse = await loadProfessionalDetail(
      professional.professionalIdentifier,
      customerAuthentication.accessToken,
    );

    // THEN
    assertStatus(detailResponse, 404);
    expect(detailResponse.data.message).toBe('Profissional nao encontrado.');
  });

  test('GIVEN profissional bloqueado WHEN buscar na vitrine THEN ele nao deve aparecer', async () => {
    // GIVEN
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

    // WHEN
    const searchResult = await listProfessionalsByCategoryAndCity(
      category.categoryIdentifier,
      city.cityIdentifier,
    );

    // THEN
    expect(searchResult.find(
      (listedProfessional) => listedProfessional.professionalIdentifier === professional.professionalIdentifier,
    )).toBeUndefined();
  });

  test('GIVEN profissional autenticado WHEN acessar endpoint administrativo THEN deve receber 403', async () => {
    // GIVEN
    const category = await createCategoryWithAdministrator(uniqueText('Categoria admin'));
    const city = await createCityWithAdministrator(uniqueText('Cidade admin'), 'RS');
    const professional = await registerProfessional({
      professionalName: uniqueText('Profissional admin'),
      whatsappNumber: uniquePhoneNumber(),
      cityIdentifier: city.cityIdentifier,
      categoryIdentifier: category.categoryIdentifier,
      shortDescription: 'Profissional sem acesso administrativo.',
    });

    // WHEN
    const response = await worklinkHttpClient.get('/api/v1/admin/professionals', {
      headers: professionalAuthorizationHeader(professional.professionalIdentifier),
    });

    // THEN
    assertStatus(response, 403);
    expect(response.data.message).toBe('Acesso negado para este recurso.');
  });

  test('GIVEN dois clientes WHEN cada um consultar seu proprio perfil THEN dados privados nao devem vazar entre usuarios', async () => {
    // GIVEN
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

    // WHEN
    const firstCustomerProfileResponse = await loadCustomerProfile(firstCustomerAuthentication.accessToken);
    const secondCustomerProfileResponse = await loadCustomerProfile(secondCustomerAuthentication.accessToken);

    // THEN
    assertStatus(firstCustomerProfileResponse, 200);
    assertStatus(secondCustomerProfileResponse, 200);
    expect(firstCustomerProfileResponse.data.savedProfessionals).toHaveLength(1);
    expect(secondCustomerProfileResponse.data.savedProfessionals).toHaveLength(0);
  });
});
