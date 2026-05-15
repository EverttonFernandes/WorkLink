const { createWorkLinkHttpClient } = require('./worklinkHttpClient');

const worklinkHttpClient = createWorkLinkHttpClient();

async function prepareFunctionalScenario() {
  await worklinkHttpClient.post('/api/v1/test-support/reset');
}

async function cleanFunctionalScenario() {
  await worklinkHttpClient.post('/api/v1/test-support/reset');
}

module.exports = {
  cleanFunctionalScenario,
  prepareFunctionalScenario,
};
