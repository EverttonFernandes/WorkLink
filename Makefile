.PHONY: backend-test mobile-test test

backend-test:
	docker compose run --rm backend-tests

mobile-test:
	docker compose run --rm mobile-tests

test: backend-test mobile-test
