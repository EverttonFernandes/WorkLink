const https = require("https");
const fs = require("fs");
const path = require("path");

// Configuration
const TOKEN = process.env.SONAR_AUTH_TOKEN;
const HOST = process.env.SONAR_HOST_URL || "https://dese-metrics.umov.me/";
const PROJECT_KEY = process.argv[2];
const MODE = process.argv[3] || "new-coverage"; // status, new-coverage, coverage, duplication, issues, report

// Report Configuration
const REPORT_DIR = path.join(".agent", "reports");
const REPORT_FILE = path.join(REPORT_DIR, "quality-report.md");

if (!TOKEN || !PROJECT_KEY) {
  console.error(
    "Usage: SONAR_AUTH_TOKEN=... node diagnose.js <PROJECT_KEY> [MODE]",
  );
  process.exit(1);
}

const BASE_URL = HOST.endsWith("/") ? HOST : HOST + "/";
const AUTH_HEADER = {
  Authorization: "Basic " + Buffer.from(TOKEN + ":").toString("base64"),
};

async function main() {
  try {
    switch (MODE) {
      case "status":
        processStatus(await fetchStatus());
        break;
      case "new-coverage":
        processNewCoverage(
          await fetchMeasures("new_coverage,new_lines", "new_coverage", true),
        );
        break;
      case "coverage":
        processOverallCoverage(
          await fetchMeasures("coverage,uncovered_lines", "coverage", true),
        );
        break;
      case "duplication":
        processDuplication(
          await fetchMeasures(
            "duplicated_lines_density",
            "duplicated_lines_density",
            false,
          ),
        );
        break;
      case "issues":
        processIssues(await fetchIssues());
        break;
      case "report":
        await generateReport();
        break;
      default:
        console.error(`Unknown mode: ${MODE}`);
        process.exit(1);
    }
  } catch (err) {
    console.error("Execution failed:", err.message);
    process.exit(1);
  }
}

// --- API Helpers (Promisified) ---

function makeRequest(url) {
  return new Promise((resolve, reject) => {
    https
      .get(url, { headers: AUTH_HEADER }, (res) => {
        let data = "";
        if (res.statusCode !== 200) {
          res.resume();
          return reject(
            new Error(`API returned status ${res.statusCode} for ${url}`),
          );
        }
        res.on("data", (chunk) => {
          data += chunk;
        });
        res.on("end", () => {
          try {
            resolve(JSON.parse(data));
          } catch (e) {
            reject(new Error("Error parsing JSON: " + e.message));
          }
        });
      })
      .on("error", (e) => reject(e));
  });
}

async function fetchStatus() {
  return makeRequest(
    `${BASE_URL}api/qualitygates/project_status?projectKey=${PROJECT_KEY}`,
  );
}

async function fetchMeasures(metricKeys, sortKey, asc) {
  return makeRequest(
    `${BASE_URL}api/measures/component_tree?component=${PROJECT_KEY}&metricKeys=${metricKeys}&ps=100&s=metric&metricSort=${sortKey}&asc=${asc}&qualifiers=FIL`,
  );
}

async function fetchIssues() {
  return makeRequest(
    `${BASE_URL}api/issues/search?componentKeys=${PROJECT_KEY}&types=CODE_SMELL,BUG,VULNERABILITY&resolved=false&ps=10&s=FILE_LINE&asc=true`,
  );
}

async function fetchNewIssues() {
  return makeRequest(
    `${BASE_URL}api/issues/search?componentKeys=${PROJECT_KEY}&types=CODE_SMELL,BUG,VULNERABILITY&resolved=false&inNewCodePeriod=true&ps=100&s=FILE_LINE&asc=true`,
  );
}

// --- Processors (Console Output) ---

function processStatus(json) {
  const status = json.projectStatus.status;
  const conditions = json.projectStatus.conditions || [];

  if (status === "OK") {
    console.log("✅ Quality Gate Passed.");
    return;
  }

  console.log(`❌ Quality Gate: ${status}`);
  console.log("Conditions:");
  conditions.forEach((c) => {
    const icon = c.status === "OK" ? "✅" : "❌";
    console.log(
      `   ${icon} ${c.metricKey}: ${c.actualValue} (Threshold: ${c.comparator} ${c.errorThreshold})`,
    );
  });
}

function processNewCoverage(json) {
  const offenders = getNewCoverageOffenders(json);
  if (offenders.length === 0) {
    console.log("✅ No 'New Code' coverage issues found.");
  } else {
    console.log("🚨 Files causing Quality Gate failure on New Code:");
    offenders.forEach((f) =>
      console.log(
        `   📄 ${f.path}\n      New Lines: ${f.newLines} | Coverage: ${f.newCoverage}%`,
      ),
    );
  }
}

function processOverallCoverage(json) {
  if (!json.components) return;
  console.log("📉 Top 5 Files with Low Coverage:");
  json.components.slice(0, 5).forEach((c) => {
    const cov = getMetric(c, "coverage")?.value || "N/A";
    const uncovered = getMetric(c, "uncovered_lines")?.value || "0";
    console.log(`   📄 ${c.path} (Cov: ${cov}%, Uncovered: ${uncovered})`);
  });
}

