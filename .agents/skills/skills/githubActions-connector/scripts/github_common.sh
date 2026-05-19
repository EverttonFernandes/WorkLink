#!/bin/bash
set -euo pipefail

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "❌ Error: '$1' is required but not installed." >&2
    exit 1
  fi
}

resolve_github_token() {
  if [ -n "${GITHUB_TOKEN:-}" ]; then
    printf '%s' "$GITHUB_TOKEN"
    return 0
  fi

  if ! git remote get-url origin >/dev/null 2>&1; then
    echo "❌ Error: GITHUB_TOKEN is not set and origin remote is unavailable." >&2
    exit 1
  fi

  local remote_url token
  remote_url="$(git remote get-url origin)"
  token="$(printf '%s' "$remote_url" | sed -nE 's#https://([^@]+)@github.com/.*#\1#p')"

  if [ -n "$token" ]; then
    printf '%s' "$token"
    return 0
  fi

  echo "❌ Error: GITHUB_TOKEN is not set." >&2
  exit 1
}

resolve_repo_slug() {
  if [ -n "${GITHUB_REPOSITORY:-}" ]; then
    printf '%s' "$GITHUB_REPOSITORY"
    return 0
  fi

  if ! git remote get-url origin >/dev/null 2>&1; then
    echo "❌ Error: Could not detect repository from origin remote." >&2
    exit 1
  fi

  local remote_url slug
  remote_url="$(git remote get-url origin)"
  slug="$(printf '%s' "$remote_url" | sed -nE 's#(git@|https://([^@]+@)?)(github.com:|github.com/)([^/]+/[^/.]+)(\.git)?#\4#p')"

  if [ -n "$slug" ]; then
    printf '%s' "$slug"
    return 0
  fi

  echo "❌ Error: Could not parse owner/repo from origin remote." >&2
  exit 1
}

github_api() {
  local method="$1"
  local path="$2"
  local data="${3:-}"
  local token
  token="$(resolve_github_token)"

  if [ -n "$data" ]; then
    curl -fsSL \
      -X "$method" \
      -H "Authorization: Bearer $token" \
      -H "Accept: application/vnd.github+json" \
      -H "Content-Type: application/json" \
      "https://api.github.com${path}" \
      -d "$data"
    return 0
  fi

  curl -fsSL \
    -X "$method" \
    -H "Authorization: Bearer $token" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com${path}"
}

list_workflows_json() {
  local repo_slug
  repo_slug="$(resolve_repo_slug)"
  github_api GET "/repos/${repo_slug}/actions/workflows?per_page=100"
}

resolve_workflow_json() {
  local selector="$1"
  local payload
  payload="$(list_workflows_json)"

  WORKFLOW_SELECTOR="$selector" python3 - <<'PY' <<<"$payload"
import json, os, sys

selector = os.environ["WORKFLOW_SELECTOR"].strip().lower()
payload = json.load(sys.stdin)
workflows = payload.get("workflows", [])

def matches(workflow):
    if selector == str(workflow.get("id", "")).lower():
        return True
    if selector == str(workflow.get("name", "")).lower():
        return True
    if selector == str(workflow.get("path", "")).lower():
        return True
    if selector == str(workflow.get("path", "")).split("/")[-1].lower():
        return True
    return False

matches_list = [workflow for workflow in workflows if matches(workflow)]
if len(matches_list) == 1:
    print(json.dumps(matches_list[0]))
    sys.exit(0)

if len(matches_list) == 0:
    print("STATUS=NOT_FOUND")
    sys.exit(2)

print("STATUS=MULTIPLE_FOUND")
for workflow in matches_list:
    print(f"{workflow['id']}|{workflow['name']}|{workflow['path']}")
sys.exit(3)
PY
}

list_runs_json() {
  local workflow_id="$1"
  local repo_slug
  repo_slug="$(resolve_repo_slug)"
  github_api GET "/repos/${repo_slug}/actions/workflows/${workflow_id}/runs?per_page=30"
}
