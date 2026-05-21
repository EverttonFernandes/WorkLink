#!/usr/bin/env sh
set -eu

API_BASE_URL="${1:-${MOBILE_HOMOLOGATION_API_BASE_URL:-}}"
ALLOWED_HOSTS="${WORKLINK_HOMOLOGATION_ALLOWED_HOSTS:-}"

if [ -z "${API_BASE_URL}" ]; then
  echo "URL de homologacao nao informada." >&2
  exit 1
fi

if [ -z "${ALLOWED_HOSTS}" ]; then
  echo "Allowlist de homologacao nao configurada. Defina WORKLINK_HOMOLOGATION_ALLOWED_HOSTS." >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 nao encontrado para validar URL de homologacao." >&2
  exit 1
fi

HOST="$(
  API_BASE_URL="${API_BASE_URL}" python3 - <<'PY'
import ipaddress
import os
import sys
from urllib.parse import urlparse

url = os.environ["API_BASE_URL"]
parsed = urlparse(url)

if parsed.scheme != "https":
    print("URL de homologacao invalida: use HTTPS.", file=sys.stderr)
    sys.exit(1)

if not parsed.hostname:
    print("URL de homologacao invalida: host ausente.", file=sys.stderr)
    sys.exit(1)

host = parsed.hostname.lower().rstrip(".")

if ":" in host:
    print("URL de homologacao invalida: IPv6 nao e permitido para artifact promovivel.", file=sys.stderr)
    sys.exit(1)

if host == "localhost" or host.endswith(".local"):
    print("URL de homologacao invalida: host local nao pode gerar artifact promovivel.", file=sys.stderr)
    sys.exit(1)

try:
    ip_address = ipaddress.ip_address(host)
except ValueError:
    pass
else:
    if (
        ip_address.is_private
        or ip_address.is_loopback
        or ip_address.is_link_local
        or ip_address.is_reserved
        or ip_address.is_multicast
        or ip_address.is_unspecified
    ):
        print("URL de homologacao invalida: IP local/privado nao pode gerar artifact promovivel.", file=sys.stderr)
        sys.exit(1)

print(host)
PY
)"

matched=false
OLD_IFS="${IFS}"
IFS=","
for allowed_host in ${ALLOWED_HOSTS}; do
  normalized_allowed_host="$(
    printf '%s' "${allowed_host}" \
      | tr '[:upper:]' '[:lower:]' \
      | sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s/\.$//'
  )"
  if [ "${HOST}" = "${normalized_allowed_host}" ]; then
    matched=true
    break
  fi
done
IFS="${OLD_IFS}"

if [ "${matched}" != "true" ]; then
  echo "URL de homologacao invalida: host ${HOST} fora da allowlist." >&2
  exit 1
fi

echo "URL de homologacao aprovada: ${HOST}."
