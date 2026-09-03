#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/github_common.sh"

selector="${1:-}"

if [ -z "$selector" ]; then
  echo "❌ Uso: describe_workflow.sh <workflow-id|name|path>"
  echo "STATUS=ERROR"
  exit 1
fi

workflow_json="$(resolve_workflow_json "$selector")" || {
  exit_code=$?
  if [ "$exit_code" -eq 2 ]; then
    echo "❌ Workflow não encontrado."
    echo "STATUS=NOT_FOUND"
  else
    echo "$workflow_json"
  fi
  exit 1
}

workflow_path="$(python3 - <<'PY' "$workflow_json"
import json, sys
workflow = json.loads(sys.argv[1])
print(workflow["path"])
PY
)"

full_path="$(pwd)/${workflow_path}"

python3 - <<'PY' "$workflow_json" "$full_path"
import json, os, sys, yaml

workflow = json.loads(sys.argv[1])
workflow_file = sys.argv[2]

print(f"📋 Workflow: {workflow['name']}")
print(f"   ID: {workflow['id']}")
print(f"   Path: {workflow['path']}")
print(f"   State: {workflow.get('state')}")
print(f"   URL: {workflow.get('html_url')}")

if not os.path.exists(workflow_file):
    print("")
    print("⚠️ Arquivo do workflow não encontrado localmente para extrair inputs.")
    print("STATUS=DESCRIBED")
    sys.exit(0)

with open(workflow_file, "r", encoding="utf-8") as fh:
    data = yaml.safe_load(fh) or {}

events = data.get("on", {})
if isinstance(events, str):
    events = {events: None}
if isinstance(events, list):
    events = {item: None for item in events}

workflow_dispatch = events.get("workflow_dispatch") or {}
inputs = workflow_dispatch.get("inputs") or {}

print("")
print("🚀 Triggers:")
for trigger_name in events.keys():
    print(f"   - {trigger_name}")

print("")
if inputs:
    print(f"🔧 Inputs workflow_dispatch ({len(inputs)}):")
    for input_name, input_config in inputs.items():
      input_config = input_config or {}
      required = input_config.get("required", False)
      default = input_config.get("default", "")
      description = input_config.get("description", "")
      print(f"   📌 {input_name}")
      print(f"      Required: {required}")
      print(f"      Default:  {default}")
      print(f"      Desc:     {description}")
else:
    print("🔧 Inputs workflow_dispatch: nenhum input declarado.")

print("")
example = f"{workflow['path']} refs/heads/main '{{}}'"
print("💡 Exemplo de uso:")
print(f"   trigger_workflow.sh \"{workflow['path']}\" \"refs/heads/main\" '{{}}'")
print("STATUS=DESCRIBED")
PY
