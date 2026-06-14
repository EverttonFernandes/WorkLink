const crypto = require('crypto');

const { createAuthorizationHeader, createSignedJwtAccessToken } = require('./authTokenFactory');
const { createWorkLinkHttpClient } = require('./worklinkHttpClient');

const worklinkHttpClient = createWorkLinkHttpClient();
const defaultLocalPassword = 'Senha local segura 123!';

async function registerLocalCustomer({
  fullName = uniqueText('Cliente funcional'),
  phoneNumber = uniquePhoneNumber(),
  emailAddress = uniqueEmailAddress(),
  password = defaultLocalPassword,
} = {}) {
  const response = await worklinkHttpClient.post('/api/v1/authentication/register', {
    fullName,
    phoneNumber,
    emailAddress,
    password,
    passwordConfirmation: password,
    legalAccepted: true,
  });
  assertStatus(response, 201);
  return {
    account: response.data,
    credentials: {
      emailAddress,
      password,
    },
  };
}

async function loginWithEmailAndPassword(emailAddress, password) {
  return worklinkHttpClient.post('/api/v1/authentication/login', {
    emailAddress,
    password,
  });
}

async function authenticateCustomerWithLocalAccount(accountData = {}) {
  const normalizedAccountData = typeof accountData === 'string'
    ? {
        phoneNumber: accountData,
        emailAddress: uniqueEmailAddress('cliente.local'),
      }
    : accountData;
  const registration = await registerLocalCustomer(normalizedAccountData);
  const loginResponse = await loginWithEmailAndPassword(
    registration.credentials.emailAddress,
    registration.credentials.password,
  );
  assertStatus(loginResponse, 200);
  return loginResponse.data;
}

async function refreshAuthenticationSession(refreshToken) {
  return worklinkHttpClient.post('/api/v1/authentication/session/refresh', {
    refreshToken,
  });
}

async function revokeAuthenticationSession(refreshToken) {
  return worklinkHttpClient.post('/api/v1/authentication/session/revoke', {
    refreshToken,
  });
}

async function requestPasswordRecovery(emailAddress) {
  return worklinkHttpClient.post('/api/v1/authentication/password-recovery/request', {
    emailAddress,
  });
}

async function loadPasswordRecoveryToken(emailAddress) {
  const response = await worklinkHttpClient.get('/api/v1/test-support/password-recovery', {
    params: { emailAddress },
  });
  assertStatus(response, 200);
  return response.data.recoveryToken;
}

async function resetPassword(recoveryToken, newPassword) {
  return worklinkHttpClient.post('/api/v1/authentication/password-recovery/reset', {
    recoveryToken,
    newPassword,
    newPasswordConfirmation: newPassword,
  });
}

async function createCategoryWithAdministrator(categoryName) {
  const response = await worklinkHttpClient.post(
    '/api/v1/categories',
    { categoryName },
    { headers: administratorAuthorizationHeader() },
  );
  assertStatus(response, 201);
  return response.data;
}

async function createCityWithAdministrator(cityName, stateCode) {
  const response = await worklinkHttpClient.post(
    '/api/v1/cities',
    { cityName, stateCode },
    { headers: administratorAuthorizationHeader() },
  );
  assertStatus(response, 201);
  return response.data;
}

async function registerProfessional({
  professionalName,
  whatsappNumber,
  cityIdentifier,
  categoryIdentifier,
  shortDescription,
}) {
  const response = await worklinkHttpClient.post('/api/v1/professionals', {
    professionalName,
    whatsappNumber,
    cityIdentifier,
    categoryIdentifier,
    shortDescription,
  });
  assertStatus(response, 201);
  return response.data;
}

async function listProfessionalsByCategoryAndCity(categoryIdentifier, cityIdentifier) {
  const response = await worklinkHttpClient.get('/api/v1/professionals', {
    params: { categoryIdentifier, cityIdentifier },
  });
  assertStatus(response, 200);
  return response.data;
}

async function startContactAsCustomer(customerAccessToken, professionalIdentifier) {
  const response = await worklinkHttpClient.post(
    '/api/v1/contact-intentions',
    { professionalIdentifier },
    { headers: createAuthorizationHeader(customerAccessToken) },
  );
  return response;
}

async function listPendingFeedbackRequests(customerAccessToken) {
  const response = await worklinkHttpClient.get('/api/v1/customers/me/post-contact-feedback-requests', {
    headers: createAuthorizationHeader(customerAccessToken),
  });
  assertStatus(response, 200);
  return response.data;
}

