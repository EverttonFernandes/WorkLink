#!/bin/sh
set -eu

preview_host="${WORKLINK_MOBILE_WEB_PREVIEW_HOST:-0.0.0.0}"
preview_port="${WORKLINK_MOBILE_WEB_PREVIEW_PORT:-18080}"
preview_data_enabled="${WORKLINK_MOBILE_WEB_USE_PREVIEW_DATA:-true}"

if [ ! -f web/index.html ]; then
  echo 'Flutter Web ainda nao esta habilitado no projeto.' >&2
  exit 1
fi

flutter pub get

exec flutter run \
  -d web-server \
  --web-hostname "${preview_host}" \
  --web-port "${preview_port}" \
  --dart-define="WORKLINK_USE_PREVIEW_DATA=${preview_data_enabled}"
