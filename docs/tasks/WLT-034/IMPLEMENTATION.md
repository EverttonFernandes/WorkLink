---
task_key: WLT-034
title: Gate de QA visual para homologacao mobile
phase: READY_TO_CLOSE
loop_iteration: 2
official_order: 55
version_suggestion: PATCH
progress_file: docs/tasks/WLT-034/progress.txt
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
  - id: WLT-034-QA-001
    severity: CRITICAL
    status: RESOLVED
    description: "Criar gate recorrente para impedir aprovacao de APK/IPA mobile sem evidencia visual/produto."
metrics:
  files_changed: 12
  tests_run:
    - "scripts/test_mobile_visual_evidence_gate.sh: PASS"
    - "sh -n scripts/check_mobile_visual_evidence_gate.sh scripts/test_mobile_visual_evidence_gate.sh scripts/prepare_android_test_candidate.sh: PASS"
    - "make -n mobile-visual-qa-gate TASK_KEY=WLT-034: PASS"
    - "git diff --check: PASS"
  ci_run: null
---

# Plano de Execucao - WLT-034

## Contexto

A WLT-034 corrige o debito `DTM-005`: a esteira mobile conseguia aprovar build, testes e artifacts sem exigir uma
evidencia visual de produto comparada aos prototipos oficiais.

## Proxima Historia Elegivel

O `KANBAN-OFICIAL.md` lista a WLT-034 como primeira historia em `To Do`, logo apos a WLT-033 concluida e validada pela
CI `26926338620`.

## Decisao de Produto/QA

- CI verde e APK instalavel continuam obrigatorios, mas nao bastam para homologacao mobile de produto.
- Toda entrega que gerar APK, IPA ou artifact para teste humano deve declarar a classe do artifact.
- Quando houver UI mobile, o gate `mobile_tests` so pode ser `PASS` com matriz visual, screenshots reais e veredito do
  `mobile-frontend-specialist-agent`.
- Enquanto screenshot diff/golden automatizado completo nao for proporcional ao custo, comparacao manual documentada e
  mecanicamente verificavel e suficiente.

## Escopo

1. Criar checklist oficial de QA visual para homologacao mobile.
2. Criar gate mecanico leve para validar existencia de matriz, screenshots e veredito especializado.
3. Conectar o gate ao Makefile para execucao padronizada.
4. Atualizar instrucoes de artifact Android para deixar claro que artifact tecnico nao equivale a homologacao de produto.
5. Atualizar documentacao de testes e entrega da historia.

## Criterios de Aceite

- [x] QA possui checklist visual oficial para APK/IPA manual.
- [x] `mobile_tests` nao pode ser `PASS` sem evidencia visual quando houver UI mobile.
- [x] O fluxo define onde registrar screenshots oficiais de validacao.
- [x] O gate diferencia artifact tecnico, preview, homologacao funcional e release candidate.
- [x] A solucao nao exige infraestrutura paga ou device farm antes da necessidade real.

## Estrategia de Testes

- Validar o script de gate visual com fixture temporaria positiva e negativa.
- Rodar `make mobile-visual-qa-gate TASK_KEY=<key>` quando existir evidencia real da historia.
- Rodar analise estatica/documental aplicavel sem tocar nos builds pesados desnecessariamente.

## Log de Iteracoes

- Iteracao 1: WLT-034 iniciada apos CI verde da WLT-033. O workflow `start-work.md` citado pela skill nao existe no
  reposititorio, entao o plano Ralph Loop foi criado manualmente seguindo o formato das historias anteriores.
- Iteracao 2: checklist oficial criado em `docs/qa/mobile-visual-homologation-gate.md`, gate mecanico adicionado em
  `scripts/check_mobile_visual_evidence_gate.sh`, target `make mobile-visual-qa-gate` criado, runbooks de homologacao
  atualizados e testes locais do gate aprovados.
- Iteracao 2: revisao de seguranca do diff nao encontrou valores reais de secrets; apenas nomes de variaveis de
  configuracao ja existentes nos runbooks e scripts.

## Aprendizados do Loop

- Artifact mobile precisa carregar uma decisao explicita: tecnico, preview, homologacao funcional ou release candidate.
- O gate visual deve ser barato agora, mas forte o suficiente para bloquear aprovacao sem evidencia.
