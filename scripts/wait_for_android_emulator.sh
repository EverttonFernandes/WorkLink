#!/bin/sh
set -eu

COMPOSE_ENV_FILE="${COMPOSE_ENV_FILE:-.env}"
SERVICE_NAME="${SERVICE_NAME:-android-emulator}"
MAX_ATTEMPTS="${MAX_ATTEMPTS:-180}"
SLEEP_SECONDS="${SLEEP_SECONDS:-5}"

attempt=1
while [ "${attempt}" -le "${MAX_ATTEMPTS}" ]; do
  container_id="$(WORKLINK_ENV_FILE="${COMPOSE_ENV_FILE}" docker compose --env-file "${COMPOSE_ENV_FILE}" ps -q "${SERVICE_NAME}")"
  if [ -n "${container_id}" ] && docker exec -u 0 "${container_id}" sh -lc '
    status="$(cat device_status 2>/dev/null | tr "[:upper:]" "[:lower:]" || true)"
    adb devices | grep -Eq "emulator-[0-9]+[[:space:]]+device" && [ "$status" = "running" ]
  '; then
    echo "Android emulator pronto."
    exit 0
  fi

  echo "Aguardando Android emulator ficar pronto (${attempt}/${MAX_ATTEMPTS})..."
  sleep "${SLEEP_SECONDS}"
  attempt=$((attempt + 1))
done

echo "Android emulator nao ficou pronto a tempo." >&2
exit 1
