#!/usr/bin/env sh
set -eu

VERSION="${1:-}"
RUN_ID="${2:-}"
ARTIFACT_NAME="${3:-}"
REPOSITORY="${GITHUB_REPOSITORY:-EverttonFernandes/WorkLink}"
UPLOAD_GITHUB_RELEASE="${PROMOTE_UPLOAD_GITHUB_RELEASE:-true}"
RELEASE_ASSET_NAME="${PROMOTE_ANDROID_APK_ASSET_NAME:-worklink-android-homologation.apk}"
EXPECTED_CERT_SHA256="${WORKLINK_ANDROID_HOMOLOGATION_CERT_SHA256:-}"

if [ -z "${VERSION}" ] || [ -z "${RUN_ID}" ]; then
  echo "Uso: $0 <versao-semantica> <github-run-id> [artifact-name]" >&2
  echo "Exemplo: $0 v0.49.0 123456789 worklink-android-homologation-<commit>" >&2
  exit 1
fi

case "${VERSION}" in
  v[0-9]*.[0-9]*.[0-9]*) ;;
  *)
    echo "Versao invalida: ${VERSION}. Use formato semantico como v0.49.0." >&2
    exit 1
    ;;
esac

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI (gh) nao encontrado." >&2
  exit 1
fi

if [ -z "${EXPECTED_CERT_SHA256}" ]; then
  echo "Fingerprint SHA-256 da chave de homologacao nao configurada." >&2
  echo "Defina WORKLINK_ANDROID_HOMOLOGATION_CERT_SHA256 antes de promover o APK." >&2
  exit 1
fi

find_apksigner() {
  if [ -n "${APKSIGNER:-}" ] && [ -x "${APKSIGNER}" ]; then
    printf '%s\n' "${APKSIGNER}"
    return 0
  fi

  if command -v apksigner >/dev/null 2>&1; then
    command -v apksigner
    return 0
  fi

  for android_sdk_dir in "${ANDROID_HOME:-}" "${ANDROID_SDK_ROOT:-}"; do
    if [ -n "${android_sdk_dir}" ] && [ -d "${android_sdk_dir}/build-tools" ]; then
      find "${android_sdk_dir}/build-tools" -type f -name apksigner 2>/dev/null \
        | sort -V \
        | tail -n 1
      return 0
    fi
  done

  return 1
}

normalize_sha256() {
  printf '%s' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | tr -d ':\n\r[:space:]'
}

TEMP_DIR="$(mktemp -d)"
OUTPUT_DIR="artifacts/homologation/releases/${VERSION}/android"

cleanup() {
  rm -rf "${TEMP_DIR}"
}
trap cleanup EXIT INT TERM

if [ -z "${ARTIFACT_NAME}" ]; then
  ARTIFACT_NAME="$(
    gh api "repos/${REPOSITORY}/actions/runs/${RUN_ID}/artifacts" \
      --paginate \
      --jq '.artifacts[].name | select(startswith("worklink-android-homologation-"))' \
      | head -n 1
  )"
fi

if [ -z "${ARTIFACT_NAME}" ]; then
  echo "Artifact Android de homologacao nao encontrado no run ${RUN_ID}." >&2
  exit 1
fi

gh run download "${RUN_ID}" \
  --repo "${REPOSITORY}" \
  --name "${ARTIFACT_NAME}" \
  --dir "${TEMP_DIR}"

if [ ! -f "${TEMP_DIR}/BUILD-METADATA.txt" ]; then
  echo "BUILD-METADATA.txt nao encontrado no artifact ${ARTIFACT_NAME}." >&2
  exit 1
fi

if ! grep -q '^app_data_mode=homologation-fullstack$' "${TEMP_DIR}/BUILD-METADATA.txt"; then
  echo "Artifact rejeitado: app_data_mode precisa ser homologation-fullstack." >&2
  exit 1
fi

if ! grep -q '^artifact=android-homologation-candidate$' "${TEMP_DIR}/BUILD-METADATA.txt"; then
  echo "Artifact rejeitado: artifact precisa ser android-homologation-candidate." >&2
  exit 1
fi

if grep -q '^api_base_url=not_configured$' "${TEMP_DIR}/BUILD-METADATA.txt"; then
  echo "Artifact rejeitado: api_base_url nao foi configurada." >&2
  exit 1
fi

API_BASE_URL="$(
  awk -F= '/^api_base_url=/ { sub(/^api_base_url=/, ""); print; exit }' "${TEMP_DIR}/BUILD-METADATA.txt"
)"

if [ -z "${API_BASE_URL}" ]; then
  echo "Artifact rejeitado: api_base_url ausente nos metadados." >&2
  exit 1
fi

./scripts/validate_homologation_api_base_url.sh "${API_BASE_URL}"

