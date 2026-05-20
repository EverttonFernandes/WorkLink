# Entrega WLT-024 — Confiabilidade da CI mobile Android

## Identificador

- História: `WLT-024`
- Tipo semântico sugerido: `MINOR`

## Objetivo técnico

Endurecer o job de Android Emulator para que a CI mobile seja uma evidência confiável antes de qualquer publicação.

## Estado concluído

Esta entrega registra logs, artifacts, critérios de diagnóstico e evidências remotas da pipeline mobile Android.

## Implementação inicial

- Adicionado script `scripts/collect_mobile_emulator_diagnostics.sh` para coletar evidências do job mobile Android.
- Atualizado o job `mobile-emulator` para manter o log do `flutter drive` em artifact.
- Configurado upload de artifact `mobile-emulator-diagnostics-*` com logs de Docker Compose, backend, emulador, `adb` e `logcat`.
- Padronizado `ANDROID_SDK_ROOT`, `ANDROID_HOME` e `GITHUB_PATH` no job `mobile-emulator`.
- Ajustado o script `worklink-mobile/tool/run_mobile_emulator_integration_tests.sh` para usar `adb` absoluto.
- Alinhado o smoke test de integração mobile à tela inicial real de descoberta.

## Evidências de fechamento

- Artifact de diagnóstico disponível em todos os runs do job `mobile-emulator`.
- Em caso de falha, logs suficientes para diferenciar problema de boot do emulador, backend, rede ou execução Flutter.
- GitHub Actions run `26176837198` executado com sucesso em `main`.
- Jobs verdes:
  - `Dependency scan` em `48s`
  - `API Docker image` em `2m19s`
  - `Backend quality gates` em `5m11s`
  - `Mobile quality gates` em `9m24s`
  - `Mobile integration on Android emulator` em `13m20s`
- O artifact `mobile-emulator-diagnostics-*` foi publicado também no run verde para rastreabilidade.

## Próxima otimização

- Reduzir tempo do job de emulador com cache/reuso de build Android quando a WLT-025 avançar para release candidate instalável.
- Tratar aviso de depreciação Node.js 20 em actions oficiais antes da remoção pelo GitHub.
