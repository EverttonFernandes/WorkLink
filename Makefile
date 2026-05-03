.PHONY: backend-unit-test backend-integration-test backend-test mobile-unit-test mobile-screen-test mobile-test functional-test db-up db-down db-logs db-migrate test

backend-unit-test:
	docker compose run --rm backend-tests mvn test

backend-integration-test:
	docker compose run --rm backend-tests mvn verify

backend-test: backend-unit-test backend-integration-test

mobile-unit-test:
	docker compose run --rm mobile-tests sh -lc "flutter pub get && flutter test --coverage"

mobile-screen-test:
	docker compose run --rm mobile-tests sh -lc "flutter pub get && if find test -type f \( -path '*/screen/*' -o -path '*/screens/*' -o -path '*/tela/*' -o -path '*/telas/*' -o -name '*screen_test.dart' -o -name '*tela_test.dart' \) | grep -q .; then flutter test test --coverage; else echo 'N/A: testes de tela ainda nao foram criados.'; fi"

mobile-test: mobile-unit-test mobile-screen-test

functional-test:
	docker compose run --rm functional-tests

db-up:
	docker compose up -d postgres

db-down:
	docker compose down --remove-orphans

db-logs:
	docker compose logs -f postgres

db-migrate:
	docker compose run --rm database-migrations

test: backend-test mobile-test functional-test
