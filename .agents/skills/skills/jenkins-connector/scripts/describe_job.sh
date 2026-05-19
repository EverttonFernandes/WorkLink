#!/bin/bash
set -e

# describe_job.sh — Descreve um job do Jenkins: parâmetros, tipos, defaults e choices.
#
# Uso: describe_job.sh "<JobName>"
#
# Saída padronizada (última linha):
#   STATUS=DESCRIBED
#
# Exit Codes:
#   0 = Job descrito com sucesso
#   1 = Erro (job não encontrado, sem credenciais, etc.)

# Check dependencies
if ! command -v jq &> /dev/null; then
  echo "Error: 'jq' is required but not installed."
  echo "Install with: sudo apt-get install -y jq"
  exit 1
fi

JOB_NAME="$1"

if [ -z "$JOB_NAME" ]; then
  echo "❌ Uso: describe_job.sh <JobName>"
  echo ""
  echo "   Descreve os parâmetros de um job do Jenkins."
  echo "   💡 Use search_job.sh para encontrar o nome do job."
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

# ─── Buscar informações do job ───

RESPONSE=$(curl -s --max-time 15 -w "\nHTTP_CODE:%{http_code}" \
  -u "$JENKINS_USER:$JENKINS_TOKEN" \
  "$JENKINS_URL/job/$JOB_NAME/api/json" 2>/dev/null)

HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | awk -F: '{print $2}')
BODY=$(echo "$RESPONSE" | sed '/HTTP_CODE:.*/d')

if [ "$HTTP_CODE" = "404" ]; then
  echo "❌ Job '$JOB_NAME' não encontrado (HTTP 404)."
  echo "   💡 Use search_job.sh para buscar pelo nome parcial."
  echo "STATUS=NOT_FOUND"
  exit 1
elif [ "$HTTP_CODE" != "200" ]; then
  echo "❌ Erro ao acessar job '$JOB_NAME' (HTTP $HTTP_CODE)."
  echo "STATUS=ERROR"
  exit 1
fi

# ─── Extrair parâmetros ───

PARAMS=$(echo "$BODY" | jq -r '
  [.property[]? | select(.parameterDefinitions) | .parameterDefinitions[]?] // []
' 2>/dev/null)

PARAM_COUNT=$(echo "$PARAMS" | jq 'length' 2>/dev/null)

# ─── Exibir informações do job ───

echo "📋 Job: $JOB_NAME"
echo "   URL: $JENKINS_URL/job/$JOB_NAME/"
echo ""

if [ "$PARAM_COUNT" = "0" ] || [ -z "$PARAM_COUNT" ]; then
  echo "   ℹ️  Este job não possui parâmetros configurados."
  echo ""
  echo "   Uso: trigger_job.sh \"$JOB_NAME\""
  echo ""
  echo "STATUS=DESCRIBED"
  exit 0
fi

echo "🔧 Parâmetros ($PARAM_COUNT):"
echo ""

# ─── Montar tabela e exemplo de uso ───

USAGE_PARTS=""

echo "$PARAMS" | jq -c '.[]' | while IFS= read -r param; do
  NAME=$(echo "$param" | jq -r '.name')
  TYPE=$(echo "$param" | jq -r '.type')
  DEFAULT=$(echo "$param" | jq -r '.defaultParameterValue.value // "—"')
  DESC=$(echo "$param" | jq -r '.description // "—"')
  CHOICES=$(echo "$param" | jq -r 'if .choices then .choices | join(", ") else "—" end')

  # Formatar tipo para leitura humana
  case "$TYPE" in
    BooleanParameterDefinition) FRIENDLY_TYPE="Boolean" ;;
    StringParameterDefinition)  FRIENDLY_TYPE="String" ;;
    ChoiceParameterDefinition)  FRIENDLY_TYPE="Choice" ;;
    PT_BRANCH_TAG)              FRIENDLY_TYPE="Branch/Tag" ;;
    TextParameterDefinition)    FRIENDLY_TYPE="Text" ;;
    *)                          FRIENDLY_TYPE="$TYPE" ;;
  esac

  echo "   📌 $NAME"
  echo "      Tipo:    $FRIENDLY_TYPE"
  echo "      Default: $DEFAULT"
  [ "$DESC" != "—" ] && echo "      Desc:    $DESC"
  [ "$CHOICES" != "—" ] && echo "      Opções:  [$CHOICES]"
  echo ""
done

# ─── Montar exemplo de uso ───

EXAMPLE=$(echo "$PARAMS" | jq -r '
  [.[] | "\(.name)=\(.defaultParameterValue.value // "")"]
  | join("&")
')

echo "💡 Exemplo de uso:"
echo "   trigger_job.sh \"$JOB_NAME\" \"$EXAMPLE\""
echo ""
echo "STATUS=DESCRIBED"
