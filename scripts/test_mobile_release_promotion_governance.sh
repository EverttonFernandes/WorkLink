#!/usr/bin/env sh
set -eu

TEMPORARY_ROOT="$(mktemp -d)"
trap 'rm -rf "${TEMPORARY_ROOT}"' EXIT

create_minimal_repository() {
  target_root="$1"

  mkdir -p \
    "${target_root}/.github/workflows" \
    "${target_root}/docs/operacao" \
    "${target_root}/docs/release" \
    "${target_root}/scripts"

  cat > "${target_root}/docs/operacao/mobile-release-promocao-rollback.md" <<'EOF'
# Promocao

Teste interno, Beta, Producao.
Rollback.
tag commit artifact checksum.
CI obrigatoria.
CD manual.
Bloqueadores de publicacao.
EOF

  cat > "${target_root}/docs/release/release-mobile.md" <<'EOF'
Consulte docs/operacao/mobile-release-promocao-rollback.md.
EOF

  cat > "${target_root}/scripts/promote_android_homologation_artifact.sh" <<'EOF'
grep BUILD-METADATA.txt artifact
grep SHA256SUMS artifact
grep app_data_mode=homologation-fullstack artifact
grep artifact=android-homologation-candidate artifact
grep build_type=release artifact
grep signing=android_homologation_key artifact
EOF

  cat > "${target_root}/Makefile" <<'EOF'
mobile-release-promotion-governance:
	./scripts/check_mobile_release_promotion_governance.sh
EOF

  cat > "${target_root}/.github/workflows/ci.yml" <<'EOF'
name: CI
jobs:
  dependency-scan:
    steps:
      - name: Mobile release promotion governance gate
        run: make mobile-release-promotion-governance
EOF
}

VALID_REPOSITORY="${TEMPORARY_ROOT}/valid"
INVALID_REPOSITORY="${TEMPORARY_ROOT}/invalid"

mkdir -p "${VALID_REPOSITORY}" "${INVALID_REPOSITORY}"
create_minimal_repository "${VALID_REPOSITORY}"
create_minimal_repository "${INVALID_REPOSITORY}"

./scripts/check_mobile_release_promotion_governance.sh "${VALID_REPOSITORY}" >/dev/null

sed -i '/Rollback/d' "${INVALID_REPOSITORY}/docs/operacao/mobile-release-promocao-rollback.md"

if ./scripts/check_mobile_release_promotion_governance.sh "${INVALID_REPOSITORY}" >/dev/null 2>&1; then
  echo "Gate deveria bloquear documento sem estrategia de rollback." >&2
  exit 1
fi

echo "Teste do gate de promocao e rollback mobile aprovado."
