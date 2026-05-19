#!/usr/bin/env node

/**
 * manage_gate.js — Gerenciamento de Quality Gates no SonarQube.
 *
 * Permite identificar, criar, copiar, modificar condições e associar
 * Quality Gates a projetos.
 *
 * Uso:
 *   node manage_gate.js <PROJECT_KEY> <ACTION> [--args]
 *
 * Ações:
 *   inspect                                    — Mostra gate e condições
 *   create    --name "QG Nome"                 — Cria novo gate e associa ao projeto
 *   copy      --source "QG Origem" --name "QG" — Copia gate e associa
 *   add-condition    --metric X --op LT --error 80     — Adiciona condição
 *   update-condition --id <ID> [--metric X] [--error Y] — Edita condição
 *   remove-condition --id <ID>                          — Remove condição
 *   assign    --gate "QG Nome"                          — Associa gate ao projeto
 *
 * Flags:
 *   --execute   Executa operações de escrita (sem isso, apenas dry-run)
 *   --json      Saída em JSON puro (para parsing pelo agente)
 */

const http = require("http");
const https = require("https");
const querystring = require("querystring");

// --- Configuration ---
const TOKEN = process.env.SONAR_AUTH_TOKEN;
const HOST = process.env.SONAR_HOST_URL || "https://dese-metrics.umov.me/";
const PROJECT_KEY = process.argv[2];
const ACTION = process.argv[3];

if (!TOKEN || !PROJECT_KEY || !ACTION) {
  console.error(
    "Usage: SONAR_AUTH_TOKEN=... node manage_gate.js <PROJECT_KEY> <ACTION> [--args]",
  );
  console.error(
    "Actions: inspect, create, copy, add-condition, update-condition, remove-condition, assign",
  );
  process.exit(1);
}

const BASE_URL = HOST.endsWith("/") ? HOST : HOST + "/";
const IS_HTTPS = BASE_URL.startsWith("https");
const AUTH_HEADER = {
  Authorization: "Basic " + Buffer.from(TOKEN + ":").toString("base64"),
};

// --- Arg Parser ---

function parseArgs(argv) {
  const args = {};
  let i = 4; // skip node, script, PROJECT_KEY, ACTION
  while (i < argv.length) {
    const arg = argv[i];
    if (arg.startsWith("--")) {
      const key = arg.slice(2);
      // Check if next arg is a value or another flag
      if (i + 1 < argv.length && !argv[i + 1].startsWith("--")) {
        args[key] = argv[i + 1];
        i += 2;
      } else {
        args[key] = true;
        i += 1;
      }
    } else {
      i += 1;
    }
  }
  return args;
}

const ARGS = parseArgs(process.argv);
const EXECUTE = ARGS.execute === true;
const JSON_OUTPUT = ARGS.json === true;

// --- HTTP Helpers ---

function makeGet(urlStr) {
  return new Promise((resolve, reject) => {
    const client = IS_HTTPS ? https : http;
    const req = client.get(
      urlStr,
      { headers: AUTH_HEADER, timeout: 15000 },
      (res) => {
        let data = "";
        if (res.statusCode !== 200) {
          res.resume();
          return reject(new Error(`GET ${res.statusCode}: ${urlStr}`));
        }
        res.on("data", (chunk) => (data += chunk));
        res.on("end", () => {
          try {
            resolve(JSON.parse(data));
          } catch (e) {
            reject(new Error("JSON parse error: " + e.message));
          }
        });
      },
    );
    req.on("error", (e) => reject(e));
    req.on("timeout", () => {
      req.destroy();
      reject(new Error("Request timeout"));
    });
  });
}

function makePost(urlStr, params = {}) {
  return new Promise((resolve, reject) => {
    const client = IS_HTTPS ? https : http;
    const postData = querystring.stringify(params);
    const urlObj = new URL(urlStr);

    const options = {
      hostname: urlObj.hostname,
      port: urlObj.port || (IS_HTTPS ? 443 : 80),
      path: urlObj.pathname + urlObj.search,
      method: "POST",
      timeout: 15000,
      headers: {
        ...AUTH_HEADER,
        "Content-Type": "application/x-www-form-urlencoded",
        "Content-Length": Buffer.byteLength(postData),
      },
    };

    const req = client.request(options, (res) => {
      let data = "";
      res.on("data", (chunk) => (data += chunk));
      res.on("end", () => {
        if (res.statusCode >= 400) {
          return reject(new Error(`POST ${res.statusCode}: ${data || urlStr}`));
        }
        try {
          resolve(data ? JSON.parse(data) : { status: "ok" });
        } catch (e) {
          // Some endpoints return empty body on success
          resolve({ status: "ok", raw: data });
        }
      });
    });
    req.on("error", (e) => reject(e));
    req.on("timeout", () => {
      req.destroy();
      reject(new Error("Request timeout"));
    });
    req.write(postData);
    req.end();
  });
}

