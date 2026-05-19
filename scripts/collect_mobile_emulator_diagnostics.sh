#!/bin/bash
set -euo pipefail

DIAGNOSTICS_DIR="${WORKLINK_MOBILE_DIAGNOSTICS_DIR:-artifacts/mobile-emulator-diagnostics}"
ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-/usr/local/lib/android/sdk}"
ANDROID_EMULATOR_PORT="${ANDROID_EMULATOR_PORT:-5554}"
ANDROID_EMULATOR_LOG_FILE="${ANDROID_EMULATOR_LOG_FILE:-/tmp/worklink-android-emulator.log}"
COMPOSE_ENV_FILE="${COMPOSE_ENV_FILE:-.env}"
ADB="${ANDROID_SDK_ROOT}/platform-tools/adb"
EMULATOR_SERIAL="emulator-${ANDROID_EMULATOR_PORT}"

mkdir -p "$DIAGNOSTICS_DIR"

{
  echo "timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "github_run_id=${GITHUB_RUN_ID:-local}"
  echo "github_sha=${GITHUB_SHA:-unknown}"
  echo "emulator_serial=${EMULATOR_SERIAL}"
  echo "compose_env_file=${COMPOSE_ENV_FILE}"
} >"${DIAGNOSTICS_DIR}/context.txt"

docker ps -a >"${DIAGNOSTICS_DIR}/docker-ps.txt" 2>&1 || true

if [ -f "$COMPOSE_ENV_FILE" ]; then
  docker compose --env-file "$COMPOSE_ENV_FILE" ps >"${DIAGNOSTICS_DIR}/compose-ps.txt" 2>&1 || true
  docker compose --env-file "$COMPOSE_ENV_FILE" logs --no-color worklink-api >"${DIAGNOSTICS_DIR}/worklink-api.log" 2>&1 || true
  docker compose --env-file "$COMPOSE_ENV_FILE" logs --no-color postgres >"${DIAGNOSTICS_DIR}/postgres.log" 2>&1 || true
  docker compose --env-file "$COMPOSE_ENV_FILE" logs --no-color redis >"${DIAGNOSTICS_DIR}/redis.log" 2>&1 || true
  docker compose --env-file "$COMPOSE_ENV_FILE" logs --no-color minio >"${DIAGNOSTICS_DIR}/minio.log" 2>&1 || true
fi

if [ -f "$ANDROID_EMULATOR_LOG_FILE" ]; then
  cp "$ANDROID_EMULATOR_LOG_FILE" "${DIAGNOSTICS_DIR}/android-emulator.log" || true
fi

if [ -x "$ADB" ]; then
  "$ADB" devices -l >"${DIAGNOSTICS_DIR}/adb-devices.txt" 2>&1 || true
  "$ADB" -s "$EMULATOR_SERIAL" shell getprop >"${DIAGNOSTICS_DIR}/android-getprop.txt" 2>&1 || true
  "$ADB" -s "$EMULATOR_SERIAL" shell dumpsys activity activities >"${DIAGNOSTICS_DIR}/android-activity.txt" 2>&1 || true
  "$ADB" -s "$EMULATOR_SERIAL" shell dumpsys package br.com.worklink.mobile >"${DIAGNOSTICS_DIR}/android-package-worklink.txt" 2>&1 || true
  "$ADB" -s "$EMULATOR_SERIAL" logcat -d -v time >"${DIAGNOSTICS_DIR}/android-logcat.txt" 2>&1 || true
fi

find "$DIAGNOSTICS_DIR" -maxdepth 1 -type f -print | sort
