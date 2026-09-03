#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/github_common.sh"

search_term="${1:-}"

if [ -z "$search_term" ]; then
  echo "❌ Uso: search_workflow.sh <termo>"
  echo "STATUS=ERROR"
  exit 1
fi

payload="$(list_workflows_json)"

WORKFLOW_SEARCH_TERM="$search_term" python3 - <<'PY' <<<"$payload"
import json, os, sys

search_terms = [item.lower() for item in os.environ["WORKFLOW_SEARCH_TERM"].split() if item.strip()]
payload = json.load(sys.stdin)
workflows = payload.get("workflows", [])

def matches(workflow):
    haystack = " ".join([
        str(workflow.get("name", "")),
        str(workflow.get("path", "")),
    ]).lower()
    return all(term in haystack for term in search_terms)

results = [workflow for workflow in workflows if matches(workflow)]

if not results:
    print(f"❌ Nenhum workflow encontrado para '{os.environ['WORKFLOW_SEARCH_TERM']}'")
    print("STATUS=NOT_FOUND")
    sys.exit(1)

if len(results) == 1:
    workflow = results[0]
    print(f"✅ Workflow encontrado: {workflow['name']}")
    print(f"WORKFLOW_ID={workflow['id']}")
    print(f"WORKFLOW_NAME={workflow['name']}")
    print(f"WORKFLOW_PATH={workflow['path']}")
    print("STATUS=FOUND")
    sys.exit(0)

print(f"⚠️  {len(results)} workflows encontrados:")
for workflow in results:
    print(f"{workflow['id']} | {workflow['name']} | {workflow['path']} | state={workflow.get('state')}")
print(f"COUNT={len(results)}")
print("STATUS=MULTIPLE_FOUND")
sys.exit(1)
PY
