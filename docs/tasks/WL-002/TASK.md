# WL-002 — Seleção de cidades e localização atual

## Fonte

- História: `docs/jira-pessoal/historias/WL-002-selecao-cidades-localizacao.md`
- Ordem oficial: 11 em `docs/jira-pessoal/KANBAN-OFICIAL.md`
- Tipo: Negócio
- Versão sugerida: `MINOR`

## Objetivo

Permitir que o usuário defina a base regional da busca usando uma ou mais cidades ou localização atual opcional.

## Escopo incluído

- Seleção manual de uma cidade.
- Seleção manual de mais de uma cidade.
- Limpeza de seleção.
- Uso opcional de localização atual como base de sugestão.
- Sugestão de cidades próximas quando a localização estiver ativa.
- Fluxo sem login.
- Tela mobile mínima vinculada ao protótipo `docs/prototipos-de-tela/tela-selecionar-cidades.png`.

## Fora do escopo

- Rastreamento contínuo de localização.
- Georreferenciamento avançado.
- Expansão nacional.
- Persistência de preferência do usuário autenticado.

## Critérios de aceite

- Usuário deve conseguir selecionar uma cidade.
- Usuário deve conseguir selecionar mais de uma cidade.
- Usuário deve conseguir limpar a seleção.
- Usuário deve conseguir usar localização atual de forma opcional.
- Quando localização estiver ativa, o sistema deve sugerir cidades próximas.
- Usuário deve conseguir realizar esse fluxo sem login.
