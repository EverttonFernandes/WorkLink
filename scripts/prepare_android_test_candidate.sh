#!/usr/bin/env sh
set -eu

APK_SOURCE="${APK_SOURCE:-worklink-mobile/build/app/outputs/flutter-apk/app-debug.apk}"
OUTPUT_DIR="${OUTPUT_DIR:-artifacts/android-test-candidate}"
APK_NAME="${APK_NAME:-worklink-android-test-candidate.apk}"
PUBSPEC_FILE="${PUBSPEC_FILE:-worklink-mobile/pubspec.yaml}"
APP_DATA_MODE="${APP_DATA_MODE:-preview}"

if [ ! -s "${APK_SOURCE}" ]; then
  echo "APK nao encontrado ou vazio em ${APK_SOURCE}." >&2
  exit 1
fi

mkdir -p "${OUTPUT_DIR}"
cp "${APK_SOURCE}" "${OUTPUT_DIR}/${APK_NAME}"

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
APK_SIZE_BYTES="$(wc -c < "${OUTPUT_DIR}/${APK_NAME}" | tr -d ' ')"

(
  cd "${OUTPUT_DIR}"
  sha256sum "${APK_NAME}" > SHA256SUMS
)

cat > "${OUTPUT_DIR}/BUILD-METADATA.txt" <<EOF
artifact=android-test-candidate
apk=${APK_NAME}
app_version=${APP_VERSION}
git_commit=${GIT_COMMIT}
git_branch=${GIT_BRANCH}
git_tags=${GIT_TAGS}
github_run_id=${RUN_ID}
github_run_attempt=${RUN_ATTEMPT}
built_at_utc=${BUILD_TIMESTAMP}
apk_size_bytes=${APK_SIZE_BYTES}
build_type=debug
signing=android_debug_key
app_data_mode=${APP_DATA_MODE}
distribution_scope=manual_internal_test_only
EOF

cat > "${OUTPUT_DIR}/INSTALL-ANDROID.md" <<EOF
# WorkLink Android Test Candidate

Este pacote contem um APK debug instalavel para validacao manual interna antes da publicacao em loja.

## Arquivos

- \`${APK_NAME}\`: APK para instalar no Android.
- \`BUILD-METADATA.txt\`: commit, branch, versao e run da pipeline.
- \`SHA256SUMS\`: checksum do APK.

## Como testar no Android

1. Baixe o artifact \`worklink-android-test-candidate-<commit>\` no run verde do GitHub Actions.
2. Extraia o arquivo zip.
3. Transfira \`${APK_NAME}\` para o aparelho Android.
4. No Android, permita instalacao de apps desconhecidos para o app usado para abrir o APK.
5. Abra \`${APK_NAME}\` e confirme a instalacao.
6. Abra o WorkLink e valide abertura, descoberta de profissionais, perfil e fluxos principais.

## Observacoes

- Este APK usa chave debug do Android e e somente para teste interno.
- Este APK usa dados preview para permitir navegacao manual sem backend publicado.
- Nao publique este APK na Google Play.
- Builds assinados para loja entram na etapa de governanca de secrets e assinatura mobile.
EOF

echo "Android test candidate preparado em ${OUTPUT_DIR}."
