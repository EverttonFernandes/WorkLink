---
task_key: WLT-004
title: "Ambiente local reproduzível"
story_path: "docs/jira-pessoal/historias-tecnicas/WLT-004-ambiente-local-docker-makefile.md"
official_order: 4
phase: DONE
loop_iteration: 1
version_suggestion: MINOR
func_tests_detected: false
func_tests_path: ""
func_tests_framework: ""
exit_bar:
  lint: PASS
  unit_tests: PASS
  integration_tests: PASS
  func_tests: N/A
  mobile_tests: N/A
  coverage: PASS
  sonar: N/A
  sre: PASS
  security: PASS
  arch_review: PASS
  final_review: PASS
metrics:
  unit_coverage_minimum: 95
  changed_files: 12
  risk_level: MEDIUM
correction_queue: []
cycle_history:
  - iteration: 0
    phase: EXECUTION
    summary: "WLT-004 iniciada e ambiente Docker ampliado."
    evidence:
      - "docker/worklink-api.Dockerfile"
      - "compose.yml"
      - "Makefile"
  - iteration: 1
    phase: DONE
    summary: "Ambiente local reproduzivel validado em Docker."
    evidence:
      - "docker compose config"
      - "docker compose build worklink-api"
      - "make up"
      - "make api"
      - "docker compose exec -T worklink-api wget -qO- http://localhost:8080/actuator/health"
      - "make backend-test"
---

# WLT-004 — Ambiente local reproduzível

## Status

Fase atual: `DONE`.

## Objetivo

Permitir subir e operar dependências locais com comandos simples e previsíveis, sem instalar ferramentas diretamente na máquina.

## Implementação planejada

- `make up`: sobe dependências principais.
- `make down`: derruba o ambiente.
- `make restart`: reinicia dependências.
- `make logs`: acompanha logs.
- `make api`: sobe a API containerizada.
- `make db`: sobe PostgreSQL.
- `make redis`: sobe Redis.
- `make storage`: sobe MinIO.
- `make migrate`: aplica migrations.
- `make clean`: remove containers, volumes e artefatos gerados.

## Dockerfile da API

O Dockerfile deve ser multi-stage:

- estágio `build`: Maven + JDK 21;
- estágio `runtime`: JRE 21 enxuto;
- runtime sem Maven, cache ou código-fonte;
- usuário não-root;
- healthcheck via actuator.

## Resultado

- Ambiente local opera somente com Docker Compose e Makefile.
- API empacotada em imagem multi-stage.
- PostgreSQL, Redis e MinIO sobem com healthcheck.
- MinIO foi fixado por digest para evitar uso mutavel de `latest`.
- O backend foi validado com `make backend-test` em container.
