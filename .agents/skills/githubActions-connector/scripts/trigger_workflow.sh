#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/github_common.sh"

selector="${1:-}"
ref_name="${2:-}"
inputs_json="${3:-{}}"
force_flag="${4:-}"

if [ -z "$selector" ] || [ -z "$ref_name" ]; then
  echo "❌ Uso: trigger_workflow.sh <workflow-id|name|path> <ref> [inputs-json] [--force]"
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

ref_short="${ref_name#refs/heads/}"
ref_short="${ref_short#refs/tags/}"

if [ "$force_flag" = "--force" ]; then
  runs_payload="$(list_runs_json "$workflow_id")"
  FORCE_REF="$ref_short" python3 - <<'PY' <<<"$runs_payload" >/tmp/github-actions-force-runs.txt
import json, os, sys
payload = json.load(sys.stdin)
for run in payload.get("workflow_runs", []):
    if run.get("status") != "completed" and run.get("head_branch") == os.environ["FORCE_REF"]:
        print(f"{run['id']}|{run.get('status')}|{run.get('html_url')}")
PY
  if [ -s /tmp/github-actions-force-runs.txt ]; then
    while IFS='|' read -r run_id _ _; do
      repo_slug="$(resolve_repo_slug)"
      github_api POST "/repos/${repo_slug}/actions/runs/${run_id}/cancel" >/dev/null || true
    done </tmp/github-actions-force-runs.txt
  fi
fi

dispatch_payload="$(python3 - <<'PY' "$ref_name" "$inputs_json"
import json, sys
ref_name = sys.argv[1]
inputs_json = sys.argv[2]
inputs = json.loads(inputs_json)
print(json.dumps({"ref": ref_name, "inputs": inputs}))
PY
)"

repo_slug="$(resolve_repo_slug)"
dispatch_started_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
github_api POST "/repos/${repo_slug}/actions/workflows/${workflow_id}/dispatches" "$dispatch_payload" >/dev/null

run_id="$(WORKFLOW_ID="$workflow_id" REF_SHORT="$ref_short" STARTED_AT="$dispatch_started_at" python3 - <<'PY'
import json, os, subprocess, sys, time

workflow_id = os.environ["WORKFLOW_ID"]
ref_short = os.environ["REF_SHORT"]
started_at = os.environ["STARTED_AT"]

for _ in range(18):
    payload = subprocess.check_output(
        [
            "bash",
            "-lc",
            f'. "{os.getcwd()}/.agents/skills/githubActions-connector/scripts/github_common.sh"; list_runs_json "{workflow_id}"'
        ],
        text=True,
    )
    data = json.loads(payload)
    for run in data.get("workflow_runs", []):
        if run.get("event") == "workflow_dispatch" and run.get("head_branch") == ref_short and run.get("created_at", "") >= started_at:
            print(run["id"])
            sys.exit(0)
    time.sleep(5)

sys.exit(1)
PY
)" || true

echo "✅ Workflow disparado com sucesso!"
echo "STATUS=TRIGGERED"
if [ -n "$run_id" ]; then
  echo "RUN_ID=$run_id"
fi
