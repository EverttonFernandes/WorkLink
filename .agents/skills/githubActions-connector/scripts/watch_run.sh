#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/github_common.sh"

selector="${1:-}"
arg2="${2:-}"
arg3="${3:-}"

if [ -z "$selector" ]; then
  echo "❌ Uso: watch_run.sh <workflow-id|name|path> [<ref>] [--run-id <id>|--only-new]"
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

run_id=""
ref_name=""
only_new="false"

if [ "$arg2" = "--run-id" ]; then
  run_id="$arg3"
elif [ "$arg2" = "--only-new" ]; then
  only_new="true"
elif [ -n "$arg2" ]; then
  ref_name="$arg2"
  if [ "$arg3" = "--only-new" ]; then
    only_new="true"
  fi
fi

repo_slug="$(resolve_repo_slug)"
started_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

if [ -z "$run_id" ]; then
  while true; do
    runs_payload="$(list_runs_json "$workflow_id")"
    run_id="$(RUN_REF="${ref_name#refs/heads/}" ONLY_NEW="$only_new" STARTED_AT="$started_at" python3 - <<'PY' <<<"$runs_payload"
import json, os, sys
payload = json.load(sys.stdin)
target_ref = os.environ.get("RUN_REF", "")
only_new = os.environ.get("ONLY_NEW") == "true"
started_at = os.environ.get("STARTED_AT", "")
for run in payload.get("workflow_runs", []):
    if target_ref and run.get("head_branch") != target_ref:
        continue
    if only_new and run.get("created_at", "") < started_at:
        continue
    print(run["id"])
    sys.exit(0)
sys.exit(1)
PY
)" || true
    if [ -n "$run_id" ]; then
      break
    fi
    sleep 10
  done
fi

while true; do
  run_payload="$(github_api GET "/repos/${repo_slug}/actions/runs/${run_id}")"
  status="$(python3 - <<'PY' "$run_payload"
import json, sys
print(json.loads(sys.argv[1])["status"])
PY
)"
  conclusion="$(python3 - <<'PY' "$run_payload"
import json, sys
print(json.loads(sys.argv[1]).get("conclusion"))
PY
)"
  html_url="$(python3 - <<'PY' "$run_payload"
import json, sys
print(json.loads(sys.argv[1]).get("html_url"))
PY
)"

  echo "🔄 Run ${run_id}: status=${status} conclusion=${conclusion} url=${html_url}"

  if [ "$status" = "completed" ]; then
    case "$conclusion" in
      success)
        echo "STATUS=SUCCESS"
        exit 0
        ;;
      failure)
        echo "STATUS=FAILURE"
        exit 1
        ;;
      *)
        echo "STATUS=ERROR"
        exit 2
        ;;
    esac
  fi

  sleep 10
done
