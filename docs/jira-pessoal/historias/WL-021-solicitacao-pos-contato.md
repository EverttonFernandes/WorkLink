# WL-021 — Solicitação de feedback pós-contato

## Objetivo

Solicitar feedback ao usuário após uma intenção de contato registrada, de forma simples e rastreável.

## Valor entregue

O WorkLink passa a coletar dados de responsividade de maneira ativa, não dependendo apenas de o usuário encontrar
manualmente a tela de feedback.

## Personas

- Usuário cliente
- Profissional

## Requisitos relacionados

- RF35, RF36, RF37, RF38, RF39
- RN11, RN18

## Escopo incluído

- Marcar contatos elegíveis para solicitação de feedback.
- Exibir lembrete/pendência de pós-contato no app.
- Permitir concluir ou dispensar a solicitação.
- Evitar solicitação duplicada para a mesma intenção de contato.

## Fora do escopo

- Push notification produtivo.
- Campanhas de reengajamento.
- Automação complexa por agenda externa.

## Critérios de aceite

- Contato iniciado deve gerar pendência de feedback pós-contato.
- App deve exibir solicitação quando houver pendência elegível.
- Usuário deve conseguir responder o feedback pela solicitação.
- Sistema não deve solicitar feedback duplicado para contato já respondido.
- Solicitação dispensada deve ser registrada para evitar insistência imediata.

## Protótipos de tela vinculados

- `docs/prototipos-de-tela/tela-falar-com-o-profissional.png`
- `docs/prototipos-de-tela/tela-avaliacao-profissional.png`

## Entrega versionável

- Tipo sugerido: `MINOR`
- Motivo: torna mensuração de responsividade ativa e coerente com a tese da V1.
