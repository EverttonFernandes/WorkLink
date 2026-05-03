# Entrega WLT-007 — Testabilidade backend

## Resultado

Base de testabilidade backend configurada para unitários, integração e funcionais HTTP, executando tudo em containers Docker.

## Entregues

- Surefire configurado para testes unitários.
- Failsafe configurado para testes `*IntegrationTest`.
- `make backend-unit-test` com relatório JaCoCo e gate mínimo de 95%.
- Teste de integração validando migrations no PostgreSQL real containerizado.
- Runner funcional em Node/Jest/Axios com `npm ci`.
- `npm audit --audit-level=moderate` sem vulnerabilidades.
- Documentação operacional atualizada.

## Validações

- `make backend-static-analysis`
- `make backend-unit-test`
- `make backend-integration-test`
- `make functional-test`
- `docker run --rm -v "$PWD/functional-tests:/workspace/functional-tests" -w /workspace/functional-tests node:20-alpine npm audit --audit-level=moderate`
- `git diff --check`

## Observações

- Testes funcionais estão preparados, mas retornam N/A até existirem endpoints/cenários reais.
- A integração usa PostgreSQL via Docker Compose porque a suíte Maven roda dentro de container e não deve exigir instalação local.
