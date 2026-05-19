# Entrega WLT-025 — Build Android e release candidate instalável

## Identificador

- História: `WLT-025`
- Tipo semântico sugerido: `MINOR`

## Objetivo técnico

Gerar artefatos Android instaláveis pela pipeline, com rastreabilidade para commit, versão e ambiente.

## Estado planejado

Esta entrega deve registrar o workflow de build Android, artifacts produzidos e instruções de teste pré-loja.

## Implementação inicial

- Atualizado o job mobile da CI para publicar `worklink-mobile/build/app/outputs/flutter-apk/app-debug.apk`.
- O artifact segue o padrão `worklink-android-debug-<commit>`.
- O primeiro artifact é debug, suficiente para instalação manual e validação antes da etapa de signing/release.

## Próximo endurecimento

- Evoluir de APK debug para release candidate assinado quando a governança de secrets e assinatura mobile estiver fechada.
- Adicionar validação automática de instalação do artifact em emulador ou device de teste.
