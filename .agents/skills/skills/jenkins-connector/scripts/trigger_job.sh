#!/bin/bash
set -e

# Check dependencies
if ! command -v jq &> /dev/null; then
  echo "Error: 'jq' is required but not installed."
  echo "Install with: sudo apt-get install -y jq"
  exit 1
fi

# Inputs
JOB_NAME="$1"
# Parameters string format: "PARAM1=Value1&PARAM2=Value2"
PARAMETERS="$2"

# Optional flags
FORCE=false
for arg in "$@"; do
  [ "$arg" = "--force" ] && FORCE=true
done

# Validate Environment
if [ -z "$JENKINS_USER" ] || [ -z "$JENKINS_TOKEN" ]; then
  echo "Error: JENKINS_USER and JENKINS_TOKEN must be set."
  exit 1
fi

if [ -z "$JOB_NAME" ]; then
  echo "Usage: ./trigger_job.sh \"<JobName>\" \"<ParametersString>\" [--force]"
  echo ""
  echo "  --force:  Stop active build for same branch before triggering a new one"
  exit 1
fi

JENKINS_URL="${JENKINS_URL:-https://dese-jenkins.umov.me}"

# ─── Validar existência do job ───

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

JOB_HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
  --user "${JENKINS_USER}:${JENKINS_TOKEN}" \
  "${JENKINS_URL}/job/${JOB_NAME}/api/json")

if [ "$JOB_HTTP_STATUS" = "404" ]; then
  echo "❌ Job '$JOB_NAME' não encontrado no Jenkins (HTTP 404)."
  echo "   💡 Se o nome está parcial, use search_job.sh para buscar: search_job.sh \"$JOB_NAME\""
  exit 3
elif [ "$JOB_HTTP_STATUS" != "200" ]; then
  echo "❌ Erro ao acessar job '$JOB_NAME' (HTTP $JOB_HTTP_STATUS)."
  exit 3
fi

# ─── Extrair branch dos parâmetros ───

# Tenta extrair CHECKOUT=xxx dos parâmetros
DESIRED_BRANCH=""
if [ -n "$PARAMETERS" ]; then
  DESIRED_BRANCH=$(echo "$PARAMETERS" | grep -oP 'CHECKOUT=\K[^&]+' || true)
fi

# ─── Check: já existe build rodando pra mesma branch? ───

if [ -n "$DESIRED_BRANCH" ]; then
  echo "🔍 Verificando se já existe build rodando para '$DESIRED_BRANCH'..."

  LAST_BUILD=$(curl -s --user "${JENKINS_USER}:${JENKINS_TOKEN}" \
    "${JENKINS_URL}/job/${JOB_NAME}/lastBuild/api/json" 2>/dev/null || echo "{}")

  IS_BUILDING=$(echo "$LAST_BUILD" | jq -r '.building // false')
  BUILD_NUMBER=$(echo "$LAST_BUILD" | jq -r '.number // empty')

  if [ "$IS_BUILDING" = "true" ] && [ -n "$BUILD_NUMBER" ]; then
    # Verificar se o CHECKOUT do build rodando é o mesmo
    RUNNING_CHECKOUT=$(echo "$LAST_BUILD" | jq -r '
      [.actions[]?.parameters? // [] | .[]? | select(.name == "CHECKOUT") | .value] | first // empty
    ')

    # Normalizar nomes de branch (remover prefixos origin/, refs/heads/)
    NORM_RUNNING=$(echo "$RUNNING_CHECKOUT" | sed 's|^origin/||;s|^refs/heads/||')
    NORM_DESIRED=$(echo "$DESIRED_BRANCH" | sed 's|^origin/||;s|^refs/heads/||')

    if [ "$NORM_RUNNING" = "$NORM_DESIRED" ]; then
      if [ "$FORCE" = true ]; then
        echo "⚠️  Build #$BUILD_NUMBER está rodando para branch '$RUNNING_CHECKOUT'."
        echo "   --force ativo: cancelando build #$BUILD_NUMBER antes de disparar novo..."
        echo ""
        "$SCRIPT_DIR/stop_build.sh" "$JOB_NAME" "$BUILD_NUMBER"
        echo ""
        echo "   Disparando novo build..."
      else
        echo "✅ Build #$BUILD_NUMBER já está rodando para branch '$RUNNING_CHECKOUT'."
        echo "   Não é necessário disparar um novo build."
        echo "   💡 Use --force para cancelar o build ativo e disparar um novo."
        echo ""
        echo "BUILD_NUMBER=$BUILD_NUMBER"
        echo "STATUS=ALREADY_RUNNING"
        exit 0
      fi
    else
      echo "⚠️  Build #$BUILD_NUMBER está rodando, mas para branch '$RUNNING_CHECKOUT' (não '$DESIRED_BRANCH')."
      echo "   Disparando novo build..."
    fi
  else
    echo "   Nenhum build ativo. Disparando novo..."
  fi
fi

# ─── Trigger ───

echo "Triggering Job '$JOB_NAME' with params '$PARAMETERS'..."

# Capture headers to extract queue ID from Location header
HEADER_FILE=$(mktemp)
RESPONSE=$(curl -s -D "$HEADER_FILE" -w "\nHTTP_CODE:%{http_code}" \
  -X POST \
  --user "${JENKINS_USER}:${JENKINS_TOKEN}" \
  "${JENKINS_URL}/job/${JOB_NAME}/buildWithParameters?${PARAMETERS}")

# Check Result
HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | awk -F: '{print $2}')
BODY=$(echo "$RESPONSE" | sed 's/HTTP_CODE:.*//')

# Jenkins returns 201 Created for Queue Item
if [ "$HTTP_CODE" -eq 201 ]; then
  # Extract queue ID from Location header (e.g. ".../queue/item/12345/")
  QUEUE_URL=$(grep -i "^Location:" "$HEADER_FILE" | awk '{print $2}' | tr -d '\r')
  QUEUE_ID=$(echo "$QUEUE_URL" | grep -oP 'item/\K[0-9]+' || true)
  rm -f "$HEADER_FILE"

  echo "✅ Build Triggered Successfully!"
  if [ -n "$QUEUE_ID" ]; then
    echo "   Queue ID: $QUEUE_ID"
  fi
  echo "STATUS=TRIGGERED"
  [ -n "$QUEUE_ID" ] && echo "QUEUE_ID=$QUEUE_ID"
else
  rm -f "$HEADER_FILE"
  echo "❌ Error triggering build (HTTP $HTTP_CODE)"
  echo "$BODY"
  exit 1
fi
