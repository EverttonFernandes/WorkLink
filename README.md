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
make backend-test
make mobile-test
make test
```

Os comandos usam `compose.yml` e caches em volumes Docker para Maven e Pub.

## Fontes de verdade

- `docs/README.md`
- `docs/jira-pessoal/KANBAN-OFICIAL.md`
- `docs/requisitos/epico-requisitos-de-negocio.md`
- `docs/requisitos/epico-requisitos-nao-funcionais.md`
- `docs/spec-driven-development/spec-driven-development.md`
