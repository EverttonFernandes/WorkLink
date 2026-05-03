# Entrega WLT-006 — Qualidade estática e clean code

## Resultado

Gates de qualidade estática para backend e mobile foram configurados e integrados ao fluxo local via Docker.

## Entregues

- Checkstyle configurado no backend Maven com regras de nomenclatura, imports, blocos, estrutura e legibilidade.
- `analysis_options.yaml` configurado no mobile Flutter com lints explícitos.
- `Makefile` com alvos `backend-static-analysis`, `mobile-static-analysis` e `static-analysis`.
- Alvo `test` executando análise estática antes dos testes aplicáveis.
- Documentação atualizada em `README.md` e `docker/README.md`.
- Ajuste pontual no app mobile para aderir ao lint.

## Validações

- `make backend-static-analysis`
- `make mobile-static-analysis`
- `make backend-test`
- `make mobile-test functional-test`
- `WORKLINK_ENV_FILE=.env.example docker compose --env-file .env.example config`
- `git diff --check`

## Observações

- Testes de tela e funcionais ainda retornam N/A porque os casos reais não existem nesta etapa.
- SonarQube/SonarCloud será tratado quando o gate externo estiver configurado.
- A execução foi feita em containers Docker, sem instalação direta de ferramentas na máquina local.
