#!/usr/bin/env sh
set -eu

TEMPORARY_ROOT="$(mktemp -d)"
trap 'rm -rf "${TEMPORARY_ROOT}"' EXIT

create_minimal_repository() {
  target_root="$1"

  mkdir -p \
    "${target_root}/.github/workflows" \
    "${target_root}/docs/operacao" \
    "${target_root}/worklink-mobile"

  git -C "${target_root}" init -q

  cat > "${target_root}/.gitignore" <<'EOF'
*.jks
*.keystore
*.p12
*.p8
*.cer
*.key
*.mobileprovision
*.provisionprofile
GoogleService-Info.plist
google-services.json
artifacts/local-secrets/
EOF

  cat > "${target_root}/.env.example" <<'EOF'
WORKLINK_HOMOLOGATION_API_BASE_URL=
WORKLINK_PLAY_STORE_API_BASE_URL=
EOF

  cat > "${target_root}/worklink-mobile/.env.example" <<'EOF'
WORKLINK_USE_PREVIEW_DATA=true
EOF

  cat > "${target_root}/.github/workflows/ci.yml" <<'EOF'
name: CI
jobs:
  dependency-scan:
    steps:
      - name: Mobile signing governance gate
        run: make mobile-signing-governance
      - run: echo "${{ secrets.WORKLINK_ANDROID_HOMOLOGATION_KEYSTORE_BASE64 }}"
      - run: echo "${{ secrets.WORKLINK_ANDROID_HOMOLOGATION_KEYSTORE_PASSWORD }}"
      - run: echo "${{ secrets.WORKLINK_ANDROID_HOMOLOGATION_KEY_ALIAS }}"
      - run: echo "${{ secrets.WORKLINK_ANDROID_HOMOLOGATION_KEY_PASSWORD }}"
      - run: echo "${{ secrets.WORKLINK_ANDROID_STORE_KEYSTORE_BASE64 }}"
      - run: echo "${{ secrets.WORKLINK_ANDROID_STORE_KEYSTORE_PASSWORD }}"
      - run: echo "${{ secrets.WORKLINK_ANDROID_STORE_KEY_ALIAS }}"
      - run: echo "${{ secrets.WORKLINK_ANDROID_STORE_KEY_PASSWORD }}"
EOF

  cat > "${target_root}/.github/workflows/ios-build.yml" <<'EOF'
name: iOS
env:
  WORKLINK_APPLE_TEAM_ID: ${{ secrets.WORKLINK_APPLE_TEAM_ID }}
  WORKLINK_IOS_BUNDLE_IDENTIFIER: ${{ secrets.WORKLINK_IOS_BUNDLE_IDENTIFIER }}
  WORKLINK_APP_STORE_CONNECT_API_KEY_ID: ${{ secrets.WORKLINK_APP_STORE_CONNECT_API_KEY_ID }}
  WORKLINK_APP_STORE_CONNECT_ISSUER_ID: ${{ secrets.WORKLINK_APP_STORE_CONNECT_ISSUER_ID }}
  WORKLINK_APP_STORE_CONNECT_API_PRIVATE_KEY: ${{ secrets.WORKLINK_APP_STORE_CONNECT_API_PRIVATE_KEY }}
  WORKLINK_IOS_DISTRIBUTION_CERTIFICATE_BASE64: ${{ secrets.WORKLINK_IOS_DISTRIBUTION_CERTIFICATE_BASE64 }}
  WORKLINK_IOS_DISTRIBUTION_CERTIFICATE_PASSWORD: ${{ secrets.WORKLINK_IOS_DISTRIBUTION_CERTIFICATE_PASSWORD }}
  WORKLINK_IOS_PROVISIONING_PROFILE_BASE64: ${{ secrets.WORKLINK_IOS_PROVISIONING_PROFILE_BASE64 }}
EOF

  cat > "${target_root}/docs/operacao/mobile-secrets-assinatura.md" <<'EOF'
# Governanca

## Obrigatorios para CD

WORKLINK_ANDROID_HOMOLOGATION_KEYSTORE_BASE64
WORKLINK_ANDROID_HOMOLOGATION_KEYSTORE_PASSWORD
WORKLINK_ANDROID_HOMOLOGATION_KEY_ALIAS
WORKLINK_ANDROID_HOMOLOGATION_KEY_PASSWORD
WORKLINK_ANDROID_STORE_KEYSTORE_BASE64
WORKLINK_ANDROID_STORE_KEYSTORE_PASSWORD
WORKLINK_ANDROID_STORE_KEY_ALIAS
WORKLINK_ANDROID_STORE_KEY_PASSWORD
WORKLINK_APPLE_TEAM_ID
WORKLINK_IOS_BUNDLE_IDENTIFIER
WORKLINK_APP_STORE_CONNECT_API_KEY_ID
WORKLINK_APP_STORE_CONNECT_ISSUER_ID
WORKLINK_APP_STORE_CONNECT_API_PRIVATE_KEY
WORKLINK_IOS_DISTRIBUTION_CERTIFICATE_BASE64
WORKLINK_IOS_DISTRIBUTION_CERTIFICATE_PASSWORD
WORKLINK_IOS_PROVISIONING_PROFILE_BASE64

## Rotacao e revogacao

Rotacionar e revogar quando houver suspeita de exposicao.
EOF

  git -C "${target_root}" add .
  git -C "${target_root}" \
    -c user.name=WorkLink \
    -c user.email=worklink@example.com \
    commit -m "fixture" >/dev/null
}

