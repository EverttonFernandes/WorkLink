#!/usr/bin/env sh
set -eu

TASK_KEY="${1:-${TASK_KEY:-}}"
TASKS_DIR="${WORKLINK_TASKS_DIR:-docs/tasks}"

if [ -z "${TASK_KEY}" ]; then
  echo "Informe TASK_KEY. Exemplo: make mobile-visual-qa-gate TASK_KEY=WLT-034" >&2
  exit 1
fi

VISUAL_QA_DIR="${TASKS_DIR}/${TASK_KEY}/visual-qa"
MATRIX_FILE="${VISUAL_QA_DIR}/MOBILE_VISUAL_QA_MATRIX.md"
SPECIALIST_REVIEW_FILE="${VISUAL_QA_DIR}/MOBILE_FRONTEND_SPECIALIST_REVIEW.md"
SCREENSHOTS_DIR="${VISUAL_QA_DIR}/screenshots"

require_file() {
  if [ ! -s "$1" ]; then
    echo "Evidencia obrigatoria ausente ou vazia: $1" >&2
    exit 1
  fi
}

require_pattern() {
  file="$1"
  pattern="$2"
  description="$3"

  if ! grep -Eiq "$pattern" "$file"; then
    echo "Evidencia invalida em ${file}: ${description}" >&2
    exit 1
  fi
}

require_file "${MATRIX_FILE}"
require_file "${SPECIALIST_REVIEW_FILE}"

if [ ! -d "${SCREENSHOTS_DIR}" ]; then
  echo "Diretorio de screenshots obrigatorio ausente: ${SCREENSHOTS_DIR}" >&2
  exit 1
fi

if ! find "${SCREENSHOTS_DIR}" -type f \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' \) -size +0c | grep -q .; then
  echo "Nenhum screenshot real encontrado em ${SCREENSHOTS_DIR}." >&2
  exit 1
fi

require_pattern "${MATRIX_FILE}" 'Visual QA Verdict:[[:space:]]*PASS' 'inclua "Visual QA Verdict: PASS".'
require_pattern "${MATRIX_FILE}" 'Artifact class:[[:space:]]*(technical-build|preview|functional-homologation|release-candidate)' 'declare uma classe oficial de artifact.'
require_pattern "${MATRIX_FILE}" 'docs/prototipos-de-tela/|MAPA-PROTOTIPOS-TELAS.md' 'cite o prototipo oficial ou mapa de prototipos comparado.'
require_pattern "${MATRIX_FILE}" 'screenshots/' 'referencie pelo menos um screenshot usado na comparacao.'
require_pattern "${SPECIALIST_REVIEW_FILE}" 'Verdict:[[:space:]]*APPROVED' 'inclua "Verdict: APPROVED".'

if grep -Eiq '(^|[^A-Z_])(FAIL|REJECTED|DECISAO_PRODUTO_NECESSARIA)([^A-Z_]|$)' "${MATRIX_FILE}" "${SPECIALIST_REVIEW_FILE}"; then
  echo "Gate visual bloqueado: ha FAIL, REJECTED ou DECISAO_PRODUTO_NECESSARIA nas evidencias." >&2
  exit 1
fi

echo "Gate de QA visual mobile aprovado para ${TASK_KEY}."
