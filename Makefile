COMPOSE_ENV_FILE ?= .env
DOCKER_COMPOSE = WORKLINK_ENV_FILE=$(COMPOSE_ENV_FILE) docker compose --env-file $(COMPOSE_ENV_FILE)

.PHONY: up down restart logs api db redis storage migrate clean \
	backend-static-analysis mobile-static-analysis static-analysis \
	backend-unit-test backend-integration-test backend-test backend-image-build \
	mobile-unit-test mobile-screen-test mobile-integration-test mobile-android-build \
	mobile-emulator-prereqs \
	mobile-test mobile-emulator-up mobile-emulator-wait mobile-emulator-install \
	mobile-emulator-integration-test mobile-manual-test functional-test test-unit test-integration test-functional \
	db-up db-down db-logs db-migrate test ci

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
	sudo rm -rf worklink-api/target worklink-mobile/build worklink-mobile/.dart_tool worklink-mobile/coverage

backend-static-analysis: $(COMPOSE_ENV_FILE)
	$(DOCKER_COMPOSE) run --rm backend-tests mvn -DskipTests -DskipITs -Djacoco.skip=true compile test-compile checkstyle:check spotbugs:check pmd:check

mobile-static-analysis: $(COMPOSE_ENV_FILE)
	$(DOCKER_COMPOSE) run --rm mobile-tests sh -lc "flutter pub get && flutter analyze"

static-analysis: backend-static-analysis mobile-static-analysis

backend-unit-test: $(COMPOSE_ENV_FILE)
	rm -rf worklink-api/target/jacoco.exec || true
	$(DOCKER_COMPOSE) run --rm backend-tests mvn test jacoco:report jacoco:check@check

backend-integration-test: $(COMPOSE_ENV_FILE)
	rm -rf worklink-api/target/jacoco.exec || true
	$(DOCKER_COMPOSE) run --rm backend-tests mvn verify

backend-test: backend-unit-test backend-integration-test

backend-image-build:
	docker build -f docker/worklink-api.Dockerfile -t worklink-api:local .

mobile-unit-test: $(COMPOSE_ENV_FILE)
	$(DOCKER_COMPOSE) run --rm mobile-tests sh -lc "rm -rf coverage && flutter pub get && flutter test test/unit --coverage && awk -F: '/^LF:/{lf+=\$$2}/^LH:/{lh+=\$$2} END { if (lf == 0) { print \"N/A: cobertura mobile sem linhas rastreaveis.\"; exit 0 } coverage=(lh/lf)*100; printf \"Cobertura mobile unitarios: %.2f%%\\n\", coverage; if (coverage < 95) exit 1 }' coverage/lcov.info"

mobile-screen-test: $(COMPOSE_ENV_FILE)
	$(DOCKER_COMPOSE) run --rm mobile-tests sh -lc "rm -rf coverage && flutter pub get && if find test -type f \( -path '*/widget/*' -o -path '*/widgets/*' -o -path '*/screen/*' -o -path '*/screens/*' -o -path '*/tela/*' -o -path '*/telas/*' -o -name '*widget_test.dart' -o -name '*screen_test.dart' -o -name '*tela_test.dart' \) | grep -q .; then flutter test test/widget --coverage; else echo 'N/A: testes de tela ainda nao foram criados.'; fi"

mobile-integration-test: $(COMPOSE_ENV_FILE)
	$(DOCKER_COMPOSE) run --rm database-migrations
	$(DOCKER_COMPOSE) up -d --wait worklink-api
	$(DOCKER_COMPOSE) run --rm -e API_BASE_URL=http://worklink-api:8080 mobile-tests sh -lc "./tool/run_mobile_integration_tests.sh"

mobile-android-build: $(COMPOSE_ENV_FILE)
	rm -rf worklink-mobile/android/.gradle
	$(DOCKER_COMPOSE) run --rm mobile-tests sh -lc "flutter pub get && if [ -d android ]; then flutter build apk --debug; else echo 'N/A: projeto Android ainda nao foi gerado.'; fi"

mobile-test: mobile-unit-test mobile-screen-test mobile-integration-test

mobile-emulator-prereqs:
	./scripts/check_android_emulator_prereqs.sh

mobile-emulator-up: $(COMPOSE_ENV_FILE)
	$(DOCKER_COMPOSE) up -d android-emulator

mobile-emulator-wait: $(COMPOSE_ENV_FILE)
	COMPOSE_ENV_FILE=$(COMPOSE_ENV_FILE) ./scripts/wait_for_android_emulator.sh

mobile-emulator-install: $(COMPOSE_ENV_FILE)
	COMPOSE_ENV_FILE=$(COMPOSE_ENV_FILE) ./scripts/install_debug_apk_on_emulator.sh

mobile-emulator-integration-test: $(COMPOSE_ENV_FILE) mobile-emulator-prereqs
	$(DOCKER_COMPOSE) up -d postgres redis minio
	$(DOCKER_COMPOSE) run --rm database-migrations
	$(DOCKER_COMPOSE) up -d --wait worklink-api android-emulator
	$(MAKE) mobile-emulator-wait
	$(DOCKER_COMPOSE) run --rm \
		-e ADB_TARGET=android-emulator:5555 \
		-e DEVICE_ID=android-emulator:5555 \
		-e API_BASE_URL=http://worklink-api:8080 \
		mobile-tests sh -lc "./tool/run_mobile_local_emulator_integration_tests.sh"

mobile-manual-test: $(COMPOSE_ENV_FILE) mobile-emulator-prereqs
	$(DOCKER_COMPOSE) up -d postgres redis minio
	$(DOCKER_COMPOSE) run --rm database-migrations
	$(DOCKER_COMPOSE) up -d --wait worklink-api
	$(MAKE) mobile-android-build
	$(MAKE) mobile-emulator-up
	$(MAKE) mobile-emulator-wait
	$(MAKE) mobile-emulator-install

functional-test: $(COMPOSE_ENV_FILE)
	$(DOCKER_COMPOSE) down -v --remove-orphans
	$(DOCKER_COMPOSE) up -d postgres redis minio
	$(DOCKER_COMPOSE) run --rm database-migrations
	$(DOCKER_COMPOSE) up -d --wait worklink-api
	$(DOCKER_COMPOSE) run --rm functional-tests

test-unit: backend-unit-test mobile-unit-test

test-integration: backend-integration-test mobile-integration-test

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

ci: static-analysis backend-test mobile-test functional-test backend-image-build mobile-android-build