// --- API Wrappers ---

function getGateByProject() {
  return makeGet(
    `${BASE_URL}api/qualitygates/get_by_project?project=${PROJECT_KEY}`,
  );
}

function showGate(nameOrId) {
  const param = nameOrId.match(/^[A-Za-z]/)
    ? `name=${encodeURIComponent(nameOrId)}`
    : `id=${nameOrId}`;
  return makeGet(`${BASE_URL}api/qualitygates/show?${param}`);
}

function listGates() {
  return makeGet(`${BASE_URL}api/qualitygates/list`);
}

function createGate(name) {
  return makePost(`${BASE_URL}api/qualitygates/create`, { name });
}

function copyGate(sourceName, newName) {
  return makePost(`${BASE_URL}api/qualitygates/copy`, {
    sourceName,
    name: newName,
  });
}

function createCondition(gateName, metric, op, error) {
  return makePost(`${BASE_URL}api/qualitygates/create_condition`, {
    gateName,
    metric,
    op,
    error,
  });
}

function updateCondition(id, params) {
  return makePost(`${BASE_URL}api/qualitygates/update_condition`, {
    id,
    ...params,
  });
}

function deleteCondition(id) {
  return makePost(`${BASE_URL}api/qualitygates/delete_condition`, { id });
}

function selectGate(projectKey, gateName) {
  return makePost(`${BASE_URL}api/qualitygates/select`, {
    projectKey,
    gateName,
  });
}

// --- Output Helpers ---

function output(data) {
  if (JSON_OUTPUT) {
    console.log(JSON.stringify(data, null, 2));
  } else {
    return data;
  }
}

function log(msg) {
  if (!JSON_OUTPUT) console.log(msg);
}

function formatOp(op) {
  switch (op) {
    case "GT":
      return ">";
    case "LT":
      return "<";
    case "EQ":
      return "=";
    case "NE":
      return "≠";
    default:
      return op;
  }
}

// --- Actions ---

async function actionInspect() {
  log(`🔍 Inspecionando Quality Gate de "${PROJECT_KEY}"...\n`);

  // 1. Get current gate
  const gateRef = await getGateByProject();
  const gateName = gateRef.qualityGate.name;
  const gateId = gateRef.qualityGate.id;

  // 2. Get gate details with conditions
  const gateDetail = await showGate(gateName);

  // 3. Try to get default gate info (optional, non-blocking)
  let defaultGate = null;
  let isUsingDefault = !!gateRef.qualityGate.default;
  try {
    const allGates = await listGates();
    const defaultGateId = allGates.default;
    if (defaultGateId && allGates.qualityGates) {
      defaultGate =
        allGates.qualityGates.find((g) => g.id === defaultGateId) || null;
      isUsingDefault = gateId === defaultGateId;
    }
  } catch (_) {
    // Non-critical, continue without default gate info
  }

  const result = {
    project: PROJECT_KEY,
    gate: {
      id: gateId,
      name: gateName,
      isDefault: isUsingDefault,
      isBuiltIn: gateDetail.isBuiltIn || false,
      conditions: gateDetail.conditions || [],
    },
    systemDefault: defaultGate
      ? { id: defaultGate.id, name: defaultGate.name }
      : null,
  };

  if (JSON_OUTPUT) {
    output(result);
    return;
  }

  // Pretty print
  log(`📋 Projeto: ${PROJECT_KEY}`);
  log(`🛡️  Gate: "${gateName}" (ID: ${gateId})`);

  if (isUsingDefault) {
    log(`⚠️  Usando o gate PADRÃO do sistema.`);
    log(
      `   Alterações neste gate afetarão TODOS os projetos que usam o padrão.`,
    );
    log(`   Recomendação: crie um gate dedicado com "create" ou "copy".`);
  } else {
    log(`✅ Gate dedicado para o projeto.`);
  }

  if (gateDetail.isBuiltIn) {
    log(`🔒 Gate built-in (não editável). Copie-o para personalizar.`);
  }

  log("");
  log(`📏 Condições (${(gateDetail.conditions || []).length}):`);

  if (!gateDetail.conditions || gateDetail.conditions.length === 0) {
    log(`   Nenhuma condição definida.`);
  } else {
    gateDetail.conditions.forEach((c) => {
      log(`   • [${c.id}] ${c.metric} ${formatOp(c.op)} ${c.error}`);
    });
  }

  if (defaultGate && !isUsingDefault) {
    log(`\n📌 Gate padrão do sistema: "${defaultGate.name}"`);
  }
}

