---
task_key: WLT-005
title: "Configuração segura e gestão de secrets"
story_path: "docs/jira-pessoal/historias-tecnicas/WLT-005-configuracao-segura-env-secrets.md"
official_order: 5
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
    summary: "Configuração segura iniciada a partir da próxima história oficial."
    evidence:
      - "docs/jira-pessoal/historias-tecnicas/WLT-005-configuracao-segura-env-secrets.md"
  - iteration: 1
    phase: DONE
    summary: "Configuração por env vars aplicada e validada em container."
    evidence:
      - "WORKLINK_ENV_FILE=.env.example docker compose --env-file .env.example config"
      - "make backend-test"
      - "git diff --check"
---

# WLT-005 — Configuração segura e gestão de secrets

## Status

Fase atual: `DONE`.

## Resultado

- `.env.example` versionado com valores fictícios.
- `.env` permanece ignorado pelo Git.
- Compose e Makefile passam a usar `.env` via `--env-file`.
- `worklink-api/src/main/resources/application.yml` centraliza leitura de configuração por variáveis de ambiente.
- Teste de contexto valida que propriedades sensíveis são resolvidas e não ficam como placeholder.

## Observações

- Secrets reais continuam fora do repositório.
- Secrets manager definitivo segue fora do escopo desta história.
- Em CI, as variáveis devem ser injetadas pelo mecanismo seguro da plataforma.
