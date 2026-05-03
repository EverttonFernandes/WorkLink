#!/bin/sh
set -eu

if ! find src -type f -name '*.spec.js' 2>/dev/null | grep -q .; then
  echo 'N/A: testes funcionais ainda nao possuem cenarios reais.'
  exit 0
fi

npm ci
npm test