async function actionCreate() {
  const name = ARGS.name;
  if (!name) {
    console.error(
      '❌ Argumento --name é obrigatório. Ex: --name "QG MeuProjeto"',
    );
    process.exit(1);
  }

  if (!EXECUTE) {
    log(
      `🔎 [DRY-RUN] Criará o gate "${name}" e associará ao projeto "${PROJECT_KEY}".`,
    );
    log(`   Execute novamente com --execute para aplicar.`);
    output({ action: "create", dryRun: true, name, project: PROJECT_KEY });
    return;
  }

  log(`🔨 Criando gate "${name}"...`);
  const result = await createGate(name);
  log(`✅ Gate criado: "${result.name}" (ID: ${result.id})`);

  log(`🔗 Associando ao projeto "${PROJECT_KEY}"...`);
  await selectGate(PROJECT_KEY, name);
  log(`✅ Projeto associado ao gate "${name}".`);

  output({
    action: "create",
    name,
    id: result.id,
    project: PROJECT_KEY,
    status: "ok",
  });
}

async function actionCopy() {
  const source = ARGS.source;
  const name = ARGS.name;
  if (!source || !name) {
    console.error("❌ Argumentos --source e --name são obrigatórios.");
    console.error('   Ex: --source "QG Origem" --name "QG Novo"');
    process.exit(1);
  }

  if (!EXECUTE) {
    log(
      `🔎 [DRY-RUN] Copiará gate "${source}" → "${name}" e associará ao projeto "${PROJECT_KEY}".`,
    );
    log(`   Execute novamente com --execute para aplicar.`);
    output({
      action: "copy",
      dryRun: true,
      source,
      name,
      project: PROJECT_KEY,
    });
    return;
  }

  log(`📋 Copiando gate "${source}" → "${name}"...`);
  const result = await copyGate(source, name);
  log(`✅ Gate copiado: "${result.name}" (ID: ${result.id})`);

  log(`🔗 Associando ao projeto "${PROJECT_KEY}"...`);
  await selectGate(PROJECT_KEY, name);
  log(`✅ Projeto associado ao gate "${name}".`);

  output({
    action: "copy",
    name,
    id: result.id,
    source,
    project: PROJECT_KEY,
    status: "ok",
  });
}

async function actionAddCondition() {
  const { metric, op, error } = ARGS;
  if (!metric || !error) {
    console.error("❌ Argumentos --metric e --error são obrigatórios.");
    console.error("   Ex: --metric coverage --op LT --error 80");
    console.error("   Operadores: LT (<), GT (>)");
    process.exit(1);
  }
  const operator = op || "LT";

  // Get current gate
  const gateRef = await getGateByProject();
  const gateName = gateRef.qualityGate.name;

  if (!EXECUTE) {
    log(`🔎 [DRY-RUN] Adicionará condição ao gate "${gateName}":`);
    log(`   ${metric} ${formatOp(operator)} ${error}`);
    log(`   Execute novamente com --execute para aplicar.`);
    output({
      action: "add-condition",
      dryRun: true,
      gate: gateName,
      metric,
      op: operator,
      error,
    });
    return;
  }

  log(
    `➕ Adicionando condição ao gate "${gateName}": ${metric} ${formatOp(operator)} ${error}`,
  );
  const result = await createCondition(gateName, metric, operator, error);
  log(`✅ Condição criada (ID: ${result.id}).`);

  output({
    action: "add-condition",
    gate: gateName,
    conditionId: result.id,
    metric,
    op: operator,
    error,
    status: "ok",
  });
}

