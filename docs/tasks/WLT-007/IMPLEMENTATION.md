---
task_key: WLT-007
title: "Testabilidade backend"
story_path: "docs/jira-pessoal/historias-tecnicas/WLT-007-testabilidade-backend.md"
official_order: 7
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
  changed_files: 20
  risk_level: MEDIUM
correction_queue: []
cycle_history:
  - iteration: 0
    phase: EXECUTION
    summary: "Testabilidade backend iniciada a partir da próxima história oficial."
    evidence:
      - "docs/jira-pessoal/historias-tecnicas/WLT-007-testabilidade-backend.md"
  - iteration: 1
    phase: DONE
    summary: "Base de testes backend e runner funcional foram configurados e validados em containers Docker."
    evidence:
      - "make backend-static-analysis"
      - "make backend-unit-test"
      - "make backend-integration-test"
      - "make functional-test"
      - "npm audit --audit-level=moderate"
      - "git diff --check"
---

# WLT-007 — Testabilidade backend

## Status

Fase atual: `DONE`.

## Resultado

- Maven separa unitários (`mvn test`) de integração (`mvn verify`) usando Surefire e Failsafe.
- `make backend-unit-test` executa unitários com JaCoCo e gate mínimo de 95%.
- `make backend-integration-test` executa integração contra PostgreSQL real em container.
- Teste de integração aplica migrations com Flyway, valida execução e confirma tabela crítica criada.
- `functional-tests` passa a ter base Node/Jest/Axios com `npm ci`, audit e ponto de entrada `run.sh`.

## Observações

- Testes funcionais ainda retornam N/A porque não existem endpoints de negócio reais.
- A suíte de integração usa PostgreSQL containerizado via Docker Compose para respeitar a regra de não instalar ferramentas no host.
- Testcontainers permanece como opção futura quando houver acesso seguro ao Docker daemon no ambiente de execução.
