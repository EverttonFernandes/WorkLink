#!/bin/bash
# Script para configuração interativa do SonarQube no bashrc do usuário.

echo "⚙️  Configuração do Sonar Runner"
echo ""

# Verifica dependências básicas
for cmd in grep sed; do
  if ! command -v $cmd &> /dev/null; then
    echo "❌ Erro: '$cmd' é necessário, mas não está instalado."
    exit 1
  fi
done

# Solicita o token de forma segura (sem echo)
read -sp "🔑 Digite seu User Token do SonarQube: " S_TOKEN
echo ""
echo ""

BASHRC_FILE="$HOME/.bashrc"

# Configura SONAR_AUTH_TOKEN
if grep -q "export SONAR_AUTH_TOKEN=" "$BASHRC_FILE"; then
    sed -i "s|export SONAR_AUTH_TOKEN=.*|export SONAR_AUTH_TOKEN=\"$S_TOKEN\"|" "$BASHRC_FILE"
else
    echo "export SONAR_AUTH_TOKEN=\"$S_TOKEN\"" >> "$BASHRC_FILE"
fi

# Aplica as variáveis globalmente na sessão atual
export SONAR_AUTH_TOKEN="$S_TOKEN"

echo "✅ Credencial salva no $BASHRC_FILE"
echo "🔄 Recarregando variáveis de ambiente..."

if [ -f "$BASHRC_FILE" ]; then
    source "$BASHRC_FILE" 2>/dev/null || true
fi

echo ""
echo "🔥 SonarQube configurado com sucesso!"
echo "⚠️  Dica: Se você não rodou este script com 'source' (ex: \`source configure.sh\`), as variáveis podem não estar logo disponíveis na sua aba atual. Nesse caso, basta abrir uma aba nova do terminal ou digitar 'source ~/.bashrc'."
