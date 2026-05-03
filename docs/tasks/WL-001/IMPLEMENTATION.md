---
task_key: WL-001
title: "Fundação de categorias, cidades e profissionais mínimos"
story_path: "docs/jira-pessoal/historias/WL-001-fundacao-categorias-cidades-profissionais.md"
official_order: 10
phase: DONE
loop_iteration: 1
version_suggestion: MINOR
func_tests_detected: false
func_tests_path: "functional-tests/src/**/*.spec.js"
func_tests_framework: "Jest + Axios"
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
  changed_files: 61
  risk_level: MEDIUM
correction_queue: []
cycle_history:
  - iteration: 0
    phase: EXECUTION
    summary: "WL-001 iniciada a partir da próxima história oficial do Kanban unificado."
    evidence:
      - "docs/jira-pessoal/historias/WL-001-fundacao-categorias-cidades-profissionais.md"
  - iteration: 1
    phase: DONE
    summary: "Fundação de categorias, cidades e profissionais mínimos implementada em DDD tático com ports and adapters."
    evidence:
      - "make backend-static-analysis"
      - "make backend-unit-test"
      - "make backend-integration-test"
---

# WL-001 — Fundação de categorias, cidades e profissionais mínimos

## Status

Fase atual: `DONE`.

## Resultado

- Criada migration `V002__create_catalog_and_professional_foundation.sql`.
- Criados agregados de domínio para categoria, cidade e profissional.
- Criados casos de uso e portas de aplicação sem acoplamento a framework.
- Criados adapters JDBC para persistência PostgreSQL.
- Criados endpoints REST `POST/GET /api/v1/categories`, `POST/GET /api/v1/cities` e `POST/GET /api/v1/professionals`.
- Perfil profissional mínimo é sempre `BASIC_PROFILE` e `qualityGuarantee=false`.

## Observações

- A API consome respostas de aplicação, não entidades de domínio.
- Testes funcionais externos permanecem `N/A` porque ainda não há suíte funcional HTTP versionada em `functional-tests/src`.
- Telas mobile permanecem fora do escopo desta história.
