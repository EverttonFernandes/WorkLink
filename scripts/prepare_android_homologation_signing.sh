#!/usr/bin/env sh
set -eu

KEYSTORE_BASE64="${WORKLINK_ANDROID_HOMOLOGATION_KEYSTORE_BASE64:-}"
KEYSTORE_PASSWORD="${WORKLINK_ANDROID_HOMOLOGATION_KEYSTORE_PASSWORD:-}"
KEY_ALIAS="${WORKLINK_ANDROID_HOMOLOGATION_KEY_ALIAS:-}"
KEY_PASSWORD="${WORKLINK_ANDROID_HOMOLOGATION_KEY_PASSWORD:-}"
KEYSTORE_PATH="${WORKLINK_ANDROID_HOMOLOGATION_KEYSTORE_PATH:-android/app/homologation-upload.jks}"

if [ -z "${KEYSTORE_BASE64}" ] ||
  [ -z "${KEYSTORE_PASSWORD}" ] ||
  [ -z "${KEY_ALIAS}" ] ||
  [ -z "${KEY_PASSWORD}" ]; then
  echo "Secrets de assinatura Android de homologacao incompletos." >&2
  echo "Configure WORKLINK_ANDROID_HOMOLOGATION_KEYSTORE_BASE64, WORKLINK_ANDROID_HOMOLOGATION_KEYSTORE_PASSWORD, WORKLINK_ANDROID_HOMOLOGATION_KEY_ALIAS e WORKLINK_ANDROID_HOMOLOGATION_KEY_PASSWORD." >&2
  exit 1
fi

mkdir -p "$(dirname "${KEYSTORE_PATH}")"
printf '%s' "${KEYSTORE_BASE64}" | base64 -d > "${KEYSTORE_PATH}"

if [ ! -s "${KEYSTORE_PATH}" ]; then
  echo "Keystore Android de homologacao nao foi gerado corretamente." >&2
  exit 1
fi

chmod 600 "${KEYSTORE_PATH}"
echo "Keystore Android de homologacao preparado em ${KEYSTORE_PATH}."
