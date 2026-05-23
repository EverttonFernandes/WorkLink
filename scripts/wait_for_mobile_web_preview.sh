#!/bin/sh
set -eu

preview_port="${WORKLINK_MOBILE_WEB_PREVIEW_PORT:-18080}"
preview_url="${WORKLINK_MOBILE_WEB_PREVIEW_URL:-http://localhost:${preview_port}}"
max_attempts="${WORKLINK_MOBILE_WEB_PREVIEW_MAX_ATTEMPTS:-60}"
sleep_seconds="${WORKLINK_MOBILE_WEB_PREVIEW_SLEEP_SECONDS:-2}"

python3 - "$preview_url" "$max_attempts" "$sleep_seconds" <<'PY'
import sys
import time
import urllib.request

preview_url = sys.argv[1].rstrip('/')
max_attempts = int(sys.argv[2])
sleep_seconds = float(sys.argv[3])
required_paths = ('', '/main.dart.js', '/flutter_bootstrap.js')

for attempt in range(1, max_attempts + 1):
    ready = True
    for path in required_paths:
        try:
            with urllib.request.urlopen(f'{preview_url}{path}') as response:
                if response.status != 200:
                    ready = False
                    break
        except Exception:
            ready = False
            break

    if ready:
        print(f'Preview web pronto em {preview_url}')
        sys.exit(0)

    time.sleep(sleep_seconds)

print(
    f'Preview web nao ficou pronto em {preview_url} '
    f'apos {max_attempts} tentativas.',
    file=sys.stderr,
)
sys.exit(1)
PY
