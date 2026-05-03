# WLT-008 — Testabilidade mobile

## Fonte

- História: `docs/jira-pessoal/historias-tecnicas/WLT-008-testabilidade-mobile.md`
- Ordem oficial: 08 em `docs/jira-pessoal/KANBAN-OFICIAL.md`
- Tipo: Técnica
- Versão sugerida: `MINOR`

## Objetivo

Criar a base de testes Flutter para lógica, widgets e integração/E2E.

## Escopo incluído

- Testes unitários com `flutter_test`.
- Dependência `mocktail` preparada para mocks em histórias com ports/adapters mobile.
- Testes de widget organizados em pasta própria.
- Teste de integração mobile com `integration_test`.
- Gate de cobertura unitária mobile mínima de 95%.
- Estratégia de execução para Android Emulator, iOS Simulator ou Chrome quando disponíveis.

## Fora do escopo

- Patrol obrigatório na V1.
- Publicação em lojas.
- Testes nativos profundos de câmera, galeria ou notificações.

## Critérios de aceite

- App deve possuir comando para testes Flutter.
- Testes unitários Flutter devem gerar cobertura e manter mínimo de 95%.
- Telas críticas devem ter testes de widget quando existirem.
- Fluxos críticos devem ter estratégia de integração mobile.
- `flutter analyze` deve ser parte do gate de qualidade.
- Testes mobile não devem depender de estado residual.
- Cobertura unitária mobile abaixo de 95% deve bloquear fechamento da história.
