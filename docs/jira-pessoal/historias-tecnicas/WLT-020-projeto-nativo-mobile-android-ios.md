# WLT-020 — Projeto nativo mobile Android/iOS

## Objetivo

Gerar os projetos nativos Android e iOS do aplicativo Flutter, habilitando builds reais, testes em emulador/simulador e publicação futura nas lojas.

## Valor técnico

O `worklink-mobile/` possui código Flutter completo mas sem as pastas `android/` e `ios/` geradas. Sem elas, `make mobile-android-build` retorna N/A, não é possível rodar testes de integração mobile em emulador e a publicação nas lojas está bloqueada.

## RNFs relacionados

- RNF01, RNF06, RNF14

## Escopo incluído

- Geração do projeto nativo Android via `flutter create` ou equivalente.
- Geração do projeto nativo iOS via `flutter create` ou equivalente.
- Configuração mínima de `applicationId`, `bundleId` e versão.
- Validação de `flutter build apk` ou `flutter build appbundle` no CI.
- Atualização do `make mobile-android-build` para executar build real.
- Documentação da estratégia de build iOS (runner macOS, Codemagic ou equivalente) conforme `docs/ci-cd/ESTRATEGIA-IOS.md`.
- Atualização do `integration_test` para rodar em Android Emulator quando disponível.

## Fora do escopo

- Publicação efetiva na Google Play Store ou Apple App Store.
- Configuração de signing de produção.
- Testes em aparelho físico.

## Critérios de aceite

- `worklink-mobile/android/` deve existir com configuração mínima válida.
- `worklink-mobile/ios/` deve existir com configuração mínima válida.
- `flutter build apk --debug` deve concluir sem erro.
- `make mobile-android-build` deve executar build real e não retornar N/A.
- CI deve executar o build Android no job mobile.
- Estratégia de build iOS deve estar documentada.

## Entrega versionável

- Tipo sugerido: `MINOR`
- Motivo: habilita builds reais e fecha o gap de publicação multiplataforma da V1.
