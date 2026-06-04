COMPOSE_ENV_FILE ?= .env
DOCKER ?= docker
DOCKER_COMPOSE = WORKLINK_ENV_FILE=$(COMPOSE_ENV_FILE) $(DOCKER) compose --env-file $(COMPOSE_ENV_FILE)

.PHONY: up down restart logs api db redis storage migrate clean \
	backend-static-analysis mobile-static-analysis static-analysis \
	backend-unit-test backend-integration-test backend-test backend-image-build \
	mobile-unit-test mobile-screen-test mobile-integration-test mobile-android-build \
	mobile-android-test-candidate mobile-android-local-fullstack-candidate mobile-android-homologation-candidate mobile-emulator-prereqs \
	mobile-visual-qa-gate mobile-product-homologation-gate mobile-signing-governance mobile-release-promotion-governance ios-readiness-check \
	mobile-web-preview mobile-web-preview-wait mobile-web-preview-stop mobile-web-preview-logs \
	mobile-test mobile-emulator-up mobile-emulator-wait mobile-emulator-install \
	mobile-emulator-integration-test mobile-manual-test functional-test test-unit test-integration test-functional \
	homologation-local-up homologation-seed promote-android-homologation-artifact \
	generate-android-homologation-keystore configure-android-homologation-github-env \
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
	$(DOCKER) build -f docker/worklink-api.Dockerfile -t worklink-api:local .

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

mobile-android-test-candidate: $(COMPOSE_ENV_FILE)
	$(DOCKER_COMPOSE) run --rm mobile-tests sh -lc "flutter pub get && flutter build apk --debug --dart-define=WORKLINK_USE_PREVIEW_DATA=true"
	./scripts/prepare_android_test_candidate.sh

mobile-android-local-fullstack-candidate: $(COMPOSE_ENV_FILE)
	@test -n "$(MOBILE_LOCAL_API_BASE_URL)" || (echo "Defina MOBILE_LOCAL_API_BASE_URL com a URL local do backend acessivel pelo celular." >&2; exit 1)
	$(DOCKER_COMPOSE) run --rm mobile-tests sh -lc "flutter pub get && flutter build apk --debug '--dart-define=API_BASE_URL=$(MOBILE_LOCAL_API_BASE_URL)'"
	OUTPUT_DIR=artifacts/android-local-fullstack-candidate \
		APK_NAME=worklink-android-local-fullstack.apk \
		ARTIFACT_TYPE=android-local-fullstack-candidate \
		APP_DATA_MODE=local-fullstack \
		API_BASE_URL="$(MOBILE_LOCAL_API_BASE_URL)" \
		./scripts/prepare_android_test_candidate.sh

mobile-android-homologation-candidate: $(COMPOSE_ENV_FILE)
	@test -n "$(MOBILE_HOMOLOGATION_API_BASE_URL)" || (echo "Defina MOBILE_HOMOLOGATION_API_BASE_URL com a URL do backend de homologacao." >&2; exit 1)
	./scripts/validate_homologation_api_base_url.sh "$(MOBILE_HOMOLOGATION_API_BASE_URL)"
	$(DOCKER_COMPOSE) run --rm \
		-e WORKLINK_ANDROID_HOMOLOGATION_KEYSTORE_BASE64 \
		-e WORKLINK_ANDROID_HOMOLOGATION_KEYSTORE_PASSWORD \
		-e WORKLINK_ANDROID_HOMOLOGATION_KEY_ALIAS \
		-e WORKLINK_ANDROID_HOMOLOGATION_KEY_PASSWORD \
		-e WORKLINK_ANDROID_HOMOLOGATION_KEYSTORE_PATH=android/app/homologation-upload.jks \
		mobile-tests sh -lc "/workspace/scripts/prepare_android_homologation_signing.sh && flutter pub get && flutter build apk --release '--dart-define=API_BASE_URL=$(MOBILE_HOMOLOGATION_API_BASE_URL)'"
	OUTPUT_DIR=artifacts/android-homologation-candidate \
		APK_NAME=worklink-android-homologation.apk \
		APK_SOURCE=worklink-mobile/build/app/outputs/flutter-apk/app-release.apk \
		ARTIFACT_TYPE=android-homologation-candidate \
		BUILD_TYPE=release \
		SIGNING=android_homologation_key \
		APP_DATA_MODE=homologation-fullstack \
		API_BASE_URL="$(MOBILE_HOMOLOGATION_API_BASE_URL)" \
		./scripts/prepare_android_test_candidate.sh

mobile-visual-qa-gate:
	@test -n "$(TASK_KEY)" || (echo "Defina TASK_KEY=WLT-000 para validar as evidencias visuais da historia." >&2; exit 1)
	./scripts/check_mobile_visual_evidence_gate.sh "$(TASK_KEY)"

mobile-product-homologation-gate:
	@test -n "$(ARTIFACT_DIR)" || (echo "Defina ARTIFACT_DIR=artifacts/android-homologation-candidate." >&2; exit 1)
	./scripts/check_mobile_product_homologation_governance.sh "$(ARTIFACT_DIR)"

mobile-signing-governance:
	./scripts/check_mobile_signing_governance.sh

mobile-release-promotion-governance:
	./scripts/check_mobile_release_promotion_governance.sh

ios-readiness-check:
	./scripts/check_ios_project_readiness.sh

mobile-web-preview: $(COMPOSE_ENV_FILE)
	$(DOCKER_COMPOSE) up -d mobile-web-preview
	$(MAKE) mobile-web-preview-wait
	@echo "Preview web do WorkLink disponivel em http://localhost:$${WORKLINK_MOBILE_WEB_PREVIEW_PORT:-18080}"

mobile-web-preview-wait:
	./scripts/wait_for_mobile_web_preview.sh

mobile-web-preview-stop: $(COMPOSE_ENV_FILE)
	$(DOCKER_COMPOSE) stop mobile-web-preview

mobile-web-preview-logs: $(COMPOSE_ENV_FILE)
	$(DOCKER_COMPOSE) logs -f mobile-web-preview

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

homologation-local-up: $(COMPOSE_ENV_FILE)
	$(DOCKER_COMPOSE) up -d postgres redis minio
	$(DOCKER_COMPOSE) run --rm database-migrations
	$(DOCKER_COMPOSE) up -d --wait worklink-api
	$(MAKE) homologation-seed

homologation-seed: $(COMPOSE_ENV_FILE)
	$(DOCKER_COMPOSE) run --rm -e WORKLINK_HOMOLOGATION_RESET=true functional-tests \
		sh -lc "npm ci && node src/scripts/seedHomologationScenario.js"

promote-android-homologation-artifact:
	@test -n "$(VERSION)" || (echo "Defina VERSION=vX.Y.Z." >&2; exit 1)
	@test -n "$(RUN_ID)" || (echo "Defina RUN_ID=<github-actions-run-id>." >&2; exit 1)
	./scripts/promote_android_homologation_artifact.sh "$(VERSION)" "$(RUN_ID)" "$(ARTIFACT_NAME)"

generate-android-homologation-keystore:
	./scripts/generate_android_homologation_keystore.sh

configure-android-homologation-github-env:
	@test -n "$(WORKLINK_HOMOLOGATION_API_BASE_URL)" || (echo "Defina WORKLINK_HOMOLOGATION_API_BASE_URL=https://..." >&2; exit 1)
	./scripts/configure_android_homologation_github_env.sh "$(WORKLINK_HOMOLOGATION_API_BASE_URL)"

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
