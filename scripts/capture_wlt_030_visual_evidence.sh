#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMP_WORKDIR="/tmp/worklink-mobile-wlt030-evidence"
EVIDENCE_DIR="${REPO_ROOT}/docs/tasks/WLT-030/evidence/generated"
GOLDENS_DIR="${TEMP_WORKDIR}/test/widget/visual/goldens"

rm -rf "${TEMP_WORKDIR}"
mkdir -p "${TEMP_WORKDIR}" "${EVIDENCE_DIR}"

rsync -a \
  --exclude '.dart_tool' \
  --exclude 'build' \
  --exclude 'coverage' \
  --exclude 'android/.gradle' \
  "${REPO_ROOT}/worklink-mobile/" \
  "${TEMP_WORKDIR}/"

pushd "${TEMP_WORKDIR}" >/dev/null
/home/everton/flutter/bin/flutter test --update-goldens \
  test/widget/visual/wlt_030_visual_evidence_test.dart
popd >/dev/null

find "${EVIDENCE_DIR}" -maxdepth 1 -type f -name '*.png' -delete
cp -f "${GOLDENS_DIR}"/*.png "${EVIDENCE_DIR}/"

printf '\nEvidencias geradas em:\n'
find "${EVIDENCE_DIR}" -maxdepth 1 -type f | sort
