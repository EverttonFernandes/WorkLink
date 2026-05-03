# Entrega WLT-003 — PostgreSQL e consistência transacional

## Identificador

- História: `WLT-003`
- Data: `2026-05-03`
- Tipo semântico sugerido: `MINOR`

## Objetivo de negócio

Preparar a persistência transacional do WorkLink para dados críticos como usuários, profissionais, cidades, contatos, avaliações, denúncias e auditoria.

## Personas afetadas

- Usuário cliente: sem mudança funcional direta nesta entrega.
- Profissional: sem mudança funcional direta nesta entrega.
- Administrador: sem mudança funcional direta nesta entrega.
- Plataforma: ganha PostgreSQL e migrations como fundação de consistência.

## Requisitos atendidos

- RNF02: qualidade, consistência e testabilidade.
- RNF15: documentação viva e rastreabilidade técnica.

## O que foi implementado

- Serviço PostgreSQL no Docker Compose.
- Serviço Flyway para migrations no Docker Compose.
- Migration inicial `V001__create_worklink_schema.sql`.
- Alvos Makefile para banco: `db-up`, `db-down`, `db-logs`, `db-migrate`.
- Documento de consistência transacional.

## O que não foi implementado

- Tabelas funcionais de domínio.
- Repositórios JPA.
- Read replicas.
- Banco distribuído.
- Event Sourcing.
- OpenSearch.

## Fluxos, telas, endpoints ou módulos envolvidos

- Banco local: PostgreSQL.
- Migrations: Flyway.
- Backend: pasta `src/main/resources/db/migration`.
- Mobile: `N/A`.

## Estratégia de testes

- Integração/SRE: `make db-migrate`.
- Unitários: `N/A`, sem código de produção testável novo.
- Funcionais/E2E: `N/A`.
- Mobile: `N/A`.

## Evidências de validação

- `docker compose config`: passou.
- `make -n db-migrate`: passou.
- `git diff --check`: passou.
- `make db-migrate`: aplicou `1` migration.
- Consulta via `psql`: confirmou `public.flyway_schema_history` e `worklink.database_migration_marker`.

## Riscos ou limitações remanescentes

- Credenciais locais do PostgreSQL ainda são valores de desenvolvimento no Compose; hardening e `.env.example` serão tratados em `WLT-005`.
- Tabelas reais devem ser criadas somente nas histórias funcionais correspondentes.
- Cache não deve ser usado como fonte da verdade em histórias futuras.

## Arquivos ou módulos relevantes

- `compose.yml`
- `Makefile`
- `docs/arquitetura/postgresql-consistencia-transacional.md`
- `worklink-api/src/main/resources/db/migration/V001__create_worklink_schema.sql`
- `docs/tasks/WLT-003/`

## Justificativa do versionamento

A entrega adiciona uma capacidade técnica nova: PostgreSQL e migrations executáveis localmente via Docker. Por isso, a versão semântica sugerida é `MINOR`.
