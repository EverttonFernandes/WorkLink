#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/github_common.sh"

selector="${1:-}"
arg2="${2:-}"
arg3="${3:-}"

if [ -z "$selector" ] || [ -z "$arg2" ]; then
  echo "❌ Uso: stop_run.sh <workflow-id|name|path> <run-id|--latest|--branch <branch>>"
  echo "STATUS=ERROR"
  exit 1
fi

workflow_json="$(resolve_workflow_json "$selector")" || {
  echo "$workflow_json"
  exit 1
}

workflow_id="$(python3 - <<'PY' "$workflow_json"
import json, sys
print(json.loads(sys.argv[1])["id"])
PY
)"

runs_payload="$(list_runs_json "$workflow_id")"
run_id=""

if [ "$arg2" = "--latest" ]; then
  run_id="$(python3 - <<'PY' <<<"$runs_payload"
import json, sys
payload = json.load(sys.stdin)
for run in payload.get("workflow_runs", []):
    if run.get("status") != "completed":
        print(run["id"])
        sys.exit(0)
sys.exit(1)
PY
)" || true
elif [ "$arg2" = "--branch" ]; then
  run_id="$(TARGET_BRANCH="$arg3" python3 - <<'PY' <<<"$runs_payload"
import json, os, sys
payload = json.load(sys.stdin)
for run in payload.get("workflow_runs", []):
    if run.get("status") != "completed" and run.get("head_branch") == os.environ["TARGET_BRANCH"]:
        print(run["id"])
        sys.exit(0)
sys.exit(1)
PY
)" || true
else
  run_id="$arg2"
fi

if [ -z "$run_id" ]; then
  echo "⚠️ Nenhum run elegível encontrado."
  echo "STATUS=NOT_FOUND"
  exit 1
fi

repo_slug="$(resolve_repo_slug)"
github_api POST "/repos/${repo_slug}/actions/runs/${run_id}/cancel" >/dev/null

echo "✅ Run cancelado com sucesso."
echo "RUN_ID=${run_id}"
echo "STATUS=STOPPED"
