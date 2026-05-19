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
BUILD_NUMBER="${2:-lastBuild}"
MAX_LOG_LINES="${3:-100}"

JENKINS_URL="${JENKINS_URL:-https://dese-jenkins.umov.me}"

# Validate Environment
if [ -z "$JENKINS_USER" ] || [ -z "$JENKINS_TOKEN" ]; then
  echo "Error: JENKINS_USER and JENKINS_TOKEN must be set."
  exit 1
fi

if [ -z "$JOB_NAME" ]; then
  echo "Usage: ./analyze_build.sh \"<JobName>\" [BuildNumber] [MaxLogLines]"
  echo ""
  echo "  JobName:      Jenkins job name (e.g., ENTRADA_umovme-Business-Graphql_Pipeline)"
  echo "  BuildNumber:  Build number or 'lastBuild' (default: lastBuild)"
  echo "  MaxLogLines:  Max lines of log to return (default: 100)"
  exit 1
fi

BASE_URL="$JENKINS_URL/job/$JOB_NAME/$BUILD_NUMBER"

# ─── Estratégia 1: wfapi (Pipeline estruturado) ───

echo "🔍 Tentando análise estruturada (wfapi)..."

WFAPI_RESPONSE=$(curl -s -u "$JENKINS_USER:$JENKINS_TOKEN" "$BASE_URL/wfapi/describe")

if echo "$WFAPI_RESPONSE" | jq -e '.stages' > /dev/null 2>&1; then
  echo "✅ Pipeline detectado. Analisando stages..."
  echo ""

  # Mostrar resumo de stages
  echo "================================"
  echo "📊 RESUMO DOS STAGES"
  echo "================================"
  echo "$WFAPI_RESPONSE" | jq -r '.stages[] | "  \(if .status == "FAILED" then "❌" elif .status == "SUCCESS" then "✅" else "⏭️" end) \(.name) (\(.status)) - \(.durationMillis/1000)s"'
  echo "================================"
  echo ""

  # Encontrar o primeiro stage FAILED
  FAILED_STAGE=$(echo "$WFAPI_RESPONSE" | jq '[.stages[] | select(.status == "FAILED")][0]')

  if [ "$FAILED_STAGE" != "null" ] && [ -n "$FAILED_STAGE" ]; then
    STAGE_NAME=$(echo "$FAILED_STAGE" | jq -r '.name')
    STAGE_ERROR=$(echo "$FAILED_STAGE" | jq -r '.error.message // "unknown"')
    STAGE_ID=$(echo "$FAILED_STAGE" | jq -r '.id')

    echo "🎯 PRIMEIRO STAGE COM FALHA: $STAGE_NAME"
    echo "   Erro: $STAGE_ERROR"
    echo ""

    # Buscar sub-nodes do stage falhou
    STAGE_DETAIL=$(curl -s -u "$JENKINS_USER:$JENKINS_TOKEN" "$BASE_URL/execution/node/$STAGE_ID/wfapi/describe")

    # Encontrar o flow node que falhou
    FAILED_NODE_ID=$(echo "$STAGE_DETAIL" | jq -r '[.stageFlowNodes[] | select(.status == "FAILED")][0].id // empty')

    if [ -n "$FAILED_NODE_ID" ]; then
      FAILED_NODE_NAME=$(echo "$STAGE_DETAIL" | jq -r "[.stageFlowNodes[] | select(.id == \"$FAILED_NODE_ID\")][0].name")
      FAILED_NODE_CMD=$(echo "$STAGE_DETAIL" | jq -r "[.stageFlowNodes[] | select(.id == \"$FAILED_NODE_ID\")][0].parameterDescription // \"\"")

      echo "📌 Step que falhou: $FAILED_NODE_NAME"
      [ -n "$FAILED_NODE_CMD" ] && echo "   Comando: $FAILED_NODE_CMD"
      echo ""

      # Pegar log do node específico
      NODE_LOG=$(curl -s -u "$JENKINS_USER:$JENKINS_TOKEN" "$BASE_URL/execution/node/$FAILED_NODE_ID/wfapi/log" | jq -r '.text // empty')

      if [ -n "$NODE_LOG" ]; then
        # Strip HTML tags
        CLEAN_LOG=$(echo "$NODE_LOG" | sed 's/<[^>]*>//g')
        LINE_COUNT=$(echo "$CLEAN_LOG" | wc -l)

        echo "================================"
        echo "📋 LOG DO STEP ($LINE_COUNT linhas)"
        echo "================================"
        echo "$CLEAN_LOG" | tail -"$MAX_LOG_LINES"
        echo "================================"
        echo ""
        echo "✅ Análise concluída via wfapi ($LINE_COUNT linhas do step vs 100% do log completo)"
        exit 0
      fi
    fi

    # Fallback: tentar log do stage inteiro se sub-nodes falharam
    echo "⚠️  Não foi possível obter log do step específico. Usando fallback..."
  fi
fi

# ─── Estratégia 2: Grep no consoleText (Fallback) ───

echo ""
echo "🔍 Usando análise por grep (fallback)..."
echo ""

CONSOLE_URL="$BASE_URL/consoleText"

# Tentar grep por padrões de erro
ERROR_BLOCK=$(curl -s -u "$JENKINS_USER:$JENKINS_TOKEN" "$CONSOLE_URL" | \
  grep -B3 -A10 -iE "error[: ]|fail[: ]|exception|npm ERR|ELIFECYCLE|Cannot find|compilation failed|BUILD FAILURE" | \
  head -"$MAX_LOG_LINES")

if [ -n "$ERROR_BLOCK" ]; then
  LINE_COUNT=$(echo "$ERROR_BLOCK" | wc -l)
  echo "================================"
  echo "📋 BLOCOS DE ERRO ENCONTRADOS ($LINE_COUNT linhas)"
  echo "================================"
  echo "$ERROR_BLOCK"
  echo "================================"
else
  # Último recurso: tail
  echo "⚠️  Nenhum padrão de erro encontrado. Mostrando últimas $MAX_LOG_LINES linhas:"
  echo ""
  echo "================================"
  echo "📋 ÚLTIMAS $MAX_LOG_LINES LINHAS"
  echo "================================"
  curl -s -u "$JENKINS_USER:$JENKINS_TOKEN" "$CONSOLE_URL" | tail -"$MAX_LOG_LINES"
  echo "================================"
fi

echo ""
echo "⚠️  Análise via grep (menos precisa que wfapi)"
