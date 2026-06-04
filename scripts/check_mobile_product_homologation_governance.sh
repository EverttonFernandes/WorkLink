#!/usr/bin/env sh
set -eu

ARTIFACT_DIR="${1:-${ARTIFACT_DIR:-}}"

if [ -z "${ARTIFACT_DIR}" ]; then
  echo "Informe ARTIFACT_DIR. Exemplo: make mobile-product-homologation-gate ARTIFACT_DIR=artifacts/android-homologation-candidate" >&2
  exit 1
fi

METADATA_FILE="${ARTIFACT_DIR}/BUILD-METADATA.txt"
INSTALL_FILE="${ARTIFACT_DIR}/INSTALL-ANDROID.md"

require_file() {
  if [ ! -s "$1" ]; then
    echo "Arquivo obrigatorio ausente ou vazio: $1" >&2
    exit 1
  fi
}

metadata_value() {
  key="$1"
  awk -F= -v expected_key="${key}" '$1 == expected_key { value=$0; sub("^[^=]*=", "", value); print value; exit }' "${METADATA_FILE}"
}

require_file "${METADATA_FILE}"
require_file "${INSTALL_FILE}"

ARTIFACT_CLASS="$(metadata_value artifact_class)"
KNOWN_LIMITATIONS="$(metadata_value known_limitations)"
APP_DATA_MODE="$(metadata_value app_data_mode)"
API_BASE_URL="$(metadata_value api_base_url)"
GIT_TAGS="$(metadata_value git_tags)"

case "${ARTIFACT_CLASS}" in
  technical-build|preview|functional-homologation|release-candidate|stable-homologation)
    ;;
  *)
    echo "artifact_class invalido ou ausente: ${ARTIFACT_CLASS:-<vazio>}" >&2
    exit 1
    ;;
esac

if [ -z "${KNOWN_LIMITATIONS}" ] || [ "${KNOWN_LIMITATIONS}" = "not_declared" ]; then
  echo "known_limitations precisa ser declarado no BUILD-METADATA.txt." >&2
  exit 1
fi

if ! grep -Eq "Classe do artifact|artifact_class|${ARTIFACT_CLASS}" "${INSTALL_FILE}"; then
  echo "INSTALL-ANDROID.md precisa declarar a classe do artifact." >&2
  exit 1
fi

if ! grep -Eiq "limitacoes conhecidas|limitações conhecidas|known limitations" "${INSTALL_FILE}"; then
  echo "INSTALL-ANDROID.md precisa informar limitacoes conhecidas antes do teste manual." >&2
  exit 1
fi

if [ "${ARTIFACT_CLASS}" = "technical-build" ] || [ "${ARTIFACT_CLASS}" = "preview" ]; then
  if grep -Eiq "release candidate|release-candidate|versao estavel|versão estável" "${INSTALL_FILE}"; then
    echo "Artifact ${ARTIFACT_CLASS} nao pode ser descrito como release candidate ou versao estavel." >&2
    exit 1
  fi
fi

if [ "${ARTIFACT_CLASS}" = "functional-homologation" ] || [ "${ARTIFACT_CLASS}" = "release-candidate" ] || [ "${ARTIFACT_CLASS}" = "stable-homologation" ]; then
  if [ -z "${API_BASE_URL}" ] || [ "${API_BASE_URL}" = "not_configured" ]; then
    echo "Artifact ${ARTIFACT_CLASS} precisa declarar api_base_url real." >&2
    exit 1
  fi
fi

if [ "${ARTIFACT_CLASS}" = "release-candidate" ] || [ "${ARTIFACT_CLASS}" = "stable-homologation" ]; then
  if [ -z "${GIT_TAGS}" ] || [ "${GIT_TAGS}" = "none" ]; then
    echo "Artifact ${ARTIFACT_CLASS} precisa estar associado a tag semantica." >&2
    exit 1
  fi
fi

if [ "${ARTIFACT_CLASS}" = "preview" ] && [ "${APP_DATA_MODE}" != "preview" ]; then
  echo "Artifact preview precisa usar app_data_mode=preview." >&2
  exit 1
fi

echo "Governanca de homologacao mobile aprovada para ${ARTIFACT_DIR} (${ARTIFACT_CLASS})."
