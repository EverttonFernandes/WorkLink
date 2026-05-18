#!/bin/sh
set -eu

COMPOSE_ENV_FILE="${COMPOSE_ENV_FILE:-.env}"
SERVICE_NAME="${SERVICE_NAME:-android-emulator}"
APK_PATH="${APK_PATH:-/workspace/worklink-mobile/build/app/outputs/flutter-apk/app-debug.apk}"
PACKAGE_NAME="${PACKAGE_NAME:-br.com.worklink.mobile}"

container_id="$(WORKLINK_ENV_FILE="${COMPOSE_ENV_FILE}" docker compose --env-file "${COMPOSE_ENV_FILE}" ps -q "${SERVICE_NAME}")"
[ -n "${container_id}" ]

docker exec -u 0 "${container_id}" sh -lc "
  test -f '${APK_PATH}'
  adb devices | grep -Eq 'emulator-[0-9]+[[:space:]]+device'
  adb install -r '${APK_PATH}'
  adb shell monkey -p '${PACKAGE_NAME}' -c android.intent.category.LAUNCHER 1
"