VALID_REPOSITORY="${TEMPORARY_ROOT}/valid"
PUBLIC_REPOSITORY="${TEMPORARY_ROOT}/public"
TRACKED_SECRET_REPOSITORY="${TEMPORARY_ROOT}/tracked-secret"
BROKEN_IGNORE_REPOSITORY="${TEMPORARY_ROOT}/broken-ignore"

mkdir -p "${VALID_REPOSITORY}" "${PUBLIC_REPOSITORY}" "${TRACKED_SECRET_REPOSITORY}" "${BROKEN_IGNORE_REPOSITORY}"
create_minimal_repository "${VALID_REPOSITORY}"
create_minimal_repository "${PUBLIC_REPOSITORY}"
create_minimal_repository "${TRACKED_SECRET_REPOSITORY}"
create_minimal_repository "${BROKEN_IGNORE_REPOSITORY}"

./scripts/check_mobile_signing_governance.sh "${VALID_REPOSITORY}" >/dev/null

rm -rf "${PUBLIC_REPOSITORY}/docs"
./scripts/check_mobile_signing_governance.sh "${PUBLIC_REPOSITORY}" >/dev/null

printf 'secret' > "${TRACKED_SECRET_REPOSITORY}/release.p12"
git -C "${TRACKED_SECRET_REPOSITORY}" add -f release.p12
git -C "${TRACKED_SECRET_REPOSITORY}" \
  -c user.name=WorkLink \
  -c user.email=worklink@example.com \
  commit -m "tracked secret" >/dev/null

if ./scripts/check_mobile_signing_governance.sh "${TRACKED_SECRET_REPOSITORY}" >/dev/null 2>&1; then
  echo "Gate deveria bloquear arquivo sensivel versionado." >&2
  exit 1
fi

sed -i '/\*\.p8/d' "${BROKEN_IGNORE_REPOSITORY}/.gitignore"
git -C "${BROKEN_IGNORE_REPOSITORY}" add .gitignore
git -C "${BROKEN_IGNORE_REPOSITORY}" \
  -c user.name=WorkLink \
  -c user.email=worklink@example.com \
  commit -m "broken ignore" >/dev/null

if ./scripts/check_mobile_signing_governance.sh "${BROKEN_IGNORE_REPOSITORY}" >/dev/null 2>&1; then
  echo "Gate deveria bloquear .gitignore incompleto." >&2
  exit 1
fi

echo "Teste do gate de governanca de assinatura mobile aprovado."
