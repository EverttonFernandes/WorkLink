# WL-008 — Disponibilidade do profissional

## História

Como usuário cliente, quero ver sinais de disponibilidade na listagem e no perfil, para estimar melhor a chance de atendimento sem interpretar o sinal como garantia.

## Fonte oficial

- `docs/jira-pessoal/historias/WL-008-disponibilidade-profissional.md`
- `docs/requisitos/epico-requisitos-de-negocio.md`
- `docs/requisitos/epico-requisitos-nao-funcionais.md`
- `docs/prototipos-de-tela/tela-perfil-do-profissional.png`
- `docs/prototipos-de-tela/tela-cadastro-do-profissional.png`

## Critérios de aceite

- [x] Profissional deve conseguir informar disponibilidade.
- [x] Status permitido deve ficar restrito aos valores da V1.
- [x] Listagem e perfil devem exibir badge de disponibilidade.
- [x] Profissional indisponível deve perder destaque.
- [x] Disponibilidade não deve ser tratada como garantia de atendimento.

## Escopo técnico

- Modelar disponibilidade como enum fechado no domínio.
- Persistir disponibilidade no PostgreSQL com migração versionada.
- Expor disponibilidade em API pública como status e label.
- Exibir badge de disponibilidade no mobile.
- Reduzir destaque de indisponíveis na ordenação/listagem.
- Cobrir regras com testes BDD/TDD.

## Fora do escopo

- Agenda avançada.
- Reserva de horário.
- Garantia de atendimento.
- TTL automático dos badges.
