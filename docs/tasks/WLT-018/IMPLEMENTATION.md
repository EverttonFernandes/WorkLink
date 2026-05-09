---
task_key: WLT-018
title: "Documentação técnica, ADRs e release mobile"
story_path: "docs/jira-pessoal/historias-tecnicas/WLT-018-documentacao-adrs-release-mobile.md"
official_order: 35
phase: DONE
loop_iteration: 1
version_suggestion: MINOR
func_tests_detected: false
func_tests_path: "functional-tests/src/**/*.spec.js"
func_tests_framework: "Jest + Axios sem cenários reais executáveis no momento"
exit_bar:
  lint: N/A
  unit_tests: N/A
  integration_tests: N/A
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
  changed_files: 23
  risk_level: LOW
release:
  commit_hash: ""
  semantic_tag: v0.35.0
correction_queue: []
cycle_history:
  - iteration: 0
    phase: EXECUTION
    summary: "WLT-018 iniciada como fechamento documental e estratégia de release mobile."
    evidence:
      - "docs/jira-pessoal/historias-tecnicas/WLT-018-documentacao-adrs-release-mobile.md"
  - iteration: 1
    phase: DONE
    summary: "Fechamento documental concluído com README, ADRs, OpenAPI, C4, segurança, operação e release mobile."
    evidence:
      - "docs/api/openapi.yaml"
      - "docs/adrs/"
      - "docs/arquitetura/c4-model.md"
      - "docs/seguranca/"
      - "docs/operacao/"
      - "docs/release/release-mobile.md"
      - "git diff --check: PASS"
---

# WLT-018 — Documentação técnica, ADRs e release mobile

## Plano BDD/TDD

- Dado um novo mantenedor, quando abrir o repositório, então deve encontrar README principal com comandos e fontes de
  verdade.
- Dado um desenvolvedor backend/mobile, quando precisar validar a entrega, então deve encontrar guia de testes e
  ambiente via Docker.
- Dado uma decisão arquitetural importante, quando auditar o projeto, então deve encontrar ADRs iniciais.
- Dado um fluxo sensível, quando revisar segurança, então deve encontrar threat model e checklist OWASP.
- Dado uma publicação mobile, quando preparar release, então deve encontrar estratégia Android, iOS, rollout e rollback.

## Decisões

- A documentação OpenAPI será estática em `docs/api/openapi.yaml` até existir necessidade real de Swagger UI runtime.
- O release mobile será estratégia e checklist; publicação real nas lojas fica fora do escopo.
- Gates de código são N/A porque a história altera documentação, não comportamento executável.

## Log de Iterações

- Iteração 0: plano criado para fechamento documental.
- Iteração 1: documentação concluída e validada por revisão de escopo e whitespace.
