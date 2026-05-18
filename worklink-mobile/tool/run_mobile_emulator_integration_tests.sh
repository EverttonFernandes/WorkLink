#!/bin/sh
set -eu

DEVICE_ID="${DEVICE_ID:-}"
API_BASE_URL="${API_BASE_URL:-http://10.0.2.2:8080}"

flutter pub get

if find test/integration -type f -name '*_test.dart' | grep -q .; then
  flutter test --dart-define="API_BASE_URL=${API_BASE_URL}" test/integration
fi

if ! find integration_test -type f -name '*_test.dart' | grep -q .; then
  echo 'N/A: testes de integracao mobile ainda nao foram criados.'
  exit 0
fi

if [ -n "${DEVICE_ID}" ]; then
  flutter test integration_test -d "${DEVICE_ID}"
  exit 0
fi

flutter test integration_test