if ! grep -q '^build_type=release$' "${TEMP_DIR}/BUILD-METADATA.txt"; then
  echo "Artifact rejeitado: build_type precisa ser release." >&2
  exit 1
fi

if grep -q '^signing=android_debug_key$' "${TEMP_DIR}/BUILD-METADATA.txt"; then
  echo "Artifact rejeitado: assinatura debug nao pode ser promovida para homologacao." >&2
  exit 1
fi

if ! grep -q '^signing=android_homologation_key$' "${TEMP_DIR}/BUILD-METADATA.txt"; then
  echo "Artifact rejeitado: signing precisa ser android_homologation_key." >&2
  exit 1
fi

(
  cd "${TEMP_DIR}"
  sha256sum -c SHA256SUMS
)

APKSIGNER_BIN="$(find_apksigner || true)"
if [ -z "${APKSIGNER_BIN}" ]; then
  echo "apksigner nao encontrado. Instale Android build-tools ou defina APKSIGNER=/caminho/apksigner." >&2
  exit 1
fi

CERTIFICATE_OUTPUT="$("${APKSIGNER_BIN}" verify --print-certs "${TEMP_DIR}/worklink-android-homologation.apk")"
ACTUAL_CERT_SHA256="$(
  printf '%s\n' "${CERTIFICATE_OUTPUT}" \
    | awk -F': ' '/certificate SHA-256 digest/ { print $2; exit }'
)"

if [ -z "${ACTUAL_CERT_SHA256}" ]; then
  echo "Artifact rejeitado: nao foi possivel ler o fingerprint SHA-256 do APK." >&2
  exit 1
fi

if [ "$(normalize_sha256 "${ACTUAL_CERT_SHA256}")" != "$(normalize_sha256 "${EXPECTED_CERT_SHA256}")" ]; then
  echo "Artifact rejeitado: fingerprint SHA-256 do APK nao corresponde a chave de homologacao esperada." >&2
  exit 1
fi

if [ "${UPLOAD_GITHUB_RELEASE}" = "true" ]; then
  if ! gh release view "${VERSION}" --repo "${REPOSITORY}" >/dev/null 2>&1; then
    gh release create "${VERSION}" \
      --repo "${REPOSITORY}" \
      --verify-tag \
      --title "WorkLink ${VERSION}" \
      --notes "Release semantica ${VERSION} com APK Android de homologacao versionado como asset protegido pelo GitHub."
  fi

  RELEASE_ASSET_PATH="${TEMP_DIR}/worklink-android-homologation.apk"
  if [ "${RELEASE_ASSET_NAME}" != "worklink-android-homologation.apk" ]; then
    cp "${TEMP_DIR}/worklink-android-homologation.apk" "${TEMP_DIR}/${RELEASE_ASSET_NAME}"
    RELEASE_ASSET_PATH="${TEMP_DIR}/${RELEASE_ASSET_NAME}"
  fi

  gh release upload "${VERSION}" "${RELEASE_ASSET_PATH}" \
    --repo "${REPOSITORY}" \
    --clobber
fi

mkdir -p "${OUTPUT_DIR}"
cp "${TEMP_DIR}/BUILD-METADATA.txt" "${OUTPUT_DIR}/"
cp "${TEMP_DIR}/SHA256SUMS" "${OUTPUT_DIR}/"
cp "${TEMP_DIR}/INSTALL-ANDROID.md" "${OUTPUT_DIR}/"

cat > "${OUTPUT_DIR}/PROMOTION-METADATA.txt" <<EOF
version=${VERSION}
source_run_id=${RUN_ID}
source_artifact=${ARTIFACT_NAME}
release_tag=${VERSION}
release_asset=${RELEASE_ASSET_NAME}
release_upload_enabled=${UPLOAD_GITHUB_RELEASE}
android_cert_sha256=$(normalize_sha256 "${ACTUAL_CERT_SHA256}")
promoted_at_utc=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
repository=${REPOSITORY}
EOF

cat > "${OUTPUT_DIR}/APK-ASSET.md" <<EOF
# WorkLink Android Homologation APK

O APK de homologacao nao e versionado como binario dentro do git.

- Release: https://github.com/${REPOSITORY}/releases/tag/${VERSION}
- Asset: \`${RELEASE_ASSET_NAME}\`
- Source workflow run: ${RUN_ID}
- Source artifact: \`${ARTIFACT_NAME}\`

Use o checksum registrado em \`SHA256SUMS\` para conferir o APK baixado do Release.
EOF

echo "Metadados Android de homologacao promovidos para ${OUTPUT_DIR}."
echo "APK versionado como asset do GitHub Release ${VERSION}: ${RELEASE_ASSET_NAME}."
