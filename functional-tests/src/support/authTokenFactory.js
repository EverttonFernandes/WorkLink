const crypto = require('crypto');

function createSignedJwtAccessToken({ principalIdentifier, profile }) {
  const jwtSecret = requiredEnvironmentValue('WORKLINK_JWT_SECRET');
  const accessTokenExpirationMinutes = Number(process.env.WORKLINK_ACCESS_TOKEN_EXPIRATION_MINUTES || '15');
  const issuedAt = Math.floor(Date.now() / 1000);
  const expiresAt = issuedAt + (accessTokenExpirationMinutes * 60);
  const header = base64UrlEncode(JSON.stringify({ alg: 'HS256', typ: 'JWT' }));
  const payload = base64UrlEncode(JSON.stringify({
    sub: principalIdentifier,
    profile,
    iat: issuedAt,
    exp: expiresAt,
  }));
  const unsignedToken = `${header}.${payload}`;
  const signature = crypto
    .createHmac('sha256', jwtSecret)
    .update(unsignedToken)
    .digest('base64url');

  return `${unsignedToken}.${signature}`;
}

function createAuthorizationHeader(accessToken) {
  return { Authorization: `Bearer ${accessToken}` };
}

function requiredEnvironmentValue(environmentVariableName) {
  const environmentVariableValue = process.env[environmentVariableName];
  if (!environmentVariableValue) {
    throw new Error(`Environment variable ${environmentVariableName} is required for functional tests.`);
  }
  return environmentVariableValue;
}

function base64UrlEncode(value) {
  return Buffer.from(value, 'utf8').toString('base64url');
}

module.exports = {
  createAuthorizationHeader,
  createSignedJwtAccessToken,
};
