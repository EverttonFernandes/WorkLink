const { cleanFunctionalScenario, prepareFunctionalScenario } = require('../support/functionalTestLifecycle');
const {
  assertStatus,
  authenticateCustomerWithLocalAccount,
  createCategoryWithAdministrator,
  createCityWithAdministrator,
  loadProfessionalReviewProfile,
  registerAnonymousReviewAsCustomer,
  registerPostContactFeedbackAsCustomer,
  registerProfessional,
  registerProfessionalReportAsCustomer,
  startContactAsCustomer,
  uniquePhoneNumber,
  uniqueText,
} = require('../support/worklinkScenarioSupport');

describe('Specs funcionais E2E reais - avaliacao e denuncia', () => {
  beforeEach(async () => {
    await prepareFunctionalScenario();
  });

  afterEach(async () => {
    await cleanFunctionalScenario();
  });

  test('GIVEN servico realizado WHEN cliente avaliar anonimamente THEN autoria publica nao deve ser exposta', async () => {
    const category = await createCategoryWithAdministrator(uniqueText('Categoria avaliacao'));
    const city = await createCityWithAdministrator(uniqueText('Cidade avaliacao'), 'RS');
    const professional = await registerProfessional({
      professionalName: uniqueText('Profissional avaliacao'),
      whatsappNumber: uniquePhoneNumber(),
      cityIdentifier: city.cityIdentifier,
      categoryIdentifier: category.categoryIdentifier,
      shortDescription: 'Profissional para avaliacao.',
    });
    const customerAuthentication = await authenticateCustomerWithLocalAccount(uniquePhoneNumber());
    const contactResponse = await startContactAsCustomer(
      customerAuthentication.accessToken,
      professional.professionalIdentifier,
    );
    assertStatus(contactResponse, 201);
    const feedbackResponse = await registerPostContactFeedbackAsCustomer(
      customerAuthentication.accessToken,
      contactResponse.data.contactIntentIdentifier,
    );
    assertStatus(feedbackResponse, 201);

    const reviewResponse = await registerAnonymousReviewAsCustomer(
      customerAuthentication.accessToken,
      contactResponse.data.contactIntentIdentifier,
      5,
      'Excelente atendimento funcional.',
    );

    assertStatus(reviewResponse, 201);
    expect(reviewResponse.data.publicAuthorIdentifier).toBeNull();
    expect(reviewResponse.data.publicAuthorDisplayName).toBe('Usuario anonimo');

    const reviewProfile = await loadProfessionalReviewProfile(
      customerAuthentication.accessToken,
      professional.professionalIdentifier,
    );

    expect(reviewProfile.summary.reviewCount).toBe(1);
    expect(reviewProfile.reviews[0].publicAuthorIdentifier).toBeNull();
    expect(reviewProfile.reviews[0].publicAuthorDisplayName).toBe('Usuario anonimo');
  });

  test('GIVEN cliente autenticado WHEN denunciar profissional THEN deve registrar denuncia funcional', async () => {
    const category = await createCategoryWithAdministrator(uniqueText('Categoria denuncia'));
    const city = await createCityWithAdministrator(uniqueText('Cidade denuncia'), 'RS');
    const professional = await registerProfessional({
      professionalName: uniqueText('Profissional denuncia'),
      whatsappNumber: uniquePhoneNumber(),
      cityIdentifier: city.cityIdentifier,
      categoryIdentifier: category.categoryIdentifier,
      shortDescription: 'Profissional para denuncia.',
    });
    const customerAuthentication = await authenticateCustomerWithLocalAccount(uniquePhoneNumber());

    const reportResponse = await registerProfessionalReportAsCustomer(
      customerAuthentication.accessToken,
      professional.professionalIdentifier,
      'THREAT',
      'Ameaca detectada durante o atendimento funcional.',
    );

    assertStatus(reportResponse, 201);
    expect(reportResponse.data.professionalIdentifier).toBe(professional.professionalIdentifier);
    expect(reportResponse.data.reportReason).toBe('THREAT');
    expect(reportResponse.data.seriousCase).toBe(true);
  });
});
