# Entrega WLT-034 — Gate de QA visual para homologação mobile

## Resumo

A WLT-034 corrige o débito `DTM-005`, criando um gate explícito para impedir que um APK/IPA seja tratado como
homologável apenas por compilar, instalar ou passar CI.

## Escopo entregue

- Checklist oficial em `docs/qa/mobile-visual-homologation-gate.md`.
- Classes oficiais de artifact: `technical-build`, `preview`, `functional-homologation` e `release-candidate`.
- Pasta padrão de evidências: `docs/tasks/<KEY>/visual-qa/`.
- Gate mecânico `scripts/check_mobile_visual_evidence_gate.sh`.
- Target `make mobile-visual-qa-gate TASK_KEY=<KEY>`.
- Instruções de artifact Android atualizadas para diferenciar artifact técnico de homologação de produto.
- Runbooks de infra mobile atualizados para exigir o gate visual quando houver UI ou teste humano de APK/IPA.

## Evidências

- `scripts/test_mobile_visual_evidence_gate.sh`: PASS.
- `sh -n` nos scripts alterados: PASS.
- `git diff --check`: PASS.
- WLT-033 validada previamente na CI `26926338620`, com emulador Android e artifacts mobile aprovados.

## Decisão de governança

`mobile_tests` só pode ser `PASS` para entrega mobile com UI/APK humano quando houver matriz visual, screenshots reais e
veredito `APPROVED` do Mobile Front-end Specialist.

Comparação visual manual documentada é aceita nesta fase para evitar custo prematuro com device farm ou automação visual
complexa.
