---
task_key: WLT-039
title: Android AAB e Play Store Internal Testing
phase: DONE
loop_iteration: 4
official_order: 64
version_suggestion: MINOR
progress_file: docs/tasks/WLT-039/progress.txt
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
  git_commit: PASS
  semantic_tag: PASS
correction_queue: []
metrics:
  files_changed: 17
  tests_run:
    - "sh -n scripts/prepare_android_store_signing.sh scripts/prepare_android_store_bundle_candidate.sh scripts/check_mobile_signing_governance.sh scripts/prepare_android_homologation_signing.sh scripts/prepare_android_test_candidate.sh"
    - "make mobile-signing-governance"
    - "make -n mobile-android-appbundle-build MOBILE_PLAY_STORE_API_BASE_URL=https://api.profissionalperto.app"
    - "make -n mobile-android-play-store-candidate MOBILE_PLAY_STORE_API_BASE_URL=https://api.profissionalperto.app"
    - "fixture local de prepare_android_store_bundle_candidate.sh"
    - "make mobile-static-analysis"
    - "git diff --check"
    - "GitHub Actions WorkLink CI run 29962987675: success"
  ci_run: 29962987675
---

# Plano de Execucao - WLT-039

## Contexto

A `WLT-038` deixou a autenticacao opcional sob controle de custo e liberou a proxima etapa da trilha Android de loja. A
`WLT-039` agora precisa transformar o build mobile em um artefato oficial da Google Play:

- `AAB` de release;
- assinatura compativel com Play App Signing;
- rastreabilidade por commit/tag;
- checklist claro para Internal Testing e, se exigido pela conta pessoal nova, Closed Testing.

## Dependencias reais

- `WLT-037`: backend cloud estavel continua sendo pre-requisito para apontar a build de loja para uma API HTTPS real.
- `WLT-027` e `WLT-028`: governanca de secrets, assinatura e promocao de release ja prepararam parte da base.
- `WLT-036`: conta da Play Console e metadados iniciais ja foram documentados.

## Restricoes pragmaticas do Pattern Enforcer

- Nao empacotar AAB de loja apontando para `localhost`, tunnel temporario ou backend nao persistente.
- Nao versionar keystore, credencial de Play Console, JSON de service account ou segredo de assinatura.
- Reaproveitar scripts e governancas ja existentes de Android/homologacao antes de criar novos fluxos.
- Tratar Internal Testing e Closed Testing como gates operacionais, nao como detalhe cosmetico.

## Fases

### Fase 1 - Descoberta e contrato

- [x] Mapear o estado atual do build Android release/APK/homologacao.
- [x] Confirmar lacunas entre APK atual e AAB de loja.
- [x] Confirmar dependencias manuais da Play Console e do backend cloud.

### Fase 2 - Build e assinatura

- [x] Preparar comando e script para `flutter build appbundle --release`.
- [x] Garantir `API_BASE_URL` de loja controlada.
- [x] Formalizar variaveis/secrets de assinatura para Play App Signing.
- [x] Gerar artifact rastreavel com checksum e metadados.

### Fase 3 - CI/CD e operacao

- [x] Criar ou ajustar workflow GitHub Actions para gerar o AAB.
- [x] Publicar artifact da CI com instrucoes de uso.
- [x] Documentar Internal Testing e Closed Testing.
- [x] Registrar bloqueios explicitos antes de producao publica.

### Fase 4 - Validacao e saida

- [x] Validar build/analise/testes relevantes do mobile.
- [x] Revisar seguranca da assinatura e segredos.
- [x] Preparar entrega documental e transbordar pendencias manuais para historia propria.

## Validacoes planejadas

- `make mobile-signing-governance`
- `make mobile-android-build` ou fluxo equivalente para `appbundle`
- validacoes do workflow GitHub Actions
- `git diff --check`

## Pendencias manuais transbordadas

- URL HTTPS cloud real da API para `WORKLINK_PLAY_STORE_API_BASE_URL`.
- Secrets reais de assinatura/upload `WORKLINK_ANDROID_STORE_*`.
- Acao manual no Google Play Console para Internal/Closed Testing.
- Itens transbordados para a `WLT-042`.

## Resultado tecnico atual

- `AAB` de release agora tem trilha oficial de build: `make mobile-android-appbundle-build`.
- O pacote rastreavel da Play Internal Testing agora tem trilha oficial: `make mobile-android-play-store-candidate`.
- O workflow `WorkLink CI` pode gerar `worklink-android-play-internal-<commit>` quando a URL/store secrets existem.
- A assinatura de loja fica separada da assinatura de homologacao, reduzindo o risco de misturar canais.
- A documentacao operacional cobre checklist, governanca e uso do artifact no Play Console.
- A operacao manual da Play Console foi separada na `WLT-042`.

## Log de Iteracoes

- Iteracao 1: WLT-039 iniciada como proxima historia oficial apos o fechamento versionado da WLT-038 (`v0.55.0`).
- Iteracao 1: bootstrap da task criado para preservar contexto e permitir retomada imediata no fluxo de AAB/Play Store.
- Iteracao 2: build/signing/governanca/documentacao da Play Internal Testing implementados e validados localmente, com
  dependencia remanescente apenas de backend HTTPS real, secrets da upload key e acao manual no Play Console.
- Iteracao 3: WLT-039 encerrada como historia tecnica automatizavel; execucao humana e validacao operacional migradas para
  `WLT-042`.
- Iteracao 4: fechamento versionavel preparado com artefatos da historia, CI verde `29962987675`, commit semantico e tag
  `v0.56.0`.
