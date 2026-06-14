#!/usr/bin/env sh
set -eu

temporary_directory="$(mktemp -d)"
trap 'rm -rf "${temporary_directory}"' EXIT

if ./scripts/run_cloud_database_migrations.sh >"${temporary_directory}/missing-migration-env.out" 2>&1; then
  echo "Esperava falha quando as variaveis cloud de banco estao ausentes." >&2
  exit 1
fi

if ! grep -q "WORKLINK_CLOUD_DATABASE_URL" "${temporary_directory}/missing-migration-env.out"; then
  echo "Falha de migrations cloud nao apontou a variavel ausente esperada." >&2
  cat "${temporary_directory}/missing-migration-env.out" >&2
  exit 1
fi

for invalid_url in \
  "http://api.example.com" \
  "https://localhost:8080" \
  "https://127.0.0.1:8080" \
  "https://temporary.trycloudflare.com"; do
  if ./scripts/check_cloud_api_readiness.sh "${invalid_url}" >"${temporary_directory}/invalid-url.out" 2>&1; then
    echo "Esperava rejeicao da URL invalida ${invalid_url}." >&2
    exit 1
  fi
done

if ! grep -q "apps-s-1vcpu-0.5gb" deploy/digitalocean/worklink-api-app-platform.yaml.example; then
  echo "App spec precisa usar instance_size_slug atual documentado para App Platform." >&2
  exit 1
fi

for required_key in \
  WORKLINK_DATABASE_URL \
  WORKLINK_DATABASE_USERNAME \
  WORKLINK_DATABASE_PASSWORD \
  WORKLINK_JWT_SECRET \
  WORKLINK_FEATURE_LOCAL_AUTHENTICATION_ENABLED \
  WORKLINK_FEATURE_OTP_AUTHENTICATION_ENABLED \
  WORKLINK_FEATURE_SMS_ENABLED \
  WORKLINK_PASSWORD_RECOVERY_DELIVERY_MODE \
  WORKLINK_TEST_SUPPORT_FIXED_OTP \
  WORKLINK_TEST_SUPPORT_PASSWORD_RECOVERY_TOKEN_EXPOSURE_ENABLED; do
  if ! grep -q "${required_key}" deploy/digitalocean/worklink-api-app-platform.yaml.example; then
    echo "App spec nao contem ${required_key}." >&2
    exit 1
  fi
done

echo "Contrato de deploy cloud validado."
