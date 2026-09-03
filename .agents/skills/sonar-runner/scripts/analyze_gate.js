#!/usr/bin/env node

/**
 * analyze_gate.js — Análise remota de Quality Gate do SonarQube.
 *
 * Analisa um projeto pelo PROJECT_KEY, identifica condições falhadas,
 * mapeia para dados de arquivo e gera relatório acionável.
 *
 * Uso:
 *   SONAR_AUTH_TOKEN=... node analyze_gate.js <PROJECT_KEY>
 *
 * Saída: .agent/reports/gate-analysis.md
 */

const http = require("http");
const https = require("https");
const fs = require("fs");
const path = require("path");

// --- Configuration ---
const TOKEN = process.env.SONAR_AUTH_TOKEN;
const HOST = process.env.SONAR_HOST_URL || "https://dese-metrics.umov.me/";
const PROJECT_KEY = process.argv[2];

const REPORT_DIR = path.join(".agent", "reports");
const REPORT_FILE = path.join(REPORT_DIR, "gate-analysis.md");

if (!TOKEN || !PROJECT_KEY) {
  console.error(
    "Usage: SONAR_AUTH_TOKEN=... node analyze_gate.js <PROJECT_KEY>",
  );
  console.error(
    "  Env: SONAR_HOST_URL (default: https://dese-metrics.umov.me/)",
  );
  process.exit(1);
}

const BASE_URL = HOST.endsWith("/") ? HOST : HOST + "/";
const IS_HTTPS = BASE_URL.startsWith("https");
const AUTH_HEADER = {
  Authorization: "Basic " + Buffer.from(TOKEN + ":").toString("base64"),
};

// --- HTTP Helper ---

function makeRequest(urlStr) {
  return new Promise((resolve, reject) => {
    const client = IS_HTTPS ? https : http;
    const req = client.get(
      urlStr,
      { headers: AUTH_HEADER, timeout: 15000 },
      (res) => {
        let data = "";
        if (res.statusCode !== 200) {
          res.resume();
          return reject(
            new Error(`API returned status ${res.statusCode} for ${urlStr}`),
          );
        }
        res.on("data", (chunk) => (data += chunk));
        res.on("end", () => {
          try {
            resolve(JSON.parse(data));
          } catch (e) {
            reject(new Error("Error parsing JSON: " + e.message));
          }
        });
      },
    );
    req.on("error", (e) => reject(e));
    req.on("timeout", () => {
      req.destroy();
      reject(new Error(`Request timeout for ${urlStr}`));
    });
  });
}

// --- API Fetchers ---

function fetchQualityGateStatus() {
  return makeRequest(
    `${BASE_URL}api/qualitygates/project_status?projectKey=${PROJECT_KEY}`,
  );
}

function fetchProjectMeasures(metricKeys) {
  return makeRequest(
    `${BASE_URL}api/measures/component?component=${PROJECT_KEY}&metricKeys=${metricKeys}`,
  );
}

function fetchFileMeasures(metricKeys, sortMetric, asc = true, pageSize = 15) {
  return makeRequest(
    `${BASE_URL}api/measures/component_tree?component=${PROJECT_KEY}` +
      `&metricKeys=${metricKeys}&ps=${pageSize}&s=metric&metricSort=${sortMetric}` +
      `&asc=${asc}&qualifiers=FIL&metricSortFilter=withMeasuresOnly`,
  );
}

function fetchIssues(types, pageSize = 15, newCodeOnly = false) {
  const params = [
    `componentKeys=${PROJECT_KEY}`,
    `types=${types}`,
    `resolved=false`,
    `ps=${pageSize}`,
    `s=SEVERITY`,
    `asc=true`,
  ];
  if (newCodeOnly) params.push("inNewCodePeriod=true");
  return makeRequest(`${BASE_URL}api/issues/search?${params.join("&")}`);
}

// --- Metric Key Mapping ---

