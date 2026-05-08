# Entrega WL-004 — Listagem de profissionais com sinais mínimos

## Resultado

Listagem mobile evoluída para cards comparáveis, com sinais opcionais, sem promessa de ranking, avaliação ou garantia de qualidade.

## Entregues

- Modelo mobile de profissional com foto opcional, badge de perfil, disponibilidade e atividade recente.
- Cards com nome, categoria, cidade, descrição curta, avatar e sinais renderizados somente quando houver dados.
- Ação de abertura de perfil por identificador, preparando a história `WL-005`.
- Testes BDD/TDD unitários para sinais comparativos.
- Testes BDD/TDD de tela para renderização dos cards, ausência de badge indevido, estado vazio e abertura do perfil.

## Validações

- `make mobile-static-analysis`
- `make mobile-unit-test`
- `make mobile-screen-test`
- `make backend-static-analysis`
- `make backend-unit-test`
- `make backend-integration-test`
- `make mobile-integration-test`
- `make functional-test`
- `git diff --check`

## Observações

- A tela de perfil detalhado fica para `WL-005`.
- A integração HTTP real do mobile permanece fora desta entrega.
- `make mobile-integration-test` retornou `N/A` por ausência de Android Emulator, iOS Simulator ou Chrome no container.
- `make functional-test` retornou `N/A` porque ainda não existem cenários funcionais reais.
