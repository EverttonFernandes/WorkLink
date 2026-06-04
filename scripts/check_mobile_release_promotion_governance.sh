#!/usr/bin/env sh
set -eu

REPOSITORY_ROOT="${1:-.}"
RELEASE_DOC="${REPOSITORY_ROOT}/docs/operacao/mobile-release-promocao-rollback.md"
RELEASE_GUIDE="${REPOSITORY_ROOT}/docs/release/release-mobile.md"
PROMOTION_SCRIPT="${REPOSITORY_ROOT}/scripts/promote_android_homologation_artifact.sh"
MAKEFILE="${REPOSITORY_ROOT}/Makefile"
CI_WORKFLOW="${REPOSITORY_ROOT}/.github/workflows/ci.yml"

require_file() {
  if [ ! -f "$1" ]; then
    echo "Arquivo obrigatorio ausente para governanca de promocao mobile: $1" >&2
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
  "${RELEASE_DOC}" \
  "${RELEASE_GUIDE}" \
  "${PROMOTION_SCRIPT}" \
  "${MAKEFILE}" \
  "${CI_WORKFLOW}"; do
  require_file "${required_file}"
done

for expected_term in \
  'Teste interno' \
  'Beta' \
  'Producao' \
  'Rollback' \
  'tag' \
  'commit' \
  'artifact' \
  'checksum' \
  'CI obrigatoria' \
  'CD.*manual' \
  'Bloqueadores de publicacao'; do
  require_pattern "${RELEASE_DOC}" "${expected_term}" \
    "Documento de promocao mobile nao cobre o termo obrigatorio: ${expected_term}"
done

for metadata_gate in \
  'BUILD-METADATA.txt' \
  'SHA256SUMS' \
  'app_data_mode=homologation-fullstack' \
  'artifact=android-homologation-candidate' \
  'build_type=release' \
  'signing=android_homologation_key'; do
  require_pattern "${PROMOTION_SCRIPT}" "${metadata_gate}" \
    "Script de promocao Android nao valida metadado obrigatorio: ${metadata_gate}"
done

require_pattern "${MAKEFILE}" '^mobile-release-promotion-governance:' \
  "Makefile precisa expor o target mobile-release-promotion-governance."
require_pattern "${CI_WORKFLOW}" 'Mobile release promotion governance gate' \
  "Workflow CI precisa executar o gate de promocao/rollback mobile."
require_pattern "${RELEASE_GUIDE}" 'mobile-release-promocao-rollback.md' \
  "Guia de release mobile precisa apontar para o procedimento de promocao/rollback."

echo "Governanca de promocao e rollback mobile validada."
