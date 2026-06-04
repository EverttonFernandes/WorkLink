#!/usr/bin/env sh
set -eu

REPOSITORY_ROOT="${1:-.}"
GITIGNORE_FILE="${REPOSITORY_ROOT}/.gitignore"
ROOT_ENV_EXAMPLE="${REPOSITORY_ROOT}/.env.example"
MOBILE_ENV_EXAMPLE="${REPOSITORY_ROOT}/worklink-mobile/.env.example"
GOVERNANCE_DOC="${REPOSITORY_ROOT}/docs/operacao/mobile-secrets-assinatura.md"
CI_WORKFLOW="${REPOSITORY_ROOT}/.github/workflows/ci.yml"
IOS_WORKFLOW="${REPOSITORY_ROOT}/.github/workflows/ios-build.yml"

blocked_pattern='(\.jks$|\.keystore$|\.p12$|\.p8$|\.cer$|\.key$|\.mobileprovision$|\.provisionprofile$|GoogleService-Info\.plist$|google-services\.json$)'

require_file() {
  if [ ! -f "$1" ]; then
    echo "Arquivo obrigatorio ausente para governanca de assinatura mobile: $1" >&2
    exit 1
  fi
}

require_pattern() {
  file_path="$1"
  pattern="$2"
  failure_message="$3"

  if ! grep -Eq "${pattern}" "${file_path}"; then
    echo "${failure_message}" >&2
    echo "Arquivo: ${file_path}" >&2
    exit 1
  fi
}

for required_file in \
  "${GITIGNORE_FILE}" \
  "${ROOT_ENV_EXAMPLE}" \
  "${MOBILE_ENV_EXAMPLE}" \
  "${GOVERNANCE_DOC}" \
  "${CI_WORKFLOW}" \
  "${IOS_WORKFLOW}"; do
  require_file "${required_file}"
done

tracked_sensitive_files="$(git -C "${REPOSITORY_ROOT}" ls-files | grep -E "${blocked_pattern}" || true)"

if [ -n "${tracked_sensitive_files}" ]; then
  echo "Arquivos sensiveis de assinatura/configuracao mobile nao podem ser versionados:" >&2
  echo "${tracked_sensitive_files}" >&2
  exit 1
fi

for ignored_pattern in \
  '\*\.jks' \
  '\*\.keystore' \
  '\*\.p12' \
  '\*\.p8' \
  '\*\.cer' \
  '\*\.key' \
  '\*\.mobileprovision' \
  '\*\.provisionprofile' \
  'GoogleService-Info\.plist' \
  'google-services\.json' \
  'artifacts/local-secrets/'; do
  require_pattern "${GITIGNORE_FILE}" "^${ignored_pattern}$" \
    "Padrao sensivel ausente no .gitignore: ${ignored_pattern}"
done

for android_secret in \
  WORKLINK_ANDROID_HOMOLOGATION_KEYSTORE_BASE64 \
  WORKLINK_ANDROID_HOMOLOGATION_KEYSTORE_PASSWORD \
  WORKLINK_ANDROID_HOMOLOGATION_KEY_ALIAS \
  WORKLINK_ANDROID_HOMOLOGATION_KEY_PASSWORD; do
  require_pattern "${CI_WORKFLOW}" "${android_secret}" \
    "Workflow CI nao referencia o secret Android esperado: ${android_secret}"
  require_pattern "${GOVERNANCE_DOC}" "${android_secret}" \
    "Documento de governanca nao inventaria o secret Android esperado: ${android_secret}"
done

for apple_secret in \
  WORKLINK_APPLE_TEAM_ID \
  WORKLINK_IOS_BUNDLE_IDENTIFIER \
  WORKLINK_APP_STORE_CONNECT_API_KEY_ID \
  WORKLINK_APP_STORE_CONNECT_ISSUER_ID \
  WORKLINK_APP_STORE_CONNECT_API_PRIVATE_KEY \
  WORKLINK_IOS_DISTRIBUTION_CERTIFICATE_BASE64 \
  WORKLINK_IOS_DISTRIBUTION_CERTIFICATE_PASSWORD \
  WORKLINK_IOS_PROVISIONING_PROFILE_BASE64; do
  require_pattern "${IOS_WORKFLOW}" "${apple_secret}" \
    "Workflow iOS nao referencia o secret Apple esperado: ${apple_secret}"
  require_pattern "${GOVERNANCE_DOC}" "${apple_secret}" \
    "Documento de governanca nao inventaria o secret Apple esperado: ${apple_secret}"
done

require_pattern "${ROOT_ENV_EXAMPLE}" 'WORKLINK_HOMOLOGATION_API_BASE_URL' \
  ".env.example precisa documentar a URL de homologacao mobile."
require_pattern "${MOBILE_ENV_EXAMPLE}" 'WORKLINK_USE_PREVIEW_DATA' \
  "worklink-mobile/.env.example precisa documentar o modo de dados de preview."
require_pattern "${GOVERNANCE_DOC}" 'Rotacao e revogacao' \
  "Documento de governanca precisa definir rotacao e revogacao."
require_pattern "${GOVERNANCE_DOC}" 'Obrigatorios para CD' \
  "Documento de governanca precisa classificar secrets que bloqueiam CD."
require_pattern "${CI_WORKFLOW}" 'Mobile signing governance gate' \
  "Workflow CI precisa executar o gate de governanca de assinatura mobile."

echo "Governanca de secrets e assinatura mobile validada."
