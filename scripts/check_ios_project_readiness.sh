#!/usr/bin/env sh
set -eu

IOS_DIR="${IOS_DIR:-worklink-mobile/ios}"

require_path() {
  if [ ! -e "$1" ]; then
    echo "Arquivo ou diretorio iOS obrigatorio ausente: $1" >&2
    exit 1
  fi
}

require_path "${IOS_DIR}/Runner.xcworkspace/contents.xcworkspacedata"
require_path "${IOS_DIR}/Runner.xcodeproj/project.pbxproj"
require_path "${IOS_DIR}/Runner/Info.plist"
require_path "${IOS_DIR}/Runner/AppDelegate.swift"
require_path "${IOS_DIR}/Flutter/Release.xcconfig"
require_path "${IOS_DIR}/Flutter/Debug.xcconfig"

if find "${IOS_DIR}" -type f \( \
  -name '*.p12' \
  -o -name '*.p8' \
  -o -name '*.mobileprovision' \
  -o -name '*.provisionprofile' \
  -o -name '*.cer' \
  -o -name '*.key' \
  -o -name 'GoogleService-Info.plist' \
\) | grep -q .; then
  echo "Arquivo sensivel iOS encontrado dentro de ${IOS_DIR}. Remova e use secrets protegidos." >&2
  exit 1
fi

echo "Prontidao iOS basica aprovada para ${IOS_DIR}."