async function registerPostContactFeedbackAsCustomer(
  customerAccessToken,
  contactIntentIdentifier,
  {
    conversationOutcome = 'CUSTOMER_REACHED_PROFESSIONAL',
    contactResponsiveness = 'FAST_RESPONSE',
    serviceExecutionOutcome = 'SERVICE_PERFORMED',
  } = {},
) {
  const response = await worklinkHttpClient.post(
    '/api/v1/post-contact-feedbacks',
    {
      contactIntentIdentifier,
      conversationOutcome,
      contactResponsiveness,
      serviceExecutionOutcome,
    },
    { headers: createAuthorizationHeader(customerAccessToken) },
  );
  return response;
}

async function registerAnonymousReviewAsCustomer(customerAccessToken, contactIntentIdentifier, starRating, comment) {
  const response = await worklinkHttpClient.post(
    '/api/v1/professional-reviews',
    {
      contactIntentIdentifier,
      starRating,
      comment,
      anonymousToPublic: true,
    },
    { headers: createAuthorizationHeader(customerAccessToken) },
  );
  return response;
}

async function loadProfessionalReviewProfile(professionalIdentifier) {
  const response = await worklinkHttpClient.get(`/api/v1/professional-reviews/professionals/${professionalIdentifier}`);
  assertStatus(response, 200);
  return response.data;
}

async function registerProfessionalReportAsCustomer(customerAccessToken, professionalIdentifier, reportReason, description) {
  const response = await worklinkHttpClient.post(
    '/api/v1/professional-reports',
    {
      professionalIdentifier,
      reportReason,
      description,
      evidenceFileIdentifier: null,
    },
    { headers: createAuthorizationHeader(customerAccessToken) },
  );
  return response;
}

async function blockProfessionalAsAdministrator(professionalIdentifier) {
  const response = await worklinkHttpClient.post(
    `/api/v1/admin/professionals/${professionalIdentifier}/block`,
    {},
    { headers: administratorAuthorizationHeader() },
  );
  return response;
}

async function saveProfessionalAsCustomer(customerAccessToken, professionalIdentifier) {
  const response = await worklinkHttpClient.post(
    `/api/v1/customers/me/saved-professionals/${professionalIdentifier}`,
    {},
    { headers: createAuthorizationHeader(customerAccessToken) },
  );
  return response;
}

async function loadCustomerProfile(accessToken) {
  const response = await worklinkHttpClient.get('/api/v1/customers/me/profile', {
    headers: createAuthorizationHeader(accessToken),
  });
  return response;
}

function administratorAuthorizationHeader() {
  return createAuthorizationHeader(
    createSignedJwtAccessToken({
      principalIdentifier: crypto.randomUUID(),
      profile: 'ADMINISTRATOR',
    }),
  );
}

function professionalAuthorizationHeader(professionalIdentifier) {
  return createAuthorizationHeader(
    createSignedJwtAccessToken({
      principalIdentifier: professionalIdentifier,
      profile: 'PROFESSIONAL',
    }),
  );
}

function uniquePhoneNumber() {
  const randomDigits = String(Math.floor(Math.random() * 1_000_000_000)).padStart(9, '0');
  return `51${randomDigits}`;
}

function uniqueEmailAddress(prefix = 'cliente.funcional') {
  return `${prefix}.${crypto.randomUUID()}@worklink.test`;
}

function uniqueText(prefix) {
  return `${prefix} ${crypto.randomUUID().slice(0, 8)}`;
}

function assertStatus(response, expectedStatus) {
  if (response.status !== expectedStatus) {
    throw new Error(`Expected status ${expectedStatus}, received ${response.status}: ${JSON.stringify(response.data)}`);
  }
}

module.exports = {
  administratorAuthorizationHeader,
  assertStatus,
  authenticateCustomerWithLocalAccount,
  blockProfessionalAsAdministrator,
  createCategoryWithAdministrator,
  createCityWithAdministrator,
  defaultLocalPassword,
  listPendingFeedbackRequests,
  listProfessionalsByCategoryAndCity,
  loadPasswordRecoveryToken,
  loadCustomerProfile,
  loadProfessionalReviewProfile,
  loginWithEmailAndPassword,
  professionalAuthorizationHeader,
  registerAnonymousReviewAsCustomer,
  registerLocalCustomer,
  registerPostContactFeedbackAsCustomer,
  registerProfessional,
  registerProfessionalReportAsCustomer,
  requestPasswordRecovery,
  resetPassword,
  refreshAuthenticationSession,
  revokeAuthenticationSession,
  saveProfessionalAsCustomer,
  startContactAsCustomer,
  uniqueEmailAddress,
  uniquePhoneNumber,
  uniqueText,
  worklinkHttpClient,
};
