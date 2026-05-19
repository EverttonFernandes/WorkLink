# Entrega WLT-024 — Confiabilidade da CI mobile Android

## Identificador

- História: `WLT-024`
- Tipo semântico sugerido: `MINOR`

## Objetivo técnico

Endurecer o job de Android Emulator para que a CI mobile seja uma evidência confiável antes de qualquer publicação.

## Estado planejado

Esta entrega deve registrar logs, artifacts, critérios de diagnóstico e evidências remotas da pipeline mobile Android.

## Implementação inicial

- Adicionado script `scripts/collect_mobile_emulator_diagnostics.sh` para coletar evidências do job mobile Android.
- Atualizado o job `mobile-emulator` para manter o log do `flutter drive` em artifact.
- Configurado upload de artifact `mobile-emulator-diagnostics-*` com logs de Docker Compose, backend, emulador, `adb` e `logcat`.

## Evidências esperadas

- Artifact de diagnóstico disponível em todos os runs do job `mobile-emulator`.
- Em caso de falha, logs suficientes para diferenciar problema de boot do emulador, backend, rede ou execução Flutter.
