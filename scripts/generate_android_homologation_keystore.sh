#!/usr/bin/env sh
set -eu

OUTPUT_DIR="${ANDROID_HOMOLOGATION_KEY_OUTPUT_DIR:-artifacts/local-secrets/android-homologation}"
KEYSTORE_FILE="${OUTPUT_DIR}/homologation-upload.jks"
ENV_FILE="${OUTPUT_DIR}/github-secrets.env"
ALIAS="${WORKLINK_ANDROID_HOMOLOGATION_KEY_ALIAS:-worklink-homologation}"
DNAME="${WORKLINK_ANDROID_HOMOLOGATION_KEY_DNAME:-CN=WorkLink Homologation, OU=Mobile, O=WorkLink, L=Charqueadas, ST=RS, C=BR}"
VALIDITY_DAYS="${WORKLINK_ANDROID_HOMOLOGATION_KEY_VALIDITY_DAYS:-3650}"

if ! command -v keytool >/dev/null 2>&1; then
  echo "keytool nao encontrado. Instale um JDK 21+ ou execute este script em uma maquina com Java instalado." >&2
  exit 1
fi

if ! command -v openssl >/dev/null 2>&1; then
  echo "openssl nao encontrado." >&2
  exit 1
fi

if ! command -v base64 >/dev/null 2>&1; then
  echo "base64 nao encontrado." >&2
  exit 1
fi

if [ -e "${KEYSTORE_FILE}" ]; then
  echo "Keystore ja existe em ${KEYSTORE_FILE}. Remova manualmente para gerar outra." >&2
  exit 1
fi

shell_quote() {
  printf "'%s'" "$(printf '%s' "$1" | sed "s/'/'\\\\''/g")"
}

base64_one_line() {
  if base64 --help 2>&1 | grep -q -- '-w'; then
    base64 -w 0 "$1"
  else
    base64 "$1" | tr -d '\n'
  fi
}

mkdir -p "${OUTPUT_DIR}"
chmod 700 "${OUTPUT_DIR}"

KEYSTORE_PASSWORD="$(openssl rand -base64 36 | tr -d '\n')"
KEY_PASSWORD="$(openssl rand -base64 36 | tr -d '\n')"

keytool \
  -genkeypair \
  -v \
  -keystore "${KEYSTORE_FILE}" \
  -storetype JKS \
  -storepass "${KEYSTORE_PASSWORD}" \
  -keypass "${KEY_PASSWORD}" \
  -alias "${ALIAS}" \
  -keyalg RSA \
  -keysize 4096 \
  -validity "${VALIDITY_DAYS}" \
  -dname "${DNAME}"

chmod 600 "${KEYSTORE_FILE}"

CERT_SHA256="$(
  keytool \
    -list \
    -v \
    -keystore "${KEYSTORE_FILE}" \
    -storepass "${KEYSTORE_PASSWORD}" \
    -alias "${ALIAS}" \
    | awk -F': ' '/SHA256:/ { print $2; exit }' \
    | tr -d ':\r\n[:space:]' \
    | tr '[:upper:]' '[:lower:]'
)"

KEYSTORE_BASE64="$(base64_one_line "${KEYSTORE_FILE}")"

cat > "${ENV_FILE}" <<EOF
export WORKLINK_ANDROID_HOMOLOGATION_KEYSTORE_BASE64=$(shell_quote "${KEYSTORE_BASE64}")
export WORKLINK_ANDROID_HOMOLOGATION_KEYSTORE_PASSWORD=$(shell_quote "${KEYSTORE_PASSWORD}")
export WORKLINK_ANDROID_HOMOLOGATION_KEY_ALIAS=$(shell_quote "${ALIAS}")
export WORKLINK_ANDROID_HOMOLOGATION_KEY_PASSWORD=$(shell_quote "${KEY_PASSWORD}")
export WORKLINK_ANDROID_HOMOLOGATION_CERT_SHA256=$(shell_quote "${CERT_SHA256}")
EOF

chmod 600 "${ENV_FILE}"

cat <<EOF
Keystore Android de homologacao gerado.

Arquivos locais, nao versionados:
- ${KEYSTORE_FILE}
- ${ENV_FILE}

Fingerprint SHA-256:
${CERT_SHA256}
EOF
