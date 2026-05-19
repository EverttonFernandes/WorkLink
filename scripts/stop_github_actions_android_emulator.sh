#!/bin/bash
set -euo pipefail

ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-/usr/local/lib/android/sdk}"
ANDROID_EMULATOR_PORT="${ANDROID_EMULATOR_PORT:-5554}"
ADB="${ANDROID_SDK_ROOT}/platform-tools/adb"
EMULATOR_SERIAL="emulator-${ANDROID_EMULATOR_PORT}"

if [ -x "$ADB" ]; then
  "$ADB" -s "$EMULATOR_SERIAL" emu kill >/dev/null 2>&1 || true
fi

pkill -f "emulator.*-port ${ANDROID_EMULATOR_PORT}" >/dev/null 2>&1 || true
pkill -f "qemu-system.*${ANDROID_EMULATOR_PORT}" >/dev/null 2>&1 || true