/**
 * Maps a Quality Gate condition metric to the data-fetching strategy.
 * Returns { kind, fetch() } where kind is 'coverage', 'issues', or 'duplication'.
 */
function strategyForCondition(metricKey) {
  const isNewCode = metricKey.startsWith("new_");
  const baseKey = isNewCode ? metricKey.replace(/^new_/, "") : metricKey;

  switch (baseKey) {
    case "branch_coverage":
      return {
        kind: "coverage",
        label: "Branch Coverage",
        metric: "branch_coverage",
        detailMetrics:
          "branch_coverage,conditions_to_cover,uncovered_conditions",
        sortMetric: "branch_coverage",
        isNewCode,
      };
    case "coverage":
    case "line_coverage":
      return {
        kind: "coverage",
        label: "Line Coverage",
        metric: "coverage",
        detailMetrics: "coverage,ncloc,uncovered_lines",
        sortMetric: "coverage",
        isNewCode,
      };
    case "bugs":
    case "reliability_rating":
      return {
        kind: "issues",
        label: "Bugs",
        issueType: "BUG",
        isNewCode,
      };
    case "vulnerabilities":
    case "security_rating":
      return {
        kind: "issues",
        label: "Vulnerabilities",
        issueType: "VULNERABILITY",
        isNewCode,
      };
    case "code_smells":
    case "sqale_rating":
      return {
        kind: "issues",
        label: "Code Smells",
        issueType: "CODE_SMELL",
        isNewCode,
      };
    case "duplicated_lines_density":
      return {
        kind: "duplication",
        label: "Duplications",
        detailMetrics:
          "duplicated_lines_density,duplicated_blocks,duplicated_lines",
        sortMetric: "duplicated_lines_density",
        isNewCode,
      };
    case "security_hotspots_reviewed":
    case "security_review_rating":
      return {
        kind: "info",
        label: "Security Hotspots",
        isNewCode,
      };
    default:
      return { kind: "unknown", label: metricKey, isNewCode };
  }
}

// --- Utils ---

function getMetric(comp, key) {
  if (!comp || !comp.measures) return null;
  return comp.measures.find((m) => m.metric === key);
}

function getMetricValue(comp, key) {
  const m = getMetric(comp, key);
  if (!m) return null;
  // New Code period metrics use m.period.value
  if (m.period && m.period.value !== undefined) return m.period.value;
  return m.value;
}

function comparatorSymbol(comparator) {
  switch (comparator) {
    case "GT":
      return ">";
    case "LT":
      return "<";
    case "EQ":
      return "=";
    case "NE":
      return "≠";
    default:
      return comparator;
  }
}

function comparatorLabel(comparator) {
  switch (comparator) {
    case "GT":
      return "máximo";
    case "LT":
      return "mínimo";
    default:
      return comparator;
  }
}

function formatPercent(val) {
  if (val === null || val === undefined || val === "N/A") return "N/A";
  return parseFloat(val).toFixed(1) + "%";
}

// --- Analysis Core ---

async function analyzeCoverageCondition(condition, strategy) {
  const data = await fetchFileMeasures(
    strategy.detailMetrics,
    strategy.sortMetric,
    true,
    20,
  );

  if (!data.components || data.components.length === 0) {
    return { files: [], totalFiles: 0 };
  }

  const threshold = parseFloat(condition.errorThreshold);
  const actual = parseFloat(condition.actualValue);
  const gap = threshold - actual;

  const files = data.components.map((comp) => {
    const coverageVal = getMetricValue(comp, strategy.metric);
    const coverage = coverageVal !== null ? parseFloat(coverageVal) : null;

    let uncoveredKey, totalKey;
    if (strategy.metric === "branch_coverage") {
      uncoveredKey = "uncovered_conditions";
      totalKey = "conditions_to_cover";
    } else {
      uncoveredKey = "uncovered_lines";
      totalKey = "ncloc";
    }

    const uncovered = parseInt(getMetricValue(comp, uncoveredKey) || "0", 10);
    const total = parseInt(getMetricValue(comp, totalKey) || "0", 10);

    return {
      path: comp.path,
      coverage,
      uncovered,
      total,
    };
  });

  return { files, totalFiles: data.paging.total, gap, threshold, actual };
}

