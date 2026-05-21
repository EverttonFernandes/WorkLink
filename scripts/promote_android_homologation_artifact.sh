#!/usr/bin/env sh
set -eu

VERSION="${1:-}"
RUN_ID="${2:-}"
ARTIFACT_NAME="${3:-}"
REPOSITORY="${GITHUB_REPOSITORY:-EverttonFernandes/WorkLink}"

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

TEMP_DIR="$(mktemp -d)"
OUTPUT_DIR="artifacts/homologation/releases/${VERSION}/android"

cleanup() {
  rm -rf "${TEMP_DIR}"
}
trap cleanup EXIT INT TERM

if [ -z "${ARTIFACT_NAME}" ]; then
  ARTIFACT_NAME="$(
    gh run view "${RUN_ID}" \
      --repo "${REPOSITORY}" \
      --json artifacts \
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

if grep -q '^api_base_url=not_configured$' "${TEMP_DIR}/BUILD-METADATA.txt"; then
  echo "Artifact rejeitado: api_base_url nao foi configurada." >&2
  exit 1
fi

(
  cd "${TEMP_DIR}"
  sha256sum -c SHA256SUMS
)

mkdir -p "${OUTPUT_DIR}"
cp "${TEMP_DIR}/worklink-android-homologation.apk" "${OUTPUT_DIR}/"
cp "${TEMP_DIR}/BUILD-METADATA.txt" "${OUTPUT_DIR}/"
cp "${TEMP_DIR}/SHA256SUMS" "${OUTPUT_DIR}/"
cp "${TEMP_DIR}/INSTALL-ANDROID.md" "${OUTPUT_DIR}/"

cat > "${OUTPUT_DIR}/PROMOTION-METADATA.txt" <<EOF
version=${VERSION}
source_run_id=${RUN_ID}
source_artifact=${ARTIFACT_NAME}
promoted_at_utc=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
repository=${REPOSITORY}
EOF

echo "Artifact Android de homologacao promovido para ${OUTPUT_DIR}."
