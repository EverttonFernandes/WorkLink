COMPOSE_ENV_FILE ?= .env
DOCKER_COMPOSE = WORKLINK_ENV_FILE=$(COMPOSE_ENV_FILE) docker compose --env-file $(COMPOSE_ENV_FILE)

.PHONY: up down restart logs api db redis storage migrate clean backend-static-analysis mobile-static-analysis static-analysis backend-unit-test backend-integration-test backend-test mobile-unit-test mobile-screen-test mobile-test functional-test test-unit test-integration test-functional db-up db-down db-logs db-migrate test

$(COMPOSE_ENV_FILE):
	cp .env.example $(COMPOSE_ENV_FILE)

up: $(COMPOSE_ENV_FILE)
	$(DOCKER_COMPOSE) up -d postgres redis minio

down: $(COMPOSE_ENV_FILE)
	$(DOCKER_COMPOSE) down --remove-orphans

restart: down up

logs: $(COMPOSE_ENV_FILE)
	$(DOCKER_COMPOSE) logs -f

api: $(COMPOSE_ENV_FILE)
	$(DOCKER_COMPOSE) up -d worklink-api

db: db-up

redis: $(COMPOSE_ENV_FILE)
	$(DOCKER_COMPOSE) up -d redis

storage: $(COMPOSE_ENV_FILE)
	$(DOCKER_COMPOSE) up -d minio

migrate: db-migrate

clean: $(COMPOSE_ENV_FILE)
	$(DOCKER_COMPOSE) down -v --remove-orphans
	rm -rf worklink-api/target worklink-mobile/build worklink-mobile/.dart_tool worklink-mobile/coverage

backend-static-analysis: $(COMPOSE_ENV_FILE)
	$(DOCKER_COMPOSE) run --rm backend-tests mvn checkstyle:check

mobile-static-analysis: $(COMPOSE_ENV_FILE)
	$(DOCKER_COMPOSE) run --rm mobile-tests sh -lc "flutter pub get && flutter analyze"

static-analysis: backend-static-analysis mobile-static-analysis

backend-unit-test: $(COMPOSE_ENV_FILE)
	$(DOCKER_COMPOSE) run --rm backend-tests mvn test jacoco:report jacoco:check@check

backend-integration-test: $(COMPOSE_ENV_FILE)
	$(DOCKER_COMPOSE) run --rm backend-tests mvn verify

backend-test: backend-unit-test backend-integration-test

mobile-unit-test: $(COMPOSE_ENV_FILE)
	$(DOCKER_COMPOSE) run --rm mobile-tests sh -lc "flutter pub get && flutter test --coverage"

mobile-screen-test: $(COMPOSE_ENV_FILE)
	$(DOCKER_COMPOSE) run --rm mobile-tests sh -lc "flutter pub get && if find test -type f \( -path '*/screen/*' -o -path '*/screens/*' -o -path '*/tela/*' -o -path '*/telas/*' -o -name '*screen_test.dart' -o -name '*tela_test.dart' \) | grep -q .; then flutter test test --coverage; else echo 'N/A: testes de tela ainda nao foram criados.'; fi"

mobile-test: mobile-unit-test mobile-screen-test

functional-test: $(COMPOSE_ENV_FILE)
	$(DOCKER_COMPOSE) run --rm functional-tests

test-unit: backend-unit-test mobile-unit-test

test-integration: backend-integration-test

test-functional: functional-test

db-up: $(COMPOSE_ENV_FILE)
	$(DOCKER_COMPOSE) up -d postgres

db-down: $(COMPOSE_ENV_FILE)
	$(DOCKER_COMPOSE) down --remove-orphans

db-logs: $(COMPOSE_ENV_FILE)
	$(DOCKER_COMPOSE) logs -f postgres

db-migrate: $(COMPOSE_ENV_FILE)
	$(DOCKER_COMPOSE) run --rm database-migrations

test: static-analysis backend-test mobile-test functional-test