async function analyzeIssuesCondition(condition, strategy) {
  const data = await fetchIssues(strategy.issueType, 20, strategy.isNewCode);

  if (!data.issues || data.issues.length === 0) {
    return { issues: [], total: 0 };
  }

  const issues = data.issues.map((i) => ({
    severity: i.severity,
    message: i.message,
    file: i.component.split(":").pop(),
    line: i.line,
    rule: i.rule,
    effort: i.effort || "N/A",
    type: i.type,
  }));

  return { issues, total: data.total };
}

async function analyzeDuplicationCondition(condition, strategy) {
  const data = await fetchFileMeasures(
    strategy.detailMetrics,
    strategy.sortMetric,
    false,
    15,
  );

  if (!data.components || data.components.length === 0) {
    return { files: [], totalFiles: 0 };
  }

  const files = data.components
    .filter(
      (c) =>
        parseFloat(getMetricValue(c, "duplicated_lines_density") || "0") > 0,
    )
    .map((comp) => ({
      path: comp.path,
      density: parseFloat(
        getMetricValue(comp, "duplicated_lines_density") || "0",
      ),
      blocks: parseInt(getMetricValue(comp, "duplicated_blocks") || "0", 10),
      lines: parseInt(getMetricValue(comp, "duplicated_lines") || "0", 10),
    }));

  return { files, totalFiles: data.paging.total };
}

// --- Report Generation ---

function generateDashboardSection(status, conditions, period) {
  let md = "";

  const statusIcon = status === "OK" ? "✅" : "❌";
  md += `## Status: ${statusIcon} ${status === "OK" ? "PASSED" : "FAILED"}\n\n`;

  if (period) {
    md += `**Período de New Code**: desde \`${period.parameter || "N/A"}\` (${period.mode})\n\n`;
  }

  if (conditions.length === 0) {
    md += `_Nenhuma condição avaliada._\n\n`;
    return md;
  }

  md += `### Condições do Quality Gate\n\n`;
  md += `| Condição | Valor Atual | Threshold | Status |\n`;
  md += `|:---|:---:|:---:|:---:|\n`;

  conditions.forEach((c) => {
    const icon = c.status === "OK" ? "✅" : "❌";
    const scope = c.periodIndex ? " _(New Code)_" : "";
    const formattedValue = isNaN(parseFloat(c.actualValue))
      ? c.actualValue
      : parseFloat(c.actualValue).toFixed(1);
    md += `| \`${c.metricKey}\`${scope} | **${formattedValue}** | ${comparatorSymbol(c.comparator)} ${c.errorThreshold} | ${icon} |\n`;
  });

  md += `\n`;
  return md;
}

function generateCoverageSection(condition, strategy, analysis) {
  let md = "";
  const scope = strategy.isNewCode ? " (New Code)" : " (Overall)";
  md += `### 📉 ${strategy.label}${scope}\n\n`;

  md += `**Situação**: ${formatPercent(condition.actualValue)} atual → ${comparatorLabel(condition.comparator)} ${formatPercent(condition.errorThreshold)} exigido`;
  md += ` (**gap de ${analysis.gap.toFixed(1)}pp**)\n\n`;

  if (analysis.files.length === 0) {
    md += `_Nenhum arquivo com dados de cobertura encontrado._\n\n`;
    return md;
  }

  md += `**Top ${Math.min(analysis.files.length, 15)} arquivos com menor cobertura** (de ${analysis.totalFiles} total):\n\n`;
  md += `| Arquivo | Coverage | Não Cobertos | Total |\n`;
  md += `|:---|:---:|:---:|:---:|\n`;

  analysis.files.slice(0, 15).forEach((f) => {
    md += `| \`${f.path}\` | ${formatPercent(f.coverage)} | ${f.uncovered} | ${f.total} |\n`;
  });

  md += `\n`;

  // Action plan
  md += `**🎯 Plano de Ação**:\n\n`;
  md += `_Priorize pelos arquivos com mais condições não cobertas (maior impacto no % global):_\n\n`;

  const sortedByImpact = [...analysis.files]
    .filter((f) => f.uncovered > 0)
    .sort((a, b) => b.uncovered - a.uncovered);

  sortedByImpact.slice(0, 10).forEach((f) => {
    md += `- [ ] \`${f.path}\` — **${f.uncovered}** branches/linhas não cobertas (coverage: ${formatPercent(f.coverage)})\n`;
  });

  md += `\n`;
  return md;
}

