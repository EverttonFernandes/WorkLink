#!/bin/bash
set -euo pipefail

ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-/usr/local/lib/android/sdk}"
ANDROID_AVD_NAME="${ANDROID_AVD_NAME:-worklink-ci-api30}"
ANDROID_API_LEVEL="${ANDROID_API_LEVEL:-30}"
ANDROID_SYSTEM_IMAGE_TARGET="${ANDROID_SYSTEM_IMAGE_TARGET:-google_apis}"
ANDROID_SYSTEM_IMAGE_ARCH="${ANDROID_SYSTEM_IMAGE_ARCH:-x86_64}"
ANDROID_EMULATOR_DEVICE="${ANDROID_EMULATOR_DEVICE:-pixel}"
ANDROID_EMULATOR_MEMORY_MB="${ANDROID_EMULATOR_MEMORY_MB:-2048}"
ANDROID_EMULATOR_CORES="${ANDROID_EMULATOR_CORES:-2}"
ANDROID_EMULATOR_PORT="${ANDROID_EMULATOR_PORT:-5554}"
ANDROID_EMULATOR_BOOT_TIMEOUT_SECONDS="${ANDROID_EMULATOR_BOOT_TIMEOUT_SECONDS:-900}"
ANDROID_EMULATOR_LOG_FILE="${ANDROID_EMULATOR_LOG_FILE:-/tmp/worklink-android-emulator.log}"

SDKMANAGER="${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager"
AVDMANAGER="${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/avdmanager"
ADB="${ANDROID_SDK_ROOT}/platform-tools/adb"
EMULATOR="${ANDROID_SDK_ROOT}/emulator/emulator"
SYSTEM_IMAGE="system-images;android-${ANDROID_API_LEVEL};${ANDROID_SYSTEM_IMAGE_TARGET};${ANDROID_SYSTEM_IMAGE_ARCH}"

for required_command in "$SDKMANAGER" "$AVDMANAGER" "$ADB" "$EMULATOR"; do
  if [ ! -x "$required_command" ]; then
    echo "❌ Android SDK command not found or not executable: ${required_command}" >&2
    exit 1
  fi
done

yes | "$SDKMANAGER" --licenses >/dev/null
"$SDKMANAGER" \
  "platform-tools" \
  "platforms;android-${ANDROID_API_LEVEL}" \
  "emulator" \
  "${SYSTEM_IMAGE}" >/dev/null

echo "no" | "$AVDMANAGER" create avd \
  --force \
  --name "$ANDROID_AVD_NAME" \
  --device "$ANDROID_EMULATOR_DEVICE" \
  --package "$SYSTEM_IMAGE" >/dev/null

"$ADB" start-server >/dev/null

nohup "$EMULATOR" \
  -avd "$ANDROID_AVD_NAME" \
  -port "$ANDROID_EMULATOR_PORT" \
  -accel on \
  -no-window \
  -gpu swiftshader_indirect \
  -no-snapshot \
  -noaudio \
  -no-boot-anim \
  -camera-back none \
  -memory "$ANDROID_EMULATOR_MEMORY_MB" \
  -cores "$ANDROID_EMULATOR_CORES" \
  -netfast >"$ANDROID_EMULATOR_LOG_FILE" 2>&1 &

EMULATOR_SERIAL="emulator-${ANDROID_EMULATOR_PORT}"

"$ADB" -s "$EMULATOR_SERIAL" wait-for-device >/dev/null 2>&1 || true

deadline=$((SECONDS + ANDROID_EMULATOR_BOOT_TIMEOUT_SECONDS))
while [ "$SECONDS" -lt "$deadline" ]; do
  boot_completed="$("$ADB" -s "$EMULATOR_SERIAL" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r' || true)"
  if [ "$boot_completed" = "1" ]; then
    "$ADB" -s "$EMULATOR_SERIAL" shell settings put global window_animation_scale 0 >/dev/null 2>&1 || true
    "$ADB" -s "$EMULATOR_SERIAL" shell settings put global transition_animation_scale 0 >/dev/null 2>&1 || true
    "$ADB" -s "$EMULATOR_SERIAL" shell settings put global animator_duration_scale 0 >/dev/null 2>&1 || true
    "$ADB" -s "$EMULATOR_SERIAL" shell input keyevent 3 >/dev/null 2>&1 || true
    echo "✅ Android emulator iniciado com sucesso em ${EMULATOR_SERIAL}"
    echo "EMULATOR_SERIAL=${EMULATOR_SERIAL}"
    exit 0
  fi
  echo "Aguardando boot do Android emulator (${EMULATOR_SERIAL})..."
  sleep 5
done

echo "❌ Android emulator nao concluiu boot a tempo." >&2
echo "--- emulator log ---" >&2
tail -n 200 "$ANDROID_EMULATOR_LOG_FILE" >&2 || true
exit 1
