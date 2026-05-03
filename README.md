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
make backend-unit-test
make backend-integration-test
make backend-test
make mobile-unit-test
make mobile-screen-test
make mobile-test
make functional-test
make test
```

Os comandos usam `compose.yml` e caches em volumes Docker para Maven e Pub.

`make test` e a agregacao oficial para a matriz esperada do projeto: testes unitarios backend, integracao backend,
unitarios mobile, testes de tela mobile e testes funcionais. Enquanto uma suite ainda nao existir, o alvo correspondente
registra `N/A` sem exigir instalacao de ferramentas no host.

## Fontes de verdade

- `docs/README.md`
- `docs/jira-pessoal/KANBAN-OFICIAL.md`
- `docs/requisitos/epico-requisitos-de-negocio.md`
- `docs/requisitos/epico-requisitos-nao-funcionais.md`
- `docs/spec-driven-development/spec-driven-development.md`
