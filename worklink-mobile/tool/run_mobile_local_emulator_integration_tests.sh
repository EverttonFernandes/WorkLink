#!/bin/sh
set -eu

ADB_TARGET="${ADB_TARGET:-android-emulator:5555}"
DEVICE_ID="${DEVICE_ID:-${ADB_TARGET}}"
API_BASE_URL="${API_BASE_URL:-http://worklink-api:8080}"

flutter pub get

adb connect "${ADB_TARGET}" >/dev/null 2>&1 || true
adb devices | grep -F "${ADB_TARGET}" >/dev/null

if find test/integration -type f -name '*_test.dart' | grep -q .; then
  flutter test --dart-define="API_BASE_URL=${API_BASE_URL}" test/integration
fi

if ! find integration_test -type f -name '*_test.dart' | grep -q .; then
  echo 'N/A: testes de integracao mobile ainda nao foram criados.'
  exit 0
fi

flutter test integration_test -d "${DEVICE_ID}"
