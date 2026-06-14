const { cleanFunctionalScenario, prepareFunctionalScenario } = require('../support/functionalTestLifecycle');
const {
  assertStatus,
  authenticateCustomerWithLocalAccount,
  createCategoryWithAdministrator,
  createCityWithAdministrator,
  listPendingFeedbackRequests,
  registerPostContactFeedbackAsCustomer,
  registerProfessional,
  startContactAsCustomer,
  uniquePhoneNumber,
  uniqueText,
  worklinkHttpClient,
} = require('../support/worklinkScenarioSupport');

describe('Specs funcionais E2E reais - contato e pos-contato', () => {
  beforeEach(async () => {
    await prepareFunctionalScenario();
  });

  afterEach(async () => {
    await cleanFunctionalScenario();
  });

  test('GIVEN cliente autenticado WHEN iniciar contato via WhatsApp THEN deve registrar intencao e link externo', async () => {
    const category = await createCategoryWithAdministrator(uniqueText('Categoria contato'));
    const city = await createCityWithAdministrator(uniqueText('Cidade contato'), 'RS');
    const professional = await registerProfessional({
      professionalName: uniqueText('Profissional contato'),
      whatsappNumber: uniquePhoneNumber(),
      cityIdentifier: city.cityIdentifier,
      categoryIdentifier: category.categoryIdentifier,
      shortDescription: 'Profissional para fluxo de contato.',
    });
    const customerAuthentication = await authenticateCustomerWithLocalAccount(uniquePhoneNumber());

    const contactResponse = await startContactAsCustomer(
      customerAuthentication.accessToken,
      professional.professionalIdentifier,
    );

    assertStatus(contactResponse, 201);
    expect(contactResponse.data.whatsappContactLink).toContain('wa.me');
    expect(contactResponse.data.professionalIdentifier).toBe(professional.professionalIdentifier);
  });

  test('GIVEN contato iniciado WHEN registrar feedback estruturado THEN deve listar pendencia e salvar resposta', async () => {
    const category = await createCategoryWithAdministrator(uniqueText('Categoria feedback'));
    const city = await createCityWithAdministrator(uniqueText('Cidade feedback'), 'RS');
    const professional = await registerProfessional({
      professionalName: uniqueText('Profissional feedback'),
      whatsappNumber: uniquePhoneNumber(),
      cityIdentifier: city.cityIdentifier,
      categoryIdentifier: category.categoryIdentifier,
      shortDescription: 'Profissional para pos-contato.',
    });
    const customerAuthentication = await authenticateCustomerWithLocalAccount(uniquePhoneNumber());
    const contactResponse = await startContactAsCustomer(
      customerAuthentication.accessToken,
      professional.professionalIdentifier,
    );
    assertStatus(contactResponse, 201);

    const pendingFeedbackRequests = await listPendingFeedbackRequests(customerAuthentication.accessToken);

    expect(pendingFeedbackRequests).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          contactIntentIdentifier: contactResponse.data.contactIntentIdentifier,
        }),
      ]),
    );

    const feedbackResponse = await registerPostContactFeedbackAsCustomer(
      customerAuthentication.accessToken,
      contactResponse.data.contactIntentIdentifier,
    );

    assertStatus(feedbackResponse, 201);
    expect(feedbackResponse.data.contactIntentIdentifier).toBe(contactResponse.data.contactIntentIdentifier);
    expect(feedbackResponse.data.serviceExecutionOutcome).toBe('SERVICE_PERFORMED');
  });

  test('GIVEN usuario nao autenticado WHEN iniciar contato THEN deve receber 401', async () => {
    const professionalIdentifier = '00000000-0000-0000-0000-000000000001';

    const response = await worklinkHttpClient.post('/api/v1/contact-intentions', {
      professionalIdentifier,
    });

    assertStatus(response, 401);
    expect(response.data.message).toBe('Autenticacao obrigatoria para este recurso.');
  });
});
