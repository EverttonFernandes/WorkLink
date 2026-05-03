---
task_key: WLT-003
title: "PostgreSQL e consistência transacional"
story_path: "docs/jira-pessoal/historias-tecnicas/WLT-003-banco-postgresql-consistencia.md"
official_order: 3
phase: DONE
loop_iteration: 1
version_suggestion: MINOR
func_tests_detected: false
func_tests_path: ""
func_tests_framework: ""
exit_bar:
  lint: PASS
  unit_tests: N/A
  integration_tests: PASS
  func_tests: N/A
  mobile_tests: N/A
  coverage: N/A
  sonar: N/A
  sre: PASS
  security: PASS
  arch_review: PASS
  final_review: PASS
metrics:
  unit_coverage_minimum: 95
  migrations_applied: 1
  changed_files: 9
  risk_level: LOW
correction_queue: []
cycle_history:
  - iteration: 0
    phase: PLANNING
    summary: "WLT-003 iniciada a partir do Kanban Oficial."
    evidence:
      - "docs/jira-pessoal/historias-tecnicas/WLT-003-banco-postgresql-consistencia.md"
      - "docs/requisitos/epico-requisitos-nao-funcionais.md"
  - iteration: 1
    phase: EXECUTION
    summary: "PostgreSQL, Flyway, migration inicial e documentação de consistência adicionados sem modelar domínio funcional antecipado."
    evidence:
      - "compose.yml"
      - "Makefile"
      - "worklink-api/src/main/resources/db/migration/V001__create_worklink_schema.sql"
      - "docs/arquitetura/postgresql-consistencia-transacional.md"
  - iteration: 1
    phase: VALIDATION
    summary: "Migration executada com sucesso em Docker."
    evidence:
      - "docker compose config: PASS"
      - "make -n db-migrate: PASS"
      - "git diff --check: PASS"
      - "make db-migrate: Successfully applied 1 migration"
      - "psql: public.flyway_schema_history e worklink.database_migration_marker existem"
---

# WLT-003 — PostgreSQL e consistência transacional

## Status

História concluída.

Fase atual: `DONE`.

## Objetivo

Estabelecer PostgreSQL como fonte da verdade para dados transacionais críticos e preparar migrations executáveis localmente.

## Decisão de escopo

Esta história não criou tabelas funcionais de usuários, profissionais, cidades ou categorias. Essas tabelas pertencem às histórias funcionais que modelarem o domínio.

A entrega realizada foi:

- PostgreSQL disponível via Docker Compose;
- migration inicial mínima e executável;
- comando Makefile para aplicar migrations;
- documentação da estratégia de consistência;
- cache explicitamente proibido como fonte da verdade.

## Estratégia de consistência

- Dados críticos usam consistência forte no PostgreSQL.
- Dados derivados podem usar consistência eventual apenas quando classificados explicitamente.
- Redis/cache nunca é fonte da verdade.
- Migrations devem ser versionadas, revisáveis e executáveis em Docker.

## Implementação

- Serviço `postgres` em `compose.yml`.
- Serviço `database-migrations` usando Flyway em container.
- Volume `postgres-data` para persistência local do banco.
- Alvos `db-up`, `db-down`, `db-logs` e `db-migrate` no `Makefile`.
- Migration `V001__create_worklink_schema.sql`.
- Documento `docs/arquitetura/postgresql-consistencia-transacional.md`.

## Validações executadas

- `docker compose config`: passou.
- `make -n db-migrate`: passou.
- `git diff --check`: passou.
- `make db-migrate`: aplicou `1` migration com sucesso.
- Consulta via `psql`: confirmou `public.flyway_schema_history` e `worklink.database_migration_marker`.

## Observações de segurança

As credenciais em `compose.yml` são credenciais locais de desenvolvimento para container Docker. Gestão segura de secrets, `.env.example` e hardening de configuração serão tratados em `WLT-005`.

## Resultado

WLT-003 entrega a base de PostgreSQL e migrations para que as próximas histórias funcionais modelem dados críticos com consistência forte.
