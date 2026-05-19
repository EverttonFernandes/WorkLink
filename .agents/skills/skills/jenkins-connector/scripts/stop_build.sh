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
BUILD_REF="$2"  # Number, --latest, or --branch

JENKINS_URL="${JENKINS_URL:-https://dese-jenkins.umov.me}"

# Validate Environment
if [ -z "$JENKINS_USER" ] || [ -z "$JENKINS_TOKEN" ]; then
  echo "Error: JENKINS_USER and JENKINS_TOKEN must be set."
  exit 1
fi

if [ -z "$JOB_NAME" ] || [ -z "$BUILD_REF" ]; then
  echo "Usage: ./stop_build.sh \"<JobName>\" <BuildNumber|--latest|--branch \"<branch>\">"
  echo ""
  echo "  BuildNumber:  Stop a specific build by number"
  echo "  --latest:     Stop the last build (whatever it is)"
  echo "  --branch:     Find and stop the active build for a specific branch"
  exit 1
fi

# ─── Resolver BUILD_NUMBER ───

if [ "$BUILD_REF" = "--latest" ]; then
  echo "🔍 Resolvendo último build..."
  LAST_BUILD=$(curl -s --user "${JENKINS_USER}:${JENKINS_TOKEN}" \
    "${JENKINS_URL}/job/${JOB_NAME}/lastBuild/api/json" 2>/dev/null || echo "{}")
  BUILD_NUMBER=$(echo "$LAST_BUILD" | jq -r '.number // empty')

  if [ -z "$BUILD_NUMBER" ]; then
    echo "❌ Nenhum build encontrado para job '$JOB_NAME'."
    exit 1
  fi
  echo "   Último build: #$BUILD_NUMBER"

elif [ "$BUILD_REF" = "--branch" ]; then
  BRANCH="$3"
  if [ -z "$BRANCH" ]; then
    echo "❌ --branch requer o nome da branch como argumento."
    echo "   Exemplo: ./stop_build.sh \"MyJob\" --branch \"origin/my-branch\""
    exit 1
  fi

  NORM_DESIRED=$(echo "$BRANCH" | sed 's|^origin/||;s|^refs/heads/||')
  echo "🔍 Buscando build ativo para branch '$BRANCH'..."

  # Buscar últimos 5 builds para encontrar o correto (não apenas lastBuild)
  BUILDS_JSON=$(curl -s --user "${JENKINS_USER}:${JENKINS_TOKEN}" \
    "${JENKINS_URL}/job/${JOB_NAME}/api/json?tree=builds[number,building,actions[parameters[name,value]]]{0,5}" \
    2>/dev/null || echo '{"builds":[]}')

  BUILD_NUMBER=""
  RUNNING_BRANCH=""

  # Iterar sobre os builds para encontrar um ativo para a branch desejada
  BUILD_COUNT=$(echo "$BUILDS_JSON" | jq '.builds | length')
  for i in $(seq 0 $((BUILD_COUNT - 1))); do
    B_NUMBER=$(echo "$BUILDS_JSON" | jq -r ".builds[$i].number")
    B_BUILDING=$(echo "$BUILDS_JSON" | jq -r ".builds[$i].building // false")
    B_CHECKOUT=$(echo "$BUILDS_JSON" | jq -r "
      [.builds[$i].actions[]?.parameters? // [] | .[]? | select(.name == \"CHECKOUT\") | .value] | first // empty
    ")

    if [ "$B_BUILDING" = "true" ]; then
      NORM_RUNNING=$(echo "$B_CHECKOUT" | sed 's|^origin/||;s|^refs/heads/||')
      if [ "$NORM_RUNNING" = "$NORM_DESIRED" ]; then
        BUILD_NUMBER="$B_NUMBER"
        RUNNING_BRANCH="$B_CHECKOUT"
        break
      fi
    fi
  done

  if [ -z "$BUILD_NUMBER" ]; then
    echo "⚠️  Nenhum build ativo encontrado para branch '$BRANCH'."
    exit 0
  fi
  echo "   Encontrado: build #$BUILD_NUMBER (branch: $RUNNING_BRANCH)"

else
  # Modo direto: BUILD_REF é o número do build
  BUILD_NUMBER="$BUILD_REF"

  # Validar que é numérico
  if ! [[ "$BUILD_NUMBER" =~ ^[0-9]+$ ]]; then
    echo "❌ '$BUILD_REF' não é um número de build válido nem uma flag reconhecida."
    echo "   Use: <número>, --latest, ou --branch \"<branch>\""
    exit 1
  fi
fi

# ─── Verificar se build existe e está rodando ───

echo "🔍 Verificando status do build #$BUILD_NUMBER..."

BUILD_INFO=$(curl -s -w "\nHTTP_CODE:%{http_code}" --user "${JENKINS_USER}:${JENKINS_TOKEN}" \
  "${JENKINS_URL}/job/${JOB_NAME}/${BUILD_NUMBER}/api/json" 2>/dev/null)

HTTP_CODE=$(echo "$BUILD_INFO" | grep "HTTP_CODE" | awk -F: '{print $2}')
BUILD_JSON=$(echo "$BUILD_INFO" | sed 's/HTTP_CODE:.*//')

if [ "$HTTP_CODE" = "404" ]; then
  echo "❌ Build #$BUILD_NUMBER não encontrado no job '$JOB_NAME'."
  exit 1
fi

if [ "$HTTP_CODE" != "200" ]; then
  echo "❌ Erro ao acessar build #$BUILD_NUMBER (HTTP $HTTP_CODE)."
  exit 1
fi

IS_BUILDING=$(echo "$BUILD_JSON" | jq -r '.building // false')

if [ "$IS_BUILDING" != "true" ]; then
  RESULT=$(echo "$BUILD_JSON" | jq -r '.result // "UNKNOWN"')
  echo "⚠️  Build #$BUILD_NUMBER já finalizou ($RESULT). Nada a cancelar."
  exit 0
fi

# ─── Parar o build ───

echo "🛑 Cancelando build #$BUILD_NUMBER..."

# Jenkins retorna 302 (redirect para página do build) em caso de sucesso no /stop.
# Alguns setups podem retornar 200. Ambos indicam sucesso.
STOP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
  --user "${JENKINS_USER}:${JENKINS_TOKEN}" \
  "${JENKINS_URL}/job/${JOB_NAME}/${BUILD_NUMBER}/stop")

if [ "$STOP_CODE" -eq 302 ] || [ "$STOP_CODE" -eq 200 ]; then
  echo "✅ Build #$BUILD_NUMBER cancelado com sucesso."
  echo ""
  echo "BUILD_NUMBER=$BUILD_NUMBER"
  echo "STATUS=STOPPED"
else
  echo "❌ Erro ao cancelar build #$BUILD_NUMBER (HTTP $STOP_CODE)."
  exit 1
fi
