#!/bin/sh
set -eu

MINIMUM_FREE_GB="${MINIMUM_FREE_GB:-16}"
WORKDIR="${WORKDIR:-$(pwd)}"

if [ ! -e /dev/kvm ]; then
  echo "Prerequisito ausente: /dev/kvm nao esta disponivel no host." >&2
  exit 1
fi

available_kb="$(df -Pk "${WORKDIR}" | awk 'NR==2 { print $4 }')"
required_kb="$((MINIMUM_FREE_GB * 1024 * 1024))"

if [ "${available_kb}" -lt "${required_kb}" ]; then
  echo "Espaco insuficiente para o Android Emulator em Docker." >&2
  echo "Livre no host: $((available_kb / 1024 / 1024)) GB" >&2
  echo "Minimo recomendado: ${MINIMUM_FREE_GB} GB" >&2
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker nao esta acessivel no host." >&2
  exit 1
fi

echo "Prerequisitos do Android Emulator atendidos."
