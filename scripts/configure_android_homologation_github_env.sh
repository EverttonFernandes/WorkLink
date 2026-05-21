#!/usr/bin/env sh
set -eu

REPOSITORY="${GITHUB_REPOSITORY:-EverttonFernandes/WorkLink}"
ENV_FILE="${ANDROID_HOMOLOGATION_GITHUB_ENV_FILE:-artifacts/local-secrets/android-homologation/github-secrets.env}"
API_BASE_URL="${WORKLINK_HOMOLOGATION_API_BASE_URL:-${1:-}}"
ALLOWED_HOSTS="${WORKLINK_HOMOLOGATION_ALLOWED_HOSTS:-}"

if [ -z "${API_BASE_URL}" ]; then
  echo "Informe WORKLINK_HOMOLOGATION_API_BASE_URL ou passe a URL como primeiro argumento." >&2
  exit 1
fi

if [ ! -f "${ENV_FILE}" ]; then
  echo "Arquivo de secrets nao encontrado: ${ENV_FILE}" >&2
  echo "Gere com scripts/generate_android_homologation_keystore.sh ou informe ANDROID_HOMOLOGATION_GITHUB_ENV_FILE." >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI (gh) nao encontrado." >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 nao encontrado." >&2
  exit 1
fi

HOST="$(
  API_BASE_URL="${API_BASE_URL}" python3 - <<'PY'
import os
import sys
from urllib.parse import urlparse

parsed = urlparse(os.environ["API_BASE_URL"])
if parsed.scheme != "https" or not parsed.hostname:
    print("A URL de homologacao precisa ser HTTPS e ter host valido.", file=sys.stderr)
    sys.exit(1)
print(parsed.hostname.lower().rstrip("."))
PY
)"

if [ -z "${ALLOWED_HOSTS}" ]; then
  ALLOWED_HOSTS="${HOST}"
fi

# shellcheck disable=SC1090
. "${ENV_FILE}"

required_secret_names="
WORKLINK_ANDROID_HOMOLOGATION_KEYSTORE_BASE64
WORKLINK_ANDROID_HOMOLOGATION_KEYSTORE_PASSWORD
WORKLINK_ANDROID_HOMOLOGATION_KEY_ALIAS
WORKLINK_ANDROID_HOMOLOGATION_KEY_PASSWORD
WORKLINK_ANDROID_HOMOLOGATION_CERT_SHA256
"

for secret_name in ${required_secret_names}; do
  eval "secret_value=\${${secret_name}:-}"
  if [ -z "${secret_value}" ]; then
    echo "Valor ausente em ${ENV_FILE}: ${secret_name}" >&2
    exit 1
  fi
done

WORKLINK_HOMOLOGATION_ALLOWED_HOSTS="${ALLOWED_HOSTS}" \
  ./scripts/validate_homologation_api_base_url.sh "${API_BASE_URL}" >/dev/null

gh variable set WORKLINK_HOMOLOGATION_API_BASE_URL \
  --repo "${REPOSITORY}" \
  --body "${API_BASE_URL}"

gh variable set WORKLINK_HOMOLOGATION_ALLOWED_HOSTS \
  --repo "${REPOSITORY}" \
  --body "${ALLOWED_HOSTS}"

gh variable set WORKLINK_ANDROID_HOMOLOGATION_CERT_SHA256 \
  --repo "${REPOSITORY}" \
  --body "${WORKLINK_ANDROID_HOMOLOGATION_CERT_SHA256}"

printf '%s' "${WORKLINK_ANDROID_HOMOLOGATION_KEYSTORE_BASE64}" \
  | gh secret set WORKLINK_ANDROID_HOMOLOGATION_KEYSTORE_BASE64 --repo "${REPOSITORY}"

printf '%s' "${WORKLINK_ANDROID_HOMOLOGATION_KEYSTORE_PASSWORD}" \
  | gh secret set WORKLINK_ANDROID_HOMOLOGATION_KEYSTORE_PASSWORD --repo "${REPOSITORY}"

printf '%s' "${WORKLINK_ANDROID_HOMOLOGATION_KEY_ALIAS}" \
  | gh secret set WORKLINK_ANDROID_HOMOLOGATION_KEY_ALIAS --repo "${REPOSITORY}"

printf '%s' "${WORKLINK_ANDROID_HOMOLOGATION_KEY_PASSWORD}" \
  | gh secret set WORKLINK_ANDROID_HOMOLOGATION_KEY_PASSWORD --repo "${REPOSITORY}"

cat <<EOF
GitHub Actions configurado para homologacao Android.

Repository: ${REPOSITORY}
Backend: ${API_BASE_URL}
Allowlist: ${ALLOWED_HOSTS}
Fingerprint SHA-256: ${WORKLINK_ANDROID_HOMOLOGATION_CERT_SHA256}
EOF
