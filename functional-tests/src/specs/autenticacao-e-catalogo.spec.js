const { cleanFunctionalScenario, prepareFunctionalScenario } = require('../support/functionalTestLifecycle');
const {
  assertStatus,
  authenticateCustomerWithLocalAccount,
  createCategoryWithAdministrator,
  createCityWithAdministrator,
  defaultLocalPassword,
  listProfessionalsByCategoryAndCity,
  loadPasswordRecoveryToken,
  loginWithEmailAndPassword,
  refreshAuthenticationSession,
  registerLocalCustomer,
  registerProfessional,
  requestPasswordRecovery,
  resetPassword,
  revokeAuthenticationSession,
  uniqueEmailAddress,
  uniquePhoneNumber,
  uniqueText,
  worklinkHttpClient,
} = require('../support/worklinkScenarioSupport');

describe('Specs funcionais E2E reais - autenticacao e catalogo', () => {
  beforeEach(async () => {
    await prepareFunctionalScenario();
  });

  afterEach(async () => {
    await cleanFunctionalScenario();
  });

  test('GIVEN novo cliente WHEN cadastrar e entrar com email e senha THEN deve receber sessao autenticada', async () => {
    const emailAddress = uniqueEmailAddress();

    const registration = await registerLocalCustomer({
      emailAddress,
      password: defaultLocalPassword,
    });
    const loginResponse = await loginWithEmailAndPassword(emailAddress, defaultLocalPassword);

    expect(registration.account.customerIdentifier).toBeTruthy();
    assertStatus(loginResponse, 200);
    expect(loginResponse.data.customerIdentifier).toBe(registration.account.customerIdentifier);
    expect(loginResponse.data.accessToken).toBeTruthy();
    expect(loginResponse.data.refreshToken).toBeTruthy();
  });

  test('GIVEN credenciais invalidas WHEN entrar THEN deve responder genericamente sem enumerar conta', async () => {
    const emailAddress = uniqueEmailAddress();
    await registerLocalCustomer({ emailAddress });

    const wrongPasswordResponse = await loginWithEmailAndPassword(
      emailAddress,
      'Outra senha segura 123!',
    );
    const unknownAccountResponse = await loginWithEmailAndPassword(
      uniqueEmailAddress('conta.inexistente'),
      'Outra senha segura 123!',
    );

    assertStatus(wrongPasswordResponse, 401);
    assertStatus(unknownAccountResponse, 401);
    expect(wrongPasswordResponse.data.message).toBeTruthy();
    expect(unknownAccountResponse.data.message).toBe(wrongPasswordResponse.data.message);
    expect(JSON.stringify(wrongPasswordResponse.data)).not.toContain(emailAddress);
  });

  test('GIVEN email ja cadastrado WHEN repetir com caixa e espacos diferentes THEN nao deve criar outra conta', async () => {
    const canonicalEmailAddress = uniqueEmailAddress('email.normalizado');
    const mixedCaseEmailAddress = `  ${canonicalEmailAddress.toUpperCase()}  `;
    await registerLocalCustomer({ emailAddress: mixedCaseEmailAddress });

    const duplicatedRegistrationResponse = await worklinkHttpClient.post(
      '/api/v1/authentication/register',
      {
        fullName: uniqueText('Cliente duplicado'),
        phoneNumber: uniquePhoneNumber(),
        emailAddress: canonicalEmailAddress,
        password: defaultLocalPassword,
        passwordConfirmation: defaultLocalPassword,
        legalAccepted: true,
      },
    );
    const loginResponse = await loginWithEmailAndPassword(
      ` ${canonicalEmailAddress.toUpperCase()} `,
      defaultLocalPassword,
    );

    assertStatus(duplicatedRegistrationResponse, 400);
    expect(duplicatedRegistrationResponse.data.message).toBeTruthy();
    expect(JSON.stringify(duplicatedRegistrationResponse.data)).not.toContain(canonicalEmailAddress);
    assertStatus(loginResponse, 200);
  });

  test('GIVEN sessao local WHEN renovar e sair THEN deve rotacionar e revogar o refresh token', async () => {
    const authenticationResponse = await authenticateCustomerWithLocalAccount();

    const refreshResponse = await refreshAuthenticationSession(authenticationResponse.refreshToken);
    assertStatus(refreshResponse, 200);
    expect(refreshResponse.data.refreshToken).toBeTruthy();
    expect(refreshResponse.data.refreshToken).not.toBe(authenticationResponse.refreshToken);

    const replayResponse = await refreshAuthenticationSession(authenticationResponse.refreshToken);
    assertStatus(replayResponse, 401);

    const revokeResponse = await revokeAuthenticationSession(refreshResponse.data.refreshToken);
    assertStatus(revokeResponse, 204);

    const refreshAfterLogoutResponse = await refreshAuthenticationSession(refreshResponse.data.refreshToken);
    assertStatus(refreshAfterLogoutResponse, 401);
  });

  test('GIVEN conta local WHEN solicitar e concluir recuperacao THEN deve trocar senha com token de uso unico', async () => {
    const emailAddress = uniqueEmailAddress('recuperacao');
    const newPassword = 'Nova senha local segura 456!';
    await registerLocalCustomer({ emailAddress });

    const recoveryRequestResponse = await requestPasswordRecovery(emailAddress);
    const unknownRecoveryRequestResponse = await requestPasswordRecovery(
      uniqueEmailAddress('recuperacao.inexistente'),
    );

    assertStatus(recoveryRequestResponse, 202);
    expect(unknownRecoveryRequestResponse.status).toBe(recoveryRequestResponse.status);
    expect(recoveryRequestResponse.data.message).toBeTruthy();
    expect(unknownRecoveryRequestResponse.data.message).toBe(recoveryRequestResponse.data.message);
    expect(JSON.stringify(recoveryRequestResponse.data)).not.toContain(emailAddress);

    const recoveryToken = await loadPasswordRecoveryToken(emailAddress);
    expect(recoveryToken).toBeTruthy();

    const resetResponse = await resetPassword(recoveryToken, newPassword);
    assertStatus(resetResponse, 204);

    const oldPasswordLoginResponse = await loginWithEmailAndPassword(
      emailAddress,
      defaultLocalPassword,
    );
    assertStatus(oldPasswordLoginResponse, 401);

    const newPasswordLoginResponse = await loginWithEmailAndPassword(emailAddress, newPassword);
    assertStatus(newPasswordLoginResponse, 200);
    expect(newPasswordLoginResponse.data.accessToken).toBeTruthy();

    const reusedTokenResponse = await resetPassword(recoveryToken, 'Terceira senha segura 789!');
    assertStatus(reusedTokenResponse, 400);
  });

  test('GIVEN OTP desabilitado WHEN solicitar codigo THEN deve rejeitar o canal futuro', async () => {
    const phoneNumber = uniquePhoneNumber();

    const otpRequestResponse = await worklinkHttpClient.post('/api/v1/authentication/otp/request', {
      phoneNumber,
    });

    assertStatus(otpRequestResponse, 400);
    expect(otpRequestResponse.data.message).toBeTruthy();
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