function processDuplication(json) {
  if (!json.components) return;
  console.log("👯 Top 5 Duplicated Files:");
  json.components.slice(0, 5).forEach((c) => {
    const dup = getMetric(c, "duplicated_lines_density")?.value || "0";
    console.log(`   📄 ${c.path} (Duplication: ${dup}%)`);
  });
}

function processIssues(json) {
  if (!json.issues || json.issues.length === 0) {
    console.log("✅ No unresolved issues found.");
    return;
  }
  console.log("🐛 Top Unresolved Issues (Code Smells/Bugs):");
  json.issues.slice(0, 10).forEach((issue) => {
    const file = issue.component.split(":").pop();
    console.log(`   [${issue.severity}] ${issue.message}`);
    console.log(`      📍 ${file}:${issue.line} (${issue.rule})`);
  });
}

// --- Report Generation ---

async function generateReport() {
  const [statusJson, coverageJson, issuesJson, newIssuesJson] =
    await Promise.all([
      fetchStatus(),
      fetchMeasures("new_coverage,new_lines", "new_coverage", true),
      fetchIssues(),
      fetchNewIssues(),
    ]);

  const date = new Date().toLocaleString();
  const status = statusJson.projectStatus.status;
  const statusIcon = status === "OK" ? "✅" : "❌";
  const conditions = statusJson.projectStatus.conditions || [];
  const blockers = conditions.filter((c) => c.status === "ERROR");
  const coverageOffenders = getNewCoverageOffenders(coverageJson);
  const topIssues = issuesJson.issues ? issuesJson.issues.slice(0, 10) : [];

  let md = `# 🛡️ Relatório de Qualidade de Código\n`;
  md += `**Data**: ${date}\n`;
  md += `**Status**: ${statusIcon} ${status}\n\n`;

  md += `## 🚨 Bloqueadores (Quality Gate)\n`;
  if (blockers.length === 0) {
    md += `_Nenhum bloqueador crítico._\n\n`;
  } else {
    md += `| Métrica | Limite | Atual | Status |\n`;
    md += `|:---|:---|:---|:---|\n`;
    blockers.forEach((c) => {
      md += `| \`${c.metricKey}\` | ${c.comparator} ${c.errorThreshold} | **${c.actualValue}** | ❌ |\n`;
    });
    md += `\n`;
  }

  md += `## 🎯 Ações Necessárias (New Code)\n`;
  if (coverageOffenders.length === 0) {
    md += `_Nenhuma ação necessária em Código Novo._\n\n`;
  } else {
    md += `Arquivos que precisam de testes para liberar o PR:\n`;
    coverageOffenders.forEach((f) => {
      md += `- [ ] \`${f.path}\` (Linhas: ${f.newLines} | Cobertura: ${f.newCoverage}%)\n`;
    });
    md += `\n`;
  }

  md += `## 🆕 Novos Code Smells (Bloqueante)\n`;
  if (!newIssuesJson.issues || newIssuesJson.issues.length === 0) {
    md += `_Nenhum novo code smell introduzido._\n\n`;
  } else {
    md += `*Issues criadas neste código (Devem ser corrigidas):*\n`;
    newIssuesJson.issues.forEach((i) => {
      const file = i.component.split(":").pop();
      md += `- [ ] **${i.severity}**: ${i.message} em \`${file}:${i.line}\`\n`;
    });
    md += `\n`;
  }

  md += `## 🐛 Top Ofensores (Tech Debt)\n`;
  if (topIssues.length === 0) {
    md += `_Parabéns! Nenhum issue crítico encontrado._\n\n`;
  } else {
    md += `*Principais problemas encontrados (Top 10):*\n`;
    topIssues.forEach((i) => {
      const file = i.component.split(":").pop();
      md += `1. **${i.severity}**: ${i.message} en \`${file}:${i.line}\`\n`;
    });
  }

  if (!fs.existsSync(REPORT_DIR)) {
    fs.mkdirSync(REPORT_DIR, { recursive: true });
  }
  fs.writeFileSync(REPORT_FILE, md);
  console.log(`✅ Report generated: ${REPORT_FILE}`);

  // Also print a summary to console
  console.log(`\n--- Summary ---\nStatus: ${statusIcon} ${status}`);
  if (blockers.length > 0) console.log(`Blockers: ${blockers.length}`);
  if (coverageOffenders.length > 0)
    console.log(`Files to Fix: ${coverageOffenders.length}`);
}

// --- Utils ---

function getMetric(comp, key) {
  if (!comp.measures) return null;
  return comp.measures.find((m) => m.metric === key);
}

function getNewCoverageOffenders(json) {
  if (!json.components) return [];
  return json.components
    .map((comp) => {
      const newLines = getMetric(comp, "new_lines")?.period?.value || "0";
      const newCoverage =
        getMetric(comp, "new_coverage")?.period?.value || "N/A";
      return { path: comp.path, newLines: parseInt(newLines, 10), newCoverage };
    })
    .filter((i) => i.newLines > 0)
    .filter((i) => i.newCoverage === "N/A" || parseFloat(i.newCoverage) < 80.0);
}

main();
