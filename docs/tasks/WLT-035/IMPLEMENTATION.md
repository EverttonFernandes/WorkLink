---
task_key: WLT-035
title: Governanca de homologacao de produto mobile
phase: READY_TO_CLOSE
loop_iteration: 2
official_order: 56
version_suggestion: PATCH
progress_file: docs/tasks/WLT-035/progress.txt
exit_bar:
  acceptance_criteria: PASS
  clean_code: PASS
  lint: PASS
  unit_tests: N/A
  integration_tests: N/A
  func_tests: N/A
  mobile_tests: PASS
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
  - id: WLT-035-PM-001
    severity: CRITICAL
    status: RESOLVED
    description: "Impedir que artifact tecnico ou preview seja tratado como homologacao de produto/release candidate."
metrics:
  files_changed: 11
  tests_run:
    - "scripts/test_mobile_product_homologation_governance.sh: PASS"
    - "scripts/test_mobile_visual_evidence_gate.sh: PASS"
    - "sh -n scripts/check_mobile_product_homologation_governance.sh scripts/test_mobile_product_homologation_governance.sh scripts/prepare_android_test_candidate.sh scripts/check_mobile_visual_evidence_gate.sh: PASS"
    - "make -n mobile-product-homologation-gate ARTIFACT_DIR=artifacts/android-homologation-candidate: PASS"
    - "prepare_android_test_candidate.sh + check_mobile_product_homologation_governance.sh em /tmp: PASS"
    - "git diff --check: PASS"
  ci_run: null
---

# Plano de Execucao - WLT-035

## Contexto

A WLT-035 corrige o debito `DTM-006`: o projeto precisa separar claramente artifact tecnico, preview, homologacao
funcional, release candidate e versao estavel de homologacao.

## Proxima Historia Elegivel

O `KANBAN-OFICIAL.md` lista a WLT-035 como primeira historia em `To Do`, depois da WLT-034 concluida, versionada e com
CI verde no run `26927429154`.

## Decisao de Produto

- Artifact tecnico/preview nao pode ser chamado de release candidate.
- Pacote para teste manual precisa declarar o que pode ser validado e suas limitacoes conhecidas.
- Homologacao funcional exige backend/massa coerentes e gate visual/produto da WLT-034.
- Versao estavel de homologacao deve existir apenas quando houver tag semantica, artifact promovido, checksums e
  evidencias de produto.

## Escopo

1. Definir governanca oficial de classificacao de artifacts mobile.
2. Escrever `artifact_class` e `known_limitations` nos pacotes Android.
3. Criar gate mecanico para validar classificacao e limitar release candidate indevido.
4. Conectar o gate ao Makefile.
5. Atualizar runbooks, entrega, debitos e Kanban.

## Criterios de Aceite

- [x] Toda entrega mobile manual declara sua classificacao de artifact.
- [x] Nenhum artifact tecnico/preview pode ser chamado de release candidate.
- [x] O pacote de homologacao informa limitacoes conhecidas antes do teste manual.
- [x] Product Manager e Final Reviewer possuem criterio objetivo para bloquear homologacao indevida.

## Estrategia de Testes

- Testar gate de governanca com fixture valida e fixture invalida.
- Validar sintaxe shell dos scripts alterados.
- Validar `make -n` do novo target.
- Rodar `git diff --check`.

## Log de Iteracoes

- Iteracao 1: WLT-035 iniciada apos WLT-034 com CI verde. Plano criado manualmente porque `.agents/workflows/start-work.md`
  nao existe no checkout.
- Iteracao 2: governanca oficial criada, empacotador Android passou a escrever classe/limitacoes, gate mecanico validou
  fixture positiva/negativa e pacote fake gerado em `/tmp`, e WLT-034 foi alinhada a `stable-homologation`.

## Aprendizados do Loop

- A governanca de artifact deve estar no pacote baixado pelo dono do produto, nao apenas em documentos separados.
