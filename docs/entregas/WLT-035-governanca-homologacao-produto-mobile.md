# Entrega WLT-035 — Governança de homologação de produto mobile

## Resumo

A WLT-035 corrige o débito `DTM-006`, impedindo que artifact técnico ou preview seja tratado como homologação de
produto, release candidate ou versão estável.

## Escopo entregue

- Documento oficial em `docs/operacao/governanca-homologacao-produto-mobile.md`.
- Classes oficiais: `technical-build`, `preview`, `functional-homologation`, `release-candidate` e `stable-homologation`.
- `BUILD-METADATA.txt` do pacote Android agora declara `artifact_class` e `known_limitations`.
- `INSTALL-ANDROID.md` agora informa classe do artifact e limitações conhecidas antes do teste manual.
- Gate mecânico `scripts/check_mobile_product_homologation_governance.sh`.
- Target `make mobile-product-homologation-gate ARTIFACT_DIR=<dir>`.
- Gate visual da WLT-034 alinhado para aceitar `stable-homologation`.

## Evidências

- `scripts/test_mobile_product_homologation_governance.sh`: PASS.
- `scripts/test_mobile_visual_evidence_gate.sh`: PASS.
- `sh -n` nos scripts alterados: PASS.
- `make -n mobile-product-homologation-gate ARTIFACT_DIR=artifacts/android-homologation-candidate`: PASS.
- Teste de ponta curto do empacotador com artifact fake em `/tmp`: PASS.
- `git diff --check`: PASS.

## Decisão de governança

`technical-build` e `preview` nunca podem ser chamados de release candidate.

`functional-homologation`, `release-candidate` e `stable-homologation` precisam declarar backend, limitações conhecidas e
evidências compatíveis com o tipo de validação pretendido.
