#!/usr/bin/env sh
set -eu

require_variable() {
  variable_name="$1"
  variable_value="$(eval "printf '%s' \"\${${variable_name}:-}\"")"

  if [ -z "${variable_value}" ]; then
    echo "Defina ${variable_name} antes de executar migrations cloud." >&2
    exit 1
  fi
}

require_variable WORKLINK_CLOUD_DATABASE_URL
require_variable WORKLINK_CLOUD_DATABASE_USERNAME
require_variable WORKLINK_CLOUD_DATABASE_PASSWORD

DOCKER_COMMAND="${DOCKER:-docker}"

"${DOCKER_COMMAND}" run --rm \
  -v "$(pwd)/worklink-api/src/main/resources/db/migration:/flyway/sql:ro" \
  flyway/flyway:10-alpine \
  -url="${WORKLINK_CLOUD_DATABASE_URL}" \
  -user="${WORKLINK_CLOUD_DATABASE_USERNAME}" \
  -password="${WORKLINK_CLOUD_DATABASE_PASSWORD}" \
  -defaultSchema=public \
  -schemas=public,worklink \
  -connectRetries=10 \
  migrate
