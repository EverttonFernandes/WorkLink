# Docker

Pasta reservada para containerizacao e ambiente local do WorkLink.

## Diretrizes

- A validacao local usa Docker Compose no arquivo raiz `compose.yml`.
- O Compose deve receber variaveis por `.env`; o Makefile cria esse arquivo a partir de `.env.example` quando ausente.
- `.env` nunca deve ser versionado; `.env.example` deve conter apenas valores ficticios.
- `make up` sobe PostgreSQL, Redis e MinIO.
- `make api` sobe a API containerizada e aguarda dependencias saudaveis.
- `make down` derruba os servicos do projeto.
- `make restart` reinicia o ambiente local.
- `make logs` acompanha logs dos servicos.
- `make clean` remove containers, volumes e artefatos gerados.
- `make static-analysis` executa analise estatica backend e mobile em containers.
- `make backend-unit-test` executa testes unitarios backend em container.
- `make backend-integration-test` executa o ciclo Maven `verify`, incluindo testes `*IntegrationTest` contra PostgreSQL em container.
- `make mobile-unit-test` executa testes mobile em container.
- `make mobile-screen-test` executa testes de tela mobile quando a suite existir.
- `make mobile-integration-test` executa testes de integracao mobile quando houver device suportado no container.
- `make functional-test` executa a suite funcional HTTP em Node quando houver cenarios reais, ou registra `N/A`.
- `make db-up` sobe o PostgreSQL local.
- `make db-migrate` aplica migrations no PostgreSQL usando Flyway em container.
- `make db-down` derruba os servicos Docker do projeto.
- `make test` agrega a matriz oficial de testes.
- A API usa `docker/worklink-api.Dockerfile` com build multi-stage.
- A imagem final de producao nao deve carregar ferramentas de build, caches, secrets ou dependencias de desenvolvimento.
- Imagens de runtime devem ser enxutas e previsiveis; quando houver imagem externa critica, preferir versao fixa ou digest.