async function actionUpdateCondition() {
  const id = ARGS.id;
  if (!id) {
    console.error("❌ Argumento --id é obrigatório (ID da condição).");
    console.error("   Use 'inspect' para ver os IDs das condições.");
    process.exit(1);
  }

  const params = {};
  if (ARGS.metric) params.metric = ARGS.metric;
  if (ARGS.op) params.op = ARGS.op;
  if (ARGS.error) params.error = ARGS.error;

  if (Object.keys(params).length === 0) {
    console.error(
      "❌ Forneça ao menos um campo para atualizar: --metric, --op, --error",
    );
    process.exit(1);
  }

  // We need the current condition details to send the full update
  const gateRef = await getGateByProject();
  const gateDetail = await showGate(gateRef.qualityGate.name);
  const condition = (gateDetail.conditions || []).find((c) => c.id === id);

  if (!condition) {
    console.error(
      `❌ Condição "${id}" não encontrada no gate "${gateRef.qualityGate.name}".`,
    );
    process.exit(1);
  }

  // Merge current values with updates
  const merged = {
    metric: params.metric || condition.metric,
    op: params.op || condition.op,
    error: params.error || condition.error,
  };

  if (!EXECUTE) {
    log(
      `🔎 [DRY-RUN] Atualizará condição ${id} no gate "${gateRef.qualityGate.name}":`,
    );
    log(
      `   Antes: ${condition.metric} ${formatOp(condition.op)} ${condition.error}`,
    );
    log(`   Depois: ${merged.metric} ${formatOp(merged.op)} ${merged.error}`);
    log(`   Execute novamente com --execute para aplicar.`);
    output({
      action: "update-condition",
      dryRun: true,
      id,
      before: condition,
      after: merged,
    });
    return;
  }

  log(`✏️  Atualizando condição ${id}...`);
  log(
    `   Antes: ${condition.metric} ${formatOp(condition.op)} ${condition.error}`,
  );
  log(`   Depois: ${merged.metric} ${formatOp(merged.op)} ${merged.error}`);
  await updateCondition(id, merged);
  log(`✅ Condição atualizada.`);

  output({
    action: "update-condition",
    id,
    before: condition,
    after: merged,
    status: "ok",
  });
}

async function actionRemoveCondition() {
  const id = ARGS.id;
  if (!id) {
    console.error("❌ Argumento --id é obrigatório (ID da condição).");
    console.error("   Use 'inspect' para ver os IDs das condições.");
    process.exit(1);
  }

  // Find the condition for display
  const gateRef = await getGateByProject();
  const gateDetail = await showGate(gateRef.qualityGate.name);
  const condition = (gateDetail.conditions || []).find((c) => c.id === id);

  if (!EXECUTE) {
    const desc = condition
      ? `${condition.metric} ${formatOp(condition.op)} ${condition.error}`
      : `ID: ${id}`;
    log(
      `🔎 [DRY-RUN] Removerá condição do gate "${gateRef.qualityGate.name}":`,
    );
    log(`   ${desc}`);
    log(`   Execute novamente com --execute para aplicar.`);
    output({
      action: "remove-condition",
      dryRun: true,
      id,
      condition: condition || null,
    });
    return;
  }

  log(`🗑️  Removendo condição ${id}...`);
  await deleteCondition(id);
  log(`✅ Condição removida.`);

  output({ action: "remove-condition", id, status: "ok" });
}

async function actionAssign() {
  const gate = ARGS.gate;
  if (!gate) {
    console.error("❌ Argumento --gate é obrigatório.");
    console.error('   Ex: --gate "QG MeuProjeto"');
    process.exit(1);
  }

  if (!EXECUTE) {
    log(`🔎 [DRY-RUN] Associará o projeto "${PROJECT_KEY}" ao gate "${gate}".`);
    log(`   Execute novamente com --execute para aplicar.`);
    output({ action: "assign", dryRun: true, project: PROJECT_KEY, gate });
    return;
  }

  log(`🔗 Associando projeto "${PROJECT_KEY}" ao gate "${gate}"...`);
  await selectGate(PROJECT_KEY, gate);
  log(`✅ Projeto associado.`);

  output({ action: "assign", project: PROJECT_KEY, gate, status: "ok" });
}

// --- Main ---

async function main() {
  try {
    switch (ACTION) {
      case "inspect":
        await actionInspect();
        break;
      case "create":
        await actionCreate();
        break;
      case "copy":
        await actionCopy();
        break;
      case "add-condition":
        await actionAddCondition();
        break;
      case "update-condition":
        await actionUpdateCondition();
        break;
      case "remove-condition":
        await actionRemoveCondition();
        break;
      case "assign":
        await actionAssign();
        break;
      default:
        console.error(`❌ Ação desconhecida: "${ACTION}"`);
        console.error(
          "   Ações: inspect, create, copy, add-condition, update-condition, remove-condition, assign",
        );
        process.exit(1);
    }
  } catch (err) {
    console.error(`❌ Erro: ${err.message}`);
    if (JSON_OUTPUT) {
      console.log(JSON.stringify({ error: err.message }));
    }
    process.exit(1);
  }
}

main();
