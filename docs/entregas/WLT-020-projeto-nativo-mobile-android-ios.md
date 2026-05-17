# Entrega WLT-020 — Projeto nativo mobile Android/iOS

## Identificador

- História: `WLT-020`
- Data: `2026-05-17`
- Tipo semântico sugerido: `MINOR`

## Objetivo técnico

Gerar as camadas nativas Android e iOS do aplicativo Flutter para habilitar build real, evolução para testes em emulador/simulador e preparação de publicação futura.

## O que foi implementado

- Geração de `worklink-mobile/android/` e `worklink-mobile/ios/` em ambiente containerizado.
- Namespace e identificadores nativos padronizados para `br.com.worklink.mobile`.
- Ajuste do nome visível do app para `WorkLink`.
- Correção do caminho e package de `MainActivity.kt`.
- Atualização do `README` do mobile com o fluxo de build Android.
- Atualização da estratégia iOS em `docs/ci-cd/ESTRATEGIA-IOS.md`.
- Endurecimento do `Makefile` para limpar `worklink-mobile/android/.gradle` antes do build Android.

## O que não foi implementado

- Assinatura de produção Android.
- Assinatura e publicação iOS.
- Job macOS efetivo no GitHub Actions.
- Execução local de simulador iOS fora de ambiente macOS.

## Validações executadas

- `make mobile-static-analysis`: PASS
- `make mobile-unit-test`: PASS, cobertura `95.81%`
- `make mobile-screen-test`: PASS
- `make mobile-integration-test`: PASS para contrato HTTP; emulador/simulador/browser `N/A`
- `make mobile-android-build`: PASS

## Evidências

- APK gerado em `worklink-mobile/build/app/outputs/flutter-apk/app-debug.apk`.
- `make mobile-android-build` deixou de retornar `N/A` e passou a executar build real.
- `worklink-mobile/ios/` agora existe e habilita a próxima etapa de CI em runner macOS.

## Arquivos relevantes

- `Makefile`
- `worklink-mobile/README.md`
- `worklink-mobile/.gitignore`
- `worklink-mobile/android/`
- `worklink-mobile/ios/`
- `docs/ci-cd/ESTRATEGIA-IOS.md`

## Riscos ou limitações remanescentes

- Build iOS continua dependente de runner macOS.
- Signing continua fora do escopo desta história.
- O build Android em container é mais lento na primeira execução por bootstrap de Gradle/SDK.

## Justificativa do versionamento

Entrega `MINOR` porque adiciona capacidade nova de build e prontidão operacional mobile sem quebrar comportamento existente do aplicativo.
