---
task_key: WLT-017
title: "CI/CD, builds e scans"
story_path: "docs/jira-pessoal/historias-tecnicas/WLT-017-cicd-builds-scans.md"
official_order: 9
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
  mobile_tests: PASS
  coverage: PASS
  sonar: N/A
  sre: PASS
  security: PASS
  arch_review: PASS
  final_review: PASS
metrics:
  unit_coverage_minimum: 95
  changed_files: 11
  risk_level: MEDIUM
correction_queue: []
cycle_history:
  - iteration: 0
    phase: EXECUTION
    summary: "CI/CD iniciado a partir da próxima história oficial."
    evidence:
      - "docs/jira-pessoal/historias-tecnicas/WLT-017-cicd-builds-scans.md"
  - iteration: 1
    phase: DONE
    summary: "Workflow GitHub Actions e alvos CI foram criados com gates backend, mobile, Docker image e scan básico."
    evidence:
      - "WORKLINK_ENV_FILE=.env.example docker compose --env-file .env.example config"
      - "docker build -f docker/worklink-api.Dockerfile -t worklink-api:ci-local ."
      - "docker run --rm --entrypoint sh worklink-api:ci-local -lc \"test -f /app/worklink-api.jar && ! command -v mvn && ! command -v javac\""
      - "make mobile-android-build"
      - "git diff --check"
---

# WLT-017 — CI/CD, builds e scans

## Status

Fase atual: `DONE`.

## Resultado

- GitHub Actions criado em `.github/workflows/ci.yml`.
- Pipeline backend executa análise estática, unitários com cobertura, integração e funcionais.
- Pipeline mobile executa análise estática, testes mobile, coverage e estratégia Android.
- Pipeline Docker gera imagem multi-stage e valida contrato mínimo de runtime.
- Scan básico de dependências executa `npm audit` para funcionais e resolução Maven.
- Estratégia iOS documentada em `docs/ci-cd/ESTRATEGIA-IOS.md`.

## Observações

- Publicação em produção e assinatura de loja permanecem fora do escopo.
- Job iOS real deve ser ativado quando `worklink-mobile/ios` existir e houver runner macOS disponível.
