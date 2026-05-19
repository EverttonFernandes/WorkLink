#!/bin/bash
set -e

# search_job.sh — Busca jobs no Jenkins por nome parcial (case-insensitive).
#
# Uso: search_job.sh "<termo>"         (substring única)
#       search_job.sh "termo1 termo2"   (AND: ambos devem estar no nome)
#
# Saída padronizada (últimas linhas):
#   JOB_NAME=<nome_completo>
#   STATUS=FOUND|NOT_FOUND|MULTIPLE_FOUND
#
# Exit Codes:
#   0 = Encontrado (match único)
#   1 = Não encontrado ou múltiplos resultados

# Check dependencies
if ! command -v jq &> /dev/null; then
  echo "Error: 'jq' is required but not installed."
  echo "Install with: sudo apt-get install -y jq"
  exit 1
fi

SEARCH_TERM="$1"

if [ -z "$SEARCH_TERM" ]; then
  echo "❌ Uso: search_job.sh <termo>"
  echo ""
  echo "   Busca jobs no Jenkins por nome parcial (case-insensitive)."
  echo "   Múltiplos termos separados por espaço = AND (todos devem estar no nome)."
  echo ""
  echo "   Exemplos:"
  echo "     search_job.sh \"Business-Graphql\""
  echo "     search_job.sh \"redis-stream\""
  echo "     search_job.sh \"ENTRADA graphql\"       # AND: contém ENTRADA e graphql"
  echo ""
  echo "   💡 Convenção de nomes por time:"
  echo "     ENTRADA_*, AUTOMACAO_*, SUSTENTACAO_*,"
  echo "     IDENTIDADE_*, APLICATIVOS_*, GESTAO_*"
  echo ""
  echo "STATUS=ERROR"
  exit 1
fi

# Validate Environment
if [ -z "$JENKINS_USER" ] || [ -z "$JENKINS_TOKEN" ]; then
  echo "❌ JENKINS_USER e JENKINS_TOKEN devem estar configurados."
  echo "STATUS=ERROR"
  exit 1
fi

JENKINS_URL="${JENKINS_URL:-https://dese-jenkins.umov.me}"

# ─── Buscar jobs (recursivo para suportar folders) ───

RESPONSE=$(curl -s --max-time 15 -u "$JENKINS_USER:$JENKINS_TOKEN" \
  "$JENKINS_URL/api/json?tree=jobs%5Bname,url,jobs%5Bname,url,jobs%5Bname,url%5D%5D%5D" 2>/dev/null)

if [ -z "$RESPONSE" ]; then
  echo "❌ Erro ao consultar API do Jenkins."
  echo "STATUS=ERROR"
  exit 1
fi

# Extrair todos os nomes de jobs (recursivo: 3 níveis de profundidade)
ALL_JOBS=$(echo "$RESPONSE" | jq -r '
  [
    .jobs[]? |
    .name,
    (.jobs[]? | .name),
    (.jobs[]? | .jobs[]? | .name)
  ] | map(select(. != null)) | unique | .[]
' 2>/dev/null)

if [ -z "$ALL_JOBS" ]; then
  echo "❌ Nenhum job retornado pela API do Jenkins."
  echo "STATUS=ERROR"
  exit 1
fi

# ─── Filtrar por match parcial (case-insensitive, multi-termo AND) ───

# Split search term by spaces — each word must match (AND logic)
read -ra TERMS <<< "$SEARCH_TERM"

MATCHES="$ALL_JOBS"
for term in "${TERMS[@]}"; do
  MATCHES=$(echo "$MATCHES" | grep -i "$term" || true)
  if [ -z "$MATCHES" ]; then
    break
  fi
done

if [ -z "$MATCHES" ]; then
  echo "❌ Nenhum job encontrado para '$SEARCH_TERM'"
  echo ""
  echo "   💡 Convenção de nomes por time:"
  echo "     ENTRADA_*, AUTOMACAO_*, SUSTENTACAO_*,"
  echo "     IDENTIDADE_*, APLICATIVOS_*, GESTAO_*"
  echo ""
  echo "   💡 Use múltiplos termos para AND: search_job.sh \"ENTRADA graphql\""
  echo ""
  echo "STATUS=NOT_FOUND"
  exit 1
fi

COUNT=$(echo "$MATCHES" | wc -l)
MAX_RESULTS=80

if [ "$COUNT" -eq 1 ]; then
  echo "✅ Job encontrado: $MATCHES"
  echo ""
  echo "JOB_NAME=$MATCHES"
  echo "STATUS=FOUND"
  exit 0
elif [ "$COUNT" -le "$MAX_RESULTS" ]; then
  echo "⚠️  $COUNT jobs encontrados para '$SEARCH_TERM':"
  echo "$MATCHES" | nl -ba
  echo ""
  echo "   💡 Para refinar: inclua o prefixo do time (ENTRADA_, AUTOMACAO_, IDENTIDADE_)"
  echo "      ou use múltiplos termos: search_job.sh \"ENTRADA graphql\""
  echo ""
  echo "COUNT=$COUNT"
  echo "STATUS=MULTIPLE_FOUND"
  exit 1
else
  echo "⚠️  $COUNT jobs encontrados para '$SEARCH_TERM' (mostrando os $MAX_RESULTS primeiros):"
  echo "$MATCHES" | head -n "$MAX_RESULTS" | nl -ba
  echo "   ... e mais $((COUNT - MAX_RESULTS)) jobs"
  echo ""
  echo "   💡 Para refinar: inclua o prefixo do time (ENTRADA_, AUTOMACAO_, IDENTIDADE_)"
  echo "      ou use múltiplos termos: search_job.sh \"ENTRADA graphql\""
  echo ""
  echo "COUNT=$COUNT"
  echo "STATUS=MULTIPLE_FOUND"
  exit 1
fi