function generateIssuesSection(condition, strategy, analysis) {
  let md = "";
  const scope = strategy.isNewCode ? " (New Code)" : "";
  md += `### 🐛 ${strategy.label}${scope}\n\n`;

  md += `**Total**: ${analysis.total} issue(s) não resolvida(s)\n\n`;

  if (analysis.issues.length === 0) {
    md += `_Nenhuma issue encontrada._\n\n`;
    return md;
  }

  md += `| Severidade | Mensagem | Arquivo | Regra |\n`;
  md += `|:---:|:---|:---|:---|\n`;

  analysis.issues.forEach((i) => {
    const sevIcon =
      i.severity === "BLOCKER" || i.severity === "CRITICAL"
        ? "🔴"
        : i.severity === "MAJOR"
          ? "🟠"
          : "🟡";
    md += `| ${sevIcon} ${i.severity} | ${i.message} | \`${i.file}:${i.line || "?"}\` | \`${i.rule}\` |\n`;
  });

  md += `\n`;

  md += `**🎯 Plano de Ação**:\n\n`;
  analysis.issues.forEach((i) => {
    md += `- [ ] **${i.severity}**: ${i.message} em \`${i.file}:${i.line || "?"}\`\n`;
  });
  md += `\n`;

  return md;
}

function generateDuplicationSection(condition, strategy, analysis) {
  let md = "";
  md += `### 👯 ${strategy.label}\n\n`;

  if (analysis.files.length === 0) {
    md += `_Nenhum arquivo com duplicação encontrado._\n\n`;
    return md;
  }

  md += `| Arquivo | Duplicação | Blocos | Linhas |\n`;
  md += `|:---|:---:|:---:|:---:|\n`;

  analysis.files.forEach((f) => {
    md += `| \`${f.path}\` | ${f.density.toFixed(1)}% | ${f.blocks} | ${f.lines} |\n`;
  });

  md += `\n`;

  md += `**🎯 Plano de Ação**:\n\n`;
  analysis.files.forEach((f) => {
    md += `- [ ] Refatorar \`${f.path}\` — ${f.blocks} bloco(s) duplicado(s), ${f.lines} linhas\n`;
  });
  md += `\n`;

  return md;
}

// --- Main ---

