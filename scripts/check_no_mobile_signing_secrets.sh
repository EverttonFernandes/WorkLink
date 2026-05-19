#!/bin/sh
set -eu

blocked_pattern='(\.jks$|\.keystore$|\.p12$|\.p8$|\.cer$|\.mobileprovision$|\.provisionprofile$|GoogleService-Info\.plist$|google-services\.json$)'

tracked_secret_files="$(git ls-files | grep -E "${blocked_pattern}" || true)"

if [ -n "$tracked_secret_files" ]; then
  echo "Arquivos sensiveis de assinatura/configuracao mobile nao podem ser versionados:" >&2
  echo "$tracked_secret_files" >&2
  exit 1
fi

echo "Nenhum secret de assinatura mobile versionado."
