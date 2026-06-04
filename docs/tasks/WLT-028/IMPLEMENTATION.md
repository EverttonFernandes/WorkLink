---
task_key: WLT-028
title: Promocao de release e rollback mobile
phase: READY_TO_CLOSE
loop_iteration: 2
official_order: 59
version_suggestion: MINOR
progress_file: docs/tasks/WLT-028/progress.txt
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
  kanban_updated: PASS
  git_commit: PENDING
  semantic_tag: PENDING
correction_queue:
  - id: WLT-028-SRE-001
    severity: CRITICAL
    status: RESOLVED
    description: "Formalizar promocao, rollback e separacao CI/CD manual antes de publicacao mobile."
metrics:
  files_changed: 9
  tests_run:
    - "make mobile-release-promotion-governance: PASS"
    - "sh -n scripts/check_mobile_release_promotion_governance.sh: PASS"
    - "sh -n scripts/test_mobile_release_promotion_governance.sh: PASS"
    - "./scripts/test_mobile_release_promotion_governance.sh: PASS"
    - "git diff --check: PASS"
  ci_run: null
---

# Plano de Execucao - WLT-028

## Contexto

A WLT-028 e a ultima historia tecnica pendente no Backlog apos a WLT-027 fechar com CI verde em `v0.51.0`.

## Decisao Tecnica

- Criar governanca executavel para promocao e rollback.
- Manter publicacao em lojas fora de escopo e manual/aprovada.
- Reutilizar o script de promocao Android existente como contrato de rastreabilidade.
- Validar que CI obrigatoria permanece separada de CD manual.

## Escopo

1. Criar procedimento operacional de promocao/rollback mobile.
2. Atualizar guia de release mobile.
3. Criar gate local e teste sintetico.
4. Conectar o gate no job `Dependency scan`.
5. Atualizar entrega e Kanban.

## Criterios de Aceite

- [x] Existe checklist de promocao de release mobile.
- [x] Versao mobile e rastreavel por tag, commit e artifact.
- [x] Fluxo diferencia teste interno, beta e producao.
- [x] Ha procedimento documentado de rollback ou bloqueio de rollout.
- [x] Esteira DevOps fica definida como gate obrigatorio antes de publicacao.

## Estrategia de Testes

- `make mobile-release-promotion-governance`.
- `sh -n scripts/check_mobile_release_promotion_governance.sh`.
- `sh -n scripts/test_mobile_release_promotion_governance.sh`.
- `./scripts/test_mobile_release_promotion_governance.sh`.
- `git diff --check`.

## Log de Iteracoes

- Iteracao 1: plano criado porque a historia ainda nao possuia `docs/tasks/WLT-028/IMPLEMENTATION.md`.
- Iteracao 2: procedimento de promocao/rollback criado, gate conectado no Makefile/CI e teste sintetico validou bloqueio
  de documento sem rollback.
