---
task_key: WLT-027
title: Governanca de secrets e assinatura mobile
phase: READY_TO_CLOSE
loop_iteration: 2
official_order: 58
version_suggestion: MINOR
progress_file: docs/tasks/WLT-027/progress.txt
func_tests_detected: false
func_tests_path: ""
func_tests_framework: ""
exit_bar:
  acceptance_criteria: PASS
  clean_code: PASS
  lint: PASS
  unit_tests: N/A
  integration_tests: N/A
  func_tests: N/A
  mobile_tests: N/A
  coverage: N/A
  sre_review: PASS
  security_review: PASS
  architecture_review: PASS
  final_review: PASS
  documentation: PASS
  kanban_updated: PENDING
  git_commit: PENDING
  semantic_tag: PENDING
correction_queue:
  - id: WLT-027-SEC-001
    severity: CRITICAL
    status: RESOLVED
    description: "Criar inventario e gate para impedir versionamento de secrets de assinatura mobile."
metrics:
  files_changed: 12
  tests_run:
    - "make mobile-signing-governance: PASS"
    - "sh -n scripts/check_mobile_signing_governance.sh: PASS"
    - "sh -n scripts/test_mobile_signing_governance.sh: PASS"
    - "sh -n scripts/check_no_mobile_signing_secrets.sh: PASS"
    - "./scripts/test_mobile_signing_governance.sh: PASS"
    - "git diff --check: PASS"
    - "rg secret-pattern audit: PASS"
  ci_run: null
---

# Plano de Execucao - WLT-027

## Contexto

A WLT-027 e a primeira historia restante apos a WLT-026 ter fechado com CI verde. Ela prepara governanca de secrets e
assinatura mobile antes de qualquer promocao mais automatizada para lojas.

## Decisao Tecnica

- Tratar secrets como contrato documentado, sem valores reais no repositorio.
- Validar a governanca por script local e no job `Dependency scan`.
- Manter Android homologacao e iOS TestFlight separados por ambiente e obrigatoriedade.
- Usar `artifacts/local-secrets/` apenas como area local ignorada para material gerado.

## Escopo

1. Criar inventario operacional de secrets mobile.
2. Atualizar exemplos de env com nomes esperados.
3. Reforcar `.gitignore` e gate contra artefatos sensiveis versionados.
4. Adicionar target Makefile e step de CI para governanca de assinatura.
5. Documentar entrega e atualizar Kanban.

## Criterios de Aceite

- [ ] Inventario de secrets por ambiente existe.
- [x] Inventario de secrets por ambiente existe.
- [x] Arquivos sensiveis estao cobertos por `.gitignore`.
- [x] Workflows classificam secrets opcionais e bloqueantes.
- [x] Politica de rotacao, revogacao, ownership e recuperacao existe.
- [x] Pipeline falha se artefatos sensiveis forem versionados.

## Estrategia de Testes

- `make mobile-signing-governance`.
- `sh -n scripts/check_mobile_signing_governance.sh`.
- `sh -n scripts/test_mobile_signing_governance.sh`.
- `./scripts/test_mobile_signing_governance.sh`.
- `git diff --check`.

## Log de Iteracoes

- Iteracao 1: plano criado porque a historia ainda nao possuia `docs/tasks/WLT-027/IMPLEMENTATION.md`.
- Iteracao 2: governanca documentada, gate local/CI criado, teste sintetico validou bloqueio de arquivo sensivel
  versionado e `.gitignore` incompleto.
