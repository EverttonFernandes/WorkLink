const crypto = require('crypto');

const { createAuthorizationHeader, createSignedJwtAccessToken } = require('./authTokenFactory');
const { createWorkLinkHttpClient } = require('./worklinkHttpClient');

const worklinkHttpClient = createWorkLinkHttpClient();
const fixedOtp = process.env.WORKLINK_TEST_SUPPORT_FIXED_OTP || '123456';

async function authenticateCustomerByPhone(phoneNumber) {
  const otpRequestResponse = await worklinkHttpClient.post('/api/v1/authentication/otp/request', {
    phoneNumber,
  });
  assertStatus(otpRequestResponse, 200);

  const otpVerificationResponse = await worklinkHttpClient.post('/api/v1/authentication/otp/verify', {
    phoneNumber,
    oneTimePassword: fixedOtp,
  });
  assertStatus(otpVerificationResponse, 200);
  return otpVerificationResponse.data;
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
  authenticateCustomerByPhone,
  blockProfessionalAsAdministrator,
  createCategoryWithAdministrator,
  createCityWithAdministrator,
  listPendingFeedbackRequests,
  listProfessionalsByCategoryAndCity,
  loadCustomerProfile,
  loadProfessionalReviewProfile,
  professionalAuthorizationHeader,
  registerAnonymousReviewAsCustomer,
  registerPostContactFeedbackAsCustomer,
  registerProfessional,
  registerProfessionalReportAsCustomer,
  saveProfessionalAsCustomer,
  startContactAsCustomer,
  uniquePhoneNumber,
  uniqueText,
  worklinkHttpClient,
};
