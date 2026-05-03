# WLT-008 — Testabilidade mobile

## Objetivo

Criar base de testes para app Flutter, incluindo lógica, widgets e integração/E2E.

## Valor técnico

Permite validar comportamento mobile em fluxos críticos da V1.

## RNFs relacionados

- RNF01, RNF06, RNF13

## Escopo incluído

- Testes unitários com `flutter_test` e `mocktail`.
- Testes de widget.
- Testes de integração com `integration_test`.
- Gate de cobertura unitária mobile mínima de 95% quando houver lógica testável.
- Estratégia para Android Emulator e iOS Simulator.

## Fora do escopo

- Patrol obrigatório na V1.
- Publicação em lojas.
- Testes nativos profundos de câmera/galeria/notificações.

## Critérios de aceite

- App deve possuir comando para testes Flutter.
- Testes unitários Flutter devem gerar cobertura e manter mínimo de 95% quando houver suíte unitária.
- Telas críticas devem ter testes de widget quando existirem.
- Fluxos críticos devem ter estratégia de integração mobile.
- `flutter analyze` deve ser parte do gate de qualidade.
- Testes mobile não devem depender de estado residual.
- Cobertura unitária mobile abaixo de 95% deve bloquear fechamento da história.

## Entrega versionável

- Tipo sugerido: `MINOR`
