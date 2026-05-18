#!/bin/sh
set -eu

DEVICE_ID="${DEVICE_ID:-}"
CONTRACT_TEST_API_BASE_URL="${CONTRACT_TEST_API_BASE_URL:-${API_BASE_URL:-http://localhost:8080}}"
DEVICE_API_BASE_URL="${DEVICE_API_BASE_URL:-${API_BASE_URL:-http://10.0.2.2:8080}}"
ANDROID_READY_MAX_ATTEMPTS="${ANDROID_READY_MAX_ATTEMPTS:-180}"
ANDROID_READY_SLEEP_SECONDS="${ANDROID_READY_SLEEP_SECONDS:-2}"

wait_for_android_runtime_services() {
  if [ -z "${DEVICE_ID}" ]; then
    return 0
  fi

  adb -s "${DEVICE_ID}" wait-for-device >/dev/null 2>&1

  attempt=1
  while [ "${attempt}" -le "${ANDROID_READY_MAX_ATTEMPTS}" ]; do
    boot_completed="$(adb -s "${DEVICE_ID}" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r' || true)"
    package_manager_ready="false"
    activity_manager_ready="false"

    if adb -s "${DEVICE_ID}" shell pm path android >/dev/null 2>&1; then
      package_manager_ready="true"
    fi

    if adb -s "${DEVICE_ID}" shell cmd activity get-config >/dev/null 2>&1; then
      activity_manager_ready="true"
    fi

    if [ "${boot_completed}" = "1" ] && [ "${package_manager_ready}" = "true" ] && [ "${activity_manager_ready}" = "true" ]; then
      adb -s "${DEVICE_ID}" shell input keyevent 82 >/dev/null 2>&1 || true
      adb -s "${DEVICE_ID}" shell input keyevent 3 >/dev/null 2>&1 || true
      echo "Android emulator com runtime pronto."
      return 0
    fi

    echo "Aguardando runtime Android ficar pronto (${attempt}/${ANDROID_READY_MAX_ATTEMPTS})..."
    sleep "${ANDROID_READY_SLEEP_SECONDS}"
    attempt=$((attempt + 1))
  done

  echo "Android emulator nao disponibilizou package/activity manager a tempo." >&2
  adb -s "${DEVICE_ID}" shell getprop 2>/dev/null | grep -E 'boot|init\\.svc' || true
  exit 1
}

flutter pub get

if find test/integration -type f -name '*_test.dart' | grep -q .; then
  flutter test --dart-define="API_BASE_URL=${CONTRACT_TEST_API_BASE_URL}" test/integration
fi

if ! find integration_test -type f -name '*_test.dart' | grep -q .; then
  echo 'N/A: testes de integracao mobile ainda nao foram criados.'
  exit 0
fi

if [ -n "${DEVICE_ID}" ]; then
  wait_for_android_runtime_services
  for integration_test_file in integration_test/*_test.dart; do
    flutter drive \
      --driver=test_driver/integration_test.dart \
      --target="${integration_test_file}" \
      --device-timeout=1200 \
      --no-dds \
      -d "${DEVICE_ID}" \
      --dart-define="API_BASE_URL=${DEVICE_API_BASE_URL}"
  done
  exit 0
fi

flutter test --dart-define="API_BASE_URL=${DEVICE_API_BASE_URL}" integration_test
