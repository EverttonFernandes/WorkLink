#!/usr/bin/env sh
set -eu

TEMPORARY_ROOT="$(mktemp -d)"
trap 'rm -rf "${TEMPORARY_ROOT}"' EXIT

VALID_ARTIFACT_DIR="${TEMPORARY_ROOT}/valid"
INVALID_ARTIFACT_DIR="${TEMPORARY_ROOT}/invalid"

mkdir -p "${VALID_ARTIFACT_DIR}" "${INVALID_ARTIFACT_DIR}"

cat > "${VALID_ARTIFACT_DIR}/BUILD-METADATA.txt" <<'EOF'
artifact=android-homologation-candidate
artifact_class=functional-homologation
git_commit=abc123
git_tags=v0.1.0
app_data_mode=homologation-fullstack
api_base_url=https://homologacao.example.com
known_limitations=envio de notificacoes pode ser simulado
EOF

cat > "${VALID_ARTIFACT_DIR}/INSTALL-ANDROID.md" <<'EOF'
# Android

Classe do artifact: functional-homologation.

Limitacoes conhecidas: envio de notificacoes pode ser simulado.
EOF

cat > "${INVALID_ARTIFACT_DIR}/BUILD-METADATA.txt" <<'EOF'
artifact=android-test-candidate
artifact_class=preview
git_commit=abc123
git_tags=none
app_data_mode=preview
api_base_url=not_configured
known_limitations=dados locais de preview
EOF

cat > "${INVALID_ARTIFACT_DIR}/INSTALL-ANDROID.md" <<'EOF'
# Android

Classe do artifact: preview.

Limitacoes conhecidas: dados locais de preview.

Este pacote e um release candidate.
EOF

./scripts/check_mobile_product_homologation_governance.sh "${VALID_ARTIFACT_DIR}" >/dev/null

if ./scripts/check_mobile_product_homologation_governance.sh "${INVALID_ARTIFACT_DIR}" >/dev/null 2>&1; then
  echo "O gate deveria bloquear preview descrito como release candidate." >&2
  exit 1
fi

echo "Teste do gate de governanca de homologacao mobile aprovado."
