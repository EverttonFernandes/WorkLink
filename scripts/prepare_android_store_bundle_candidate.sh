#!/usr/bin/env sh
set -eu

AAB_SOURCE="${AAB_SOURCE:-worklink-mobile/build/app/outputs/bundle/release/app-release.aab}"
OUTPUT_DIR="${OUTPUT_DIR:-artifacts/android-play-internal-candidate}"
AAB_NAME="${AAB_NAME:-profissional-perto-play-internal.aab}"
PUBSPEC_FILE="${PUBSPEC_FILE:-worklink-mobile/pubspec.yaml}"
API_BASE_URL="${API_BASE_URL:-not_configured}"
BUILD_TYPE="${BUILD_TYPE:-release}"
SIGNING="${SIGNING:-android_store_upload_key}"
ARTIFACT_TYPE="${ARTIFACT_TYPE:-android-play-internal-candidate}"
ARTIFACT_CLASS="${ARTIFACT_CLASS:-release-candidate}"
APP_DATA_MODE="${APP_DATA_MODE:-store-release}"
KNOWN_LIMITATIONS="${KNOWN_LIMITATIONS:-depende de backend HTTPS estavel, cadastro Play Console e validacao manual na trilha interna}"
DOWNLOAD_ARTIFACT_NAME="${DOWNLOAD_ARTIFACT_NAME:-worklink-android-play-internal-<commit>}"
PLAY_TRACK="${PLAY_TRACK:-internal}"

if [ ! -s "${AAB_SOURCE}" ]; then
  echo "AAB nao encontrado ou vazio em ${AAB_SOURCE}." >&2
  exit 1
fi

mkdir -p "${OUTPUT_DIR}"
cp "${AAB_SOURCE}" "${OUTPUT_DIR}/${AAB_NAME}"

APP_VERSION="$(
  awk -F': ' '/^version: / { print $2; exit }' "${PUBSPEC_FILE}" 2>/dev/null || true
)"
APP_VERSION="${APP_VERSION:-unknown}"

GIT_COMMIT="${GITHUB_SHA:-$(git rev-parse HEAD 2>/dev/null || echo unknown)}"
GIT_BRANCH="${GITHUB_REF_NAME:-$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)}"
GIT_TAGS="$(git tag --points-at "${GIT_COMMIT}" 2>/dev/null | tr '\n' ' ' | sed 's/[[:space:]]*$//' || true)"
GIT_TAGS="${GIT_TAGS:-none}"
RUN_ID="${GITHUB_RUN_ID:-local}"
RUN_ATTEMPT="${GITHUB_RUN_ATTEMPT:-local}"
BUILD_TIMESTAMP="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
AAB_SIZE_BYTES="$(wc -c < "${OUTPUT_DIR}/${AAB_NAME}" | tr -d ' ')"

(
  cd "${OUTPUT_DIR}"
  sha256sum "${AAB_NAME}" > SHA256SUMS
)

cat > "${OUTPUT_DIR}/BUILD-METADATA.txt" <<EOF
artifact=${ARTIFACT_TYPE}
artifact_class=${ARTIFACT_CLASS}
bundle=${AAB_NAME}
app_version=${APP_VERSION}
git_commit=${GIT_COMMIT}
git_branch=${GIT_BRANCH}
git_tags=${GIT_TAGS}
github_run_id=${RUN_ID}
github_run_attempt=${RUN_ATTEMPT}
built_at_utc=${BUILD_TIMESTAMP}
bundle_size_bytes=${AAB_SIZE_BYTES}
build_type=${BUILD_TYPE}
signing=${SIGNING}
app_data_mode=${APP_DATA_MODE}
api_base_url=${API_BASE_URL}
play_track=${PLAY_TRACK}
known_limitations=${KNOWN_LIMITATIONS}
distribution_scope=play_internal_testing_only
EOF

cat > "${OUTPUT_DIR}/PUBLISH-PLAY-STORE.md" <<EOF
# Profissional Perto - Android App Bundle para Play Internal Testing

Este pacote contem um Android App Bundle de release preparado para trilha interna da Google Play.

## Arquivos

- \`${AAB_NAME}\`: bundle Android para upload no Play Console.
- \`BUILD-METADATA.txt\`: commit, branch, versao, backend e run da pipeline.
- \`SHA256SUMS\`: checksum do bundle.

## Como usar

1. Baixe o artifact \`${DOWNLOAD_ARTIFACT_NAME}\` no run verde do GitHub Actions.
2. Extraia o zip do artifact.
3. Abra a Google Play Console e selecione o app \`Profissional Perto\`.
4. Entre em \`Testing > Internal testing\`.
5. Crie ou selecione um release.
6. Envie o arquivo \`${AAB_NAME}\`.
7. Confirme se o \`versionCode\` e o backend esperado batem com \`BUILD-METADATA.txt\`.
8. Publique a trilha interna e valide a instalacao pela Play Store em aparelho real.

## Observacoes

- Classe do artifact: \`${ARTIFACT_CLASS}\`.
- Assinatura declarada: \`${SIGNING}\`.
- Backend configurado no build: \`${API_BASE_URL}\`.
- Trilha prevista: \`${PLAY_TRACK}\`.
- Limitacoes conhecidas: ${KNOWN_LIMITATIONS}.
- Este artifact nao substitui o gate visual, o smoke test manual nem as declaracoes obrigatorias da Play Console.
- Nao versione o \`.aab\` no repositorio; apenas os metadados de release/promocao.
EOF

echo "Android Play Store bundle candidate preparado em ${OUTPUT_DIR}."
