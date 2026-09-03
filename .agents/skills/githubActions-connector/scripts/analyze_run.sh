#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/github_common.sh"

selector="${1:-}"
run_id="${2:-}"
max_lines="${3:-120}"

if [ -z "$selector" ]; then
  echo "❌ Uso: analyze_run.sh <workflow-id|name|path> [run-id] [max-lines]"
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

if [ -z "$run_id" ]; then
  runs_payload="$(list_runs_json "$workflow_id")"
  run_id="$(python3 - <<'PY' <<<"$runs_payload"
import json, sys
payload = json.load(sys.stdin)
runs = payload.get("workflow_runs", [])
if not runs:
    sys.exit(1)
print(runs[0]["id"])
PY
)"
fi

repo_slug="$(resolve_repo_slug)"
jobs_payload="$(github_api GET "/repos/${repo_slug}/actions/runs/${run_id}/jobs?per_page=100")"

failing_job_id="$(python3 - <<'PY' <<<"$jobs_payload"
import json, sys
payload = json.load(sys.stdin)
for job in payload.get("jobs", []):
    if job.get("conclusion") == "failure":
        print(job["id"])
        sys.exit(0)
sys.exit(1)
PY
)" || true

if [ -z "$failing_job_id" ]; then
  echo "⚠️ Nenhum job com conclusão failure encontrado."
  echo "STATUS=NO_FAILURE"
  exit 0
fi

log_file="/tmp/github-actions-run-${run_id}-job-${failing_job_id}.log"
github_api GET "/repos/${repo_slug}/actions/jobs/${failing_job_id}/logs" >"$log_file"

echo "📋 Run: ${run_id}"
echo "📋 Failing job: ${failing_job_id}"
echo ""
echo "🔎 Trechos relevantes:"
rg -n "(Error:|FAILED|Failed to|Timeout|Exception|Caused by:|The process|exit code|AssertionError|SocketException)" "$log_file" | tail -n "$max_lines" || true
echo ""
echo "🧾 Final do log:"
tail -n "$max_lines" "$log_file"
echo "STATUS=ANALYZED"
