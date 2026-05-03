const axios = require('axios');

function createWorkLinkHttpClient() {
  const baseURL = process.env.WORKLINK_FUNCTIONAL_BASE_URL || 'http://worklink-api:8080';

  return axios.create({
    baseURL,
    timeout: 10000,
    validateStatus: () => true,
  });
}

module.exports = {
  createWorkLinkHttpClient,
};
