# WorkLink

WorkLink e uma plataforma mobile-first para conectar usuarios a profissionais locais com sinais progressivos de confianca, disponibilidade, responsividade e reputacao.

## Estrutura do monorepo

- `worklink-api/`: backend Java 21 + Spring Boot.
- `worklink-mobile/`: aplicativo Flutter/Dart.
- `functional-tests/`: testes funcionais/E2E da API e fluxos criticos.
- `docker/`: arquivos de containerizacao e ambiente local.
- `docs/`: documentacao viva, requisitos, backlog, padroes e artefatos dos agentes.

## Validacao local via Docker

As ferramentas de build nao precisam ser instaladas diretamente na maquina. A validacao base da WLT-001 roda em
containers Docker:

```bash
make up
make api
make logs
make down
make clean
make backend-static-analysis
make mobile-static-analysis
make static-analysis
make backend-unit-test
make backend-integration-test
make backend-test
make mobile-unit-test
make mobile-screen-test
make mobile-test
make functional-test
make db-up
make db-migrate
make db-down
make test
```

Os comandos usam `compose.yml` e caches em volumes Docker para Maven e Pub.

`make up` sobe as dependencias locais principais: PostgreSQL, Redis e MinIO. `make api` sobe a API em imagem
multi-stage, aguardando as dependencias saudaveis antes do runtime. `make clean` remove containers, volumes e artefatos
gerados de build.

Na primeira execucao, o Makefile cria `.env` a partir de `.env.example` quando o arquivo local ainda nao existir.
O `.env` real fica ignorado pelo Git; somente o exemplo com valores ficticios e versionado.

`make static-analysis` agrega os gates de qualidade estatica do backend e mobile. Violacoes criticas de nomenclatura,
lint ou analise bloqueiam a continuidade da entrega.

`make backend-unit-test` executa testes unitarios Java com relatorio JaCoCo e gate minimo de 95%.
`make backend-integration-test` executa o ciclo Maven `verify`, incluindo testes `*IntegrationTest` contra PostgreSQL em container.
`make functional-test` executa a suite funcional HTTP em Node dentro de container quando houver cenarios reais.

`make test` e a agregacao oficial para a matriz esperada do projeto: testes unitarios backend, integracao backend,
unitarios mobile, testes de tela mobile e testes funcionais. Enquanto uma suite ainda nao existir, o alvo correspondente
registra `N/A` sem exigir instalacao de ferramentas no host.

`make db-migrate` sobe PostgreSQL em Docker e executa as migrations versionadas do backend via Flyway.

## Fontes de verdade

- `docs/README.md`
- `docs/jira-pessoal/KANBAN-OFICIAL.md`
- `docs/requisitos/epico-requisitos-de-negocio.md`
- `docs/requisitos/epico-requisitos-nao-funcionais.md`
- `docs/spec-driven-development/spec-driven-development.md`
