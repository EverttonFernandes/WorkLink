#!/bin/bash
set -euo pipefail

echo "⚙️  Configuração do githubActions-connector"
echo ""
echo "Crie um token em: https://github.com/settings/tokens"
echo "Escopos mínimos recomendados: actions:write, contents:read, metadata:read"
echo ""

read -rsp "🔑 Digite seu GITHUB_TOKEN: " GH_TOKEN
echo ""

BASHRC_FILE="${HOME}/.bashrc"

if grep -q 'export GITHUB_TOKEN=' "$BASHRC_FILE" 2>/dev/null; then
  sed -i "s#export GITHUB_TOKEN=.*#export GITHUB_TOKEN=\"${GH_TOKEN}\"#" "$BASHRC_FILE"
else
  echo "export GITHUB_TOKEN=\"${GH_TOKEN}\"" >>"$BASHRC_FILE"
fi

export GITHUB_TOKEN="$GH_TOKEN"

echo "✅ GITHUB_TOKEN salvo em ${BASHRC_FILE}"
echo "💡 Abra um terminal novo ou rode: source ~/.bashrc"
