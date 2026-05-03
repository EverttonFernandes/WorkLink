# WL-008 — Disponibilidade do profissional

## Objetivo

Permitir que profissionais informem disponibilidade e que usuários vejam esse sinal na listagem e no perfil.

## Valor entregue

O usuário consegue estimar melhor a chance de atendimento.

## Personas

- Usuário cliente
- Profissional

## Requisitos relacionados

- RF27, RF28, RF29, RF30, RF60
- RN06, RN07, RN08

## Escopo incluído

- Status: disponível hoje, disponível esta semana, aceitando novos clientes, atendimento emergencial e indisponível temporariamente.
- Exibição de badges de disponibilidade.
- Redução de destaque para indisponíveis.
- Registro do sinal para ranking futuro.

## Fora do escopo

- Agenda avançada.
- Reserva de horário.
- Garantia de atendimento.

## Critérios de aceite

- Profissional deve conseguir informar disponibilidade.
- Status permitido deve ficar restrito aos valores da V1.
- Listagem e perfil devem exibir badge de disponibilidade.
- Profissional indisponível deve perder destaque.
- Disponibilidade não deve ser tratada como garantia de atendimento.

## Protótipos de tela relacionados

- `docs/prototipos-de-tela/tela-perfil-do-profissional.png`
- `docs/prototipos-de-tela/tela-cadastro-do-profissional.png`

### Requisitos não funcionais por tela

- disponibilidade deve ser apresentada como sinal, não como garantia de atendimento;
- alteração de status deve ser rastreável quando aplicável;
- testes mobile devem cobrir seleção de disponibilidade, exibição no perfil e estados indisponíveis.

## Entrega versionável

- Tipo sugerido: `MINOR`
- Motivo: adiciona sinal explícito de chance de atendimento.
