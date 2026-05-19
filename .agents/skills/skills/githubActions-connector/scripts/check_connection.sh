#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/github_common.sh"

require_command curl
require_command python3

repo_slug="$(resolve_repo_slug)"

echo "Testing connection to GitHub Actions API (${repo_slug})..."

user_payload="$(github_api GET /user)"
repo_payload="$(github_api GET "/repos/${repo_slug}")"

python3 - <<'PY' "$user_payload" "$repo_payload"
import json, sys
user = json.loads(sys.argv[1])
repo = json.loads(sys.argv[2])
print("✅ Connection Successful!")
print(f"Authenticated as: {user.get('login')}")
print(f"Repository: {repo.get('full_name')}")
print(f"Default branch: {repo.get('default_branch')}")
PY
