#!/usr/bin/env sh
set -eu

TEMPORARY_ROOT="$(mktemp -d)"
trap 'rm -rf "${TEMPORARY_ROOT}"' EXIT

TASKS_DIR="${TEMPORARY_ROOT}/tasks"
VALID_TASK_KEY="WLT-VALID"
INVALID_TASK_KEY="WLT-INVALID"

mkdir -p "${TASKS_DIR}/${VALID_TASK_KEY}/visual-qa/screenshots"
mkdir -p "${TASKS_DIR}/${INVALID_TASK_KEY}/visual-qa/screenshots"

cat > "${TASKS_DIR}/${VALID_TASK_KEY}/visual-qa/MOBILE_VISUAL_QA_MATRIX.md" <<'EOF'
# Matriz visual

Visual QA Verdict: PASS
Artifact class: functional-homologation

| Tela | Prototipo | Screenshot | Status |
| ---- | --------- | ---------- | ------ |
| Login | docs/prototipos-de-tela/tela-login-autenticacao.png | screenshots/login.png | PASS |

Referencia: docs/jira-pessoal/MAPA-PROTOTIPOS-TELAS.md
EOF

cat > "${TASKS_DIR}/${VALID_TASK_KEY}/visual-qa/MOBILE_FRONTEND_SPECIALIST_REVIEW.md" <<'EOF'
# Mobile Front-end Specialist Review

Verdict: APPROVED

Telas avaliadas com screenshot real e prototipo oficial.
EOF

printf 'fake image bytes\n' > "${TASKS_DIR}/${VALID_TASK_KEY}/visual-qa/screenshots/login.png"

cat > "${TASKS_DIR}/${INVALID_TASK_KEY}/visual-qa/MOBILE_VISUAL_QA_MATRIX.md" <<'EOF'
# Matriz visual

Visual QA Verdict: PASS
Artifact class: preview

| Tela | Prototipo | Screenshot | Status |
| ---- | --------- | ---------- | ------ |
| Login | docs/prototipos-de-tela/tela-login-autenticacao.png | screenshots/login.png | FAIL |
EOF

cat > "${TASKS_DIR}/${INVALID_TASK_KEY}/visual-qa/MOBILE_FRONTEND_SPECIALIST_REVIEW.md" <<'EOF'
# Mobile Front-end Specialist Review

Verdict: APPROVED
EOF

printf 'fake image bytes\n' > "${TASKS_DIR}/${INVALID_TASK_KEY}/visual-qa/screenshots/login.png"

WORKLINK_TASKS_DIR="${TASKS_DIR}" ./scripts/check_mobile_visual_evidence_gate.sh "${VALID_TASK_KEY}" >/dev/null

if WORKLINK_TASKS_DIR="${TASKS_DIR}" ./scripts/check_mobile_visual_evidence_gate.sh "${INVALID_TASK_KEY}" >/dev/null 2>&1; then
  echo "O gate visual deveria bloquear evidencia com FAIL." >&2
  exit 1
fi

echo "Teste do gate de QA visual mobile aprovado."
