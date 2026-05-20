# Entrega WLT-025 — Build Android e release candidate instalável

## Identificador

- História: `WLT-025`
- Tipo semântico sugerido: `MINOR`

## Objetivo técnico

Gerar artefatos Android instaláveis pela pipeline, com rastreabilidade para commit, versão e ambiente.

## Estado concluído

Esta entrega registra o workflow de build Android, artifacts produzidos e instruções de teste pré-loja.

## Implementação

- Adicionado o script `scripts/prepare_android_test_candidate.sh`.
- Criado o alvo `make mobile-android-test-candidate`.
- Atualizado o job `Mobile quality gates` para preparar e publicar o artifact `worklink-android-test-candidate-<commit>`.
- O pacote publicado contém:
  - `worklink-android-test-candidate.apk`
  - `BUILD-METADATA.txt`
  - `SHA256SUMS`
  - `INSTALL-ANDROID.md`
- Atualizada a documentação em `worklink-mobile/README.md` e `docs/release/release-mobile.md` com o fluxo de teste manual.

## Evidências de fechamento

- GitHub Actions run `26188770990` executado com sucesso em `main`.
- Artifact publicado: `worklink-android-test-candidate-fe747ac9e5e39bc6f44ed04f401b5a1f672110fd`.
- APK validado por checksum após download do artifact:
  - `worklink-android-test-candidate.apk: OK`
- Metadados do artifact:
  - `app_version=0.1.0+1`
  - `git_commit=fe747ac9e5e39bc6f44ed04f401b5a1f672110fd`
  - `github_run_id=26188770990`
  - `build_type=debug`
  - `signing=android_debug_key`
- Jobs verdes:
  - `Mobile quality gates` em `10m9s`
  - `Mobile integration on Android emulator` em `10m37s`
  - `Backend quality gates` em `5m50s`
  - `Dependency scan` em `41s`
  - `API Docker image` em `1m25s`

## Como testar manualmente no Android

1. Abra o run verde `26188770990` no GitHub Actions.
2. Baixe o artifact `worklink-android-test-candidate-fe747ac9e5e39bc6f44ed04f401b5a1f672110fd`.
3. Extraia o zip.
4. Envie `worklink-android-test-candidate.apk` para o aparelho Android.
5. Permita instalação de apps desconhecidos para o app usado para abrir o APK.
6. Instale o APK e abra o WorkLink.

## Próximo endurecimento

- Evoluir de APK debug para release candidate assinado quando a governança de secrets e assinatura mobile estiver fechada.
- Preparar build `aab` para Google Play na etapa de assinatura/distribuição.
