#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMP_WORKDIR="/tmp/worklink-mobile-wlt030-web-build"
EVIDENCE_DIR="${REPO_ROOT}/docs/tasks/WLT-030/evidence/web-static"
SERVER_SCRIPT="/tmp/wlt030-static-server.ps1"
SERVER_LOG="/tmp/wlt030-static-server.log"
PORT="${WLT030_WEB_EVIDENCE_PORT:-18085}"

CHROME_PATH="${CHROME_PATH:-/mnt/c/Program Files/Google/Chrome/Application/chrome.exe}"
if [ ! -x "${CHROME_PATH}" ]; then
  CHROME_PATH="/mnt/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe"
fi

if [ ! -x "${CHROME_PATH}" ]; then
  printf 'Chrome/Edge nao encontrado para captura headless.\n' >&2
  exit 1
fi

rm -rf "${TEMP_WORKDIR}"
mkdir -p "${TEMP_WORKDIR}" "${EVIDENCE_DIR}"

rsync -a \
  --exclude '.dart_tool' \
  --exclude 'build' \
  --exclude 'coverage' \
  --exclude 'android/.gradle' \
  "${REPO_ROOT}/worklink-mobile/" \
  "${TEMP_WORKDIR}/"

pushd "${TEMP_WORKDIR}" >/dev/null
/home/everton/flutter/bin/flutter build web \
  -t test/widget/visual/wlt_030_visual_evidence_web_app.dart \
  --release
popd >/dev/null

cat >"${SERVER_SCRIPT}" <<'POWERSHELL'
param([string]$Root, [int]$Port)

$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://127.0.0.1:$Port/")
$listener.Start()
Write-Output "SERVING http://127.0.0.1:$Port/ from $Root"

while ($listener.IsListening) {
  $context = $listener.GetContext()
  $path = $context.Request.Url.AbsolutePath.TrimStart('/')
  if ([string]::IsNullOrWhiteSpace($path)) {
    $path = 'index.html'
  }

  $filePath = Join-Path $Root $path
  if (-not (Test-Path $filePath -PathType Leaf)) {
    $filePath = Join-Path $Root 'index.html'
  }

  $extension = [System.IO.Path]::GetExtension($filePath).ToLowerInvariant()
  $contentType = switch ($extension) {
    '.html' { 'text/html; charset=utf-8' }
    '.js' { 'application/javascript; charset=utf-8' }
    '.mjs' { 'application/javascript; charset=utf-8' }
    '.json' { 'application/json; charset=utf-8' }
    '.wasm' { 'application/wasm' }
    '.png' { 'image/png' }
    '.jpg' { 'image/jpeg' }
    '.jpeg' { 'image/jpeg' }
    '.svg' { 'image/svg+xml' }
    default { 'application/octet-stream' }
  }

  $bytes = [System.IO.File]::ReadAllBytes($filePath)
  $context.Response.ContentType = $contentType
  $context.Response.ContentLength64 = $bytes.Length
  $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
  $context.Response.OutputStream.Close()
}
POWERSHELL

BUILD_WEB_WINDOWS_PATH="$(wslpath -w "${TEMP_WORKDIR}/build/web")"
powershell.exe -NoProfile -ExecutionPolicy Bypass \
  -File "$(wslpath -w "${SERVER_SCRIPT}")" \
  -Root "${BUILD_WEB_WINDOWS_PATH}" \
  -Port "${PORT}" \
  >"${SERVER_LOG}" 2>&1 &
SERVER_PID="$!"

cleanup() {
  if kill -0 "${SERVER_PID}" >/dev/null 2>&1; then
    kill "${SERVER_PID}" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

sleep 3
if ! powershell.exe -NoProfile -Command \
  "try { Invoke-WebRequest -UseBasicParsing -TimeoutSec 3 -Uri http://127.0.0.1:${PORT}/ | Out-Null; exit 0 } catch { exit 1 }" \
  >/dev/null 2>&1; then
  cat "${SERVER_LOG}" >&2 || true
  exit 1
fi

rm -f "${EVIDENCE_DIR}"/*.png

SCREEN_NAMES=(
  auth-phone-entry
  auth-verification
  city-selection
  discovery-results
  discovery-empty-state
  professional-profile
  professional-registration
  customer-profile
  professional-contact
  post-contact-feedback
  professional-review
  professional-review-success
  professional-report
)

WINDOWS_TEMP_DIR="$(powershell.exe -NoProfile -Command '$env:TEMP' | tr -d '\r')"

for screen_name in "${SCREEN_NAMES[@]}"; do
  output_path="${EVIDENCE_DIR}/${screen_name}.png"
  windows_output_path="$(wslpath -w "${output_path}")"
  windows_profile_path="${WINDOWS_TEMP_DIR}\\wlt030-chrome-${screen_name}-$$"
  timeout 45s "${CHROME_PATH}" \
    --headless=new \
    --disable-gpu \
    --hide-scrollbars \
    --user-data-dir="${windows_profile_path}" \
    --window-size=430,1600 \
    --force-device-scale-factor=1 \
    --virtual-time-budget=20000 \
    --screenshot="${windows_output_path}" \
    "http://127.0.0.1:${PORT}/?screen=${screen_name}" \
    >/tmp/wlt030-chrome-${screen_name}.log 2>&1
done

printf '\nEvidencias web geradas em:\n'
find "${EVIDENCE_DIR}" -maxdepth 1 -type f -name '*.png' | sort
