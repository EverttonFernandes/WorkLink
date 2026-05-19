#!/bin/bash
# Script para configuração interativa do Jenkins no bashrc do usuário.

echo "⚙️  Configuração do Jenkins Connector"
echo ""

# Verifica dependências básicas
for cmd in grep sed; do
  if ! command -v $cmd &> /dev/null; then
    echo "❌ Erro: '$cmd' é necessário, mas não está instalado."
    exit 1
  fi
done

# Solicita o nome de usuário interativamente
read -p "👤 Digite seu usuário do Jenkins (ex: alan.turing@umov.me): " J_USER

# Solicita o token de forma segura (sem echo)
echo "🔗 Para criar seu token, acesse: https://dese-jenkins.umov.me/user/${J_USER}/configure"
read -sp "🔑 Digite seu API Token do Jenkins: " J_TOKEN
echo ""
echo ""

BASHRC_FILE="$HOME/.bashrc"

# Configura JENKINS_USER
if grep -q "export JENKINS_USER=" "$BASHRC_FILE"; then
    sed -i "s/export JENKINS_USER=.*/export JENKINS_USER=\"$J_USER\"/" "$BASHRC_FILE"
else
    echo "export JENKINS_USER=\"$J_USER\"" >> "$BASHRC_FILE"
fi

# Configura JENKINS_TOKEN
if grep -q "export JENKINS_TOKEN=" "$BASHRC_FILE"; then
    sed -i "s/export JENKINS_TOKEN=.*/export JENKINS_TOKEN=\"$J_TOKEN\"/" "$BASHRC_FILE"
else
    echo "export JENKINS_TOKEN=\"$J_TOKEN\"" >> "$BASHRC_FILE"
fi

# Aplica as variáveis globalmente na sessão atual
export JENKINS_USER="$J_USER"
export JENKINS_TOKEN="$J_TOKEN"

echo "✅ Credenciais salvas no $BASHRC_FILE"
echo "🔄 Recarregando variáveis de ambiente..."

if [ -f "$BASHRC_FILE" ]; then
    source "$BASHRC_FILE" 2>/dev/null || true
fi

echo ""
echo "🔥 Jenkins configurado com sucesso!"
echo "⚠️  Dica: Se você não rodou este script com 'source' (ex: \`source configure.sh\`), as variáveis podem não estar logo disponíveis na sua aba atual. Nesse caso, basta abrir uma aba nova do terminal ou digitar 'source ~/.bashrc'."