async function main() {
  console.log(`🔍 Analisando Quality Gate de "${PROJECT_KEY}"...`);

  // 1. Fetch Quality Gate status
  const gateData = await fetchQualityGateStatus();
  const {
    status,
    conditions = [],
    period,
    periods = [],
  } = gateData.projectStatus;
  const activePeriod = period || (periods.length > 0 ? periods[0] : null);

  // 2. Fetch project-level overview metrics
  const overviewData = await fetchProjectMeasures(
    "ncloc,bugs,vulnerabilities,code_smells,coverage,branch_coverage,duplicated_lines_density",
  );
  const projectMeasures = overviewData.component?.measures || [];

  // 3. Start report
  const date = new Date().toISOString().replace("T", " ").slice(0, 19);
  let md = `# 🔍 Análise de Quality Gate — \`${PROJECT_KEY}\`\n\n`;
  md += `**Data**: ${date}\n`;
  md += `**Host**: ${BASE_URL}\n\n`;

  // 4. Project overview
  md += `## 📊 Visão Geral do Projeto\n\n`;
  md += `| Métrica | Valor |\n`;
  md += `|:---|:---:|\n`;
  projectMeasures.forEach((m) => {
    const label =
      {
        ncloc: "Linhas de Código",
        bugs: "Bugs",
        vulnerabilities: "Vulnerabilidades",
        code_smells: "Code Smells",
        coverage: "Line Coverage",
        branch_coverage: "Branch Coverage",
        duplicated_lines_density: "Duplicação",
      }[m.metric] || m.metric;

    let val = m.value;
    if (m.metric.includes("coverage") || m.metric.includes("duplicated")) {
      val = formatPercent(val);
    }
    md += `| ${label} | **${val}** |\n`;
  });
  md += `\n`;

  // 5. Quality Gate dashboard
  md += generateDashboardSection(status, conditions, activePeriod);

  // 6. If PASSED, short-circuit
  if (status === "OK") {
    md += `> ✅ **Quality Gate aprovado!** Nenhuma ação necessária.\n`;
    writeReport(md);
    console.log("✅ Quality Gate OK — sem ações necessárias.");
    return;
  }

  // 7. Analyze each failing condition
  const failedConditions = conditions.filter((c) => c.status === "ERROR");
  md += `## 🚧 Análise das Condições Falhadas\n\n`;
  md += `_${failedConditions.length} condição(ões) requer(em) atenção:_\n\n`;

  for (const condition of failedConditions) {
    const strategy = strategyForCondition(condition.metricKey);

    try {
      switch (strategy.kind) {
        case "coverage": {
          const analysis = await analyzeCoverageCondition(condition, strategy);
          md += generateCoverageSection(condition, strategy, analysis);
          break;
        }
        case "issues": {
          const analysis = await analyzeIssuesCondition(condition, strategy);
          md += generateIssuesSection(condition, strategy, analysis);
          break;
        }
        case "duplication": {
          const analysis = await analyzeDuplicationCondition(
            condition,
            strategy,
          );
          md += generateDuplicationSection(condition, strategy, analysis);
          break;
        }
        case "info":
          md += `### ℹ️ ${strategy.label}\n\n`;
          md += `_Métrica informativa (${condition.metricKey}): ${condition.actualValue} (threshold: ${condition.comparator} ${condition.errorThreshold})._\n`;
          md += `_Verifique Security Hotspots manualmente no dashboard._\n\n`;
          break;
        default:
          md += `### ❓ ${strategy.label}\n\n`;
          md += `_Métrica não mapeada: \`${condition.metricKey}\` = ${condition.actualValue} (threshold: ${condition.comparator} ${condition.errorThreshold})._\n\n`;
      }
    } catch (err) {
      md += `### ⚠️ Erro ao analisar \`${condition.metricKey}\`\n\n`;
      md += `_${err.message}_\n\n`;
    }
  }

  // 8. Summary
  md += `---\n\n`;
  md += `## 📋 Resumo do Plano de Ação\n\n`;
  md += `> Para liberar o Quality Gate, foque nas **${failedConditions.length} condição(ões) falhada(s)** acima.\n`;
  md += `> Os arquivos estão ordenados por impacto — corrigir os primeiros da lista terá o maior efeito no percentual global.\n`;

  writeReport(md);
}

function writeReport(md) {
  if (!fs.existsSync(REPORT_DIR)) {
    fs.mkdirSync(REPORT_DIR, { recursive: true });
  }
  fs.writeFileSync(REPORT_FILE, md);
  console.log(`✅ Relatório gerado: ${REPORT_FILE}`);
}

main().catch((err) => {
  console.error("❌ Erro na análise:", err.message);
  process.exit(1);
});
