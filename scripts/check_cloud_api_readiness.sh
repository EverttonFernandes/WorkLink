#!/usr/bin/env sh
set -eu

api_base_url="${1:-${WORKLINK_CLOUD_API_BASE_URL:-}}"

if [ -z "${api_base_url}" ]; then
  echo "Informe a URL HTTPS da API cloud." >&2
  exit 1
fi

case "${api_base_url}" in
  https://localhost*|https://127.0.0.1*|https://0.0.0.0*|http://*|*trycloudflare.com*)
    echo "URL rejeitada para loja: use uma URL HTTPS estavel, nao localhost, HTTP ou tunnel temporario." >&2
    exit 1
    ;;
  https://*)
    ;;
  *)
    echo "URL rejeitada: a API de loja precisa usar HTTPS." >&2
    exit 1
    ;;
esac

readiness_url="${api_base_url%/}/actuator/health/readiness"
response_body="$(mktemp)"

if ! http_status="$(curl -sS -m 10 -o "${response_body}" -w "%{http_code}" "${readiness_url}")"; then
  echo "Nao foi possivel conectar na API cloud em ${readiness_url}." >&2
  cat "${response_body}" >&2 || true
  rm -f "${response_body}"
  exit 1
fi

if [ "${http_status}" != "200" ]; then
  echo "Readiness falhou com HTTP ${http_status} em ${readiness_url}." >&2
  cat "${response_body}" >&2 || true
  rm -f "${response_body}"
  exit 1
fi

if ! grep -q '"status"[[:space:]]*:[[:space:]]*"UP"' "${response_body}"; then
  echo "Readiness respondeu 200, mas nao indicou status UP." >&2
  cat "${response_body}" >&2 || true
  rm -f "${response_body}"
  exit 1
fi

rm -f "${response_body}"
echo "API cloud pronta: ${readiness_url}"
