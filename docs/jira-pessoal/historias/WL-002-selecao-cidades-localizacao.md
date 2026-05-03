# WL-002 — Seleção de cidades e localização atual

## Objetivo

Permitir que o usuário defina a base regional da busca usando uma ou mais cidades ou localização atual.

## Valor entregue

O WorkLink começa a operar como descoberta regional, não como catálogo genérico.

## Personas

- Usuário cliente

## Requisitos relacionados

- RF03, RF04, RF05, RF06, RF07, RF54
- RN01

## Escopo incluído

- Seleção manual de uma ou mais cidades.
- Uso opcional da localização atual como base de busca.
- Sugestão de cidades próximas quando localização estiver ativa.
- Limpeza de seleção/filtros de cidade.

## Fora do escopo

- Rastreamento contínuo de localização.
- Expansão nacional.
- Georreferenciamento avançado.

## Critérios de aceite

- Usuário deve conseguir selecionar uma cidade.
- Usuário deve conseguir selecionar mais de uma cidade.
- Usuário deve conseguir limpar a seleção.
- Usuário deve conseguir usar localização atual de forma opcional.
- Quando localização estiver ativa, o sistema deve sugerir cidades próximas.
- Usuário deve conseguir realizar esse fluxo sem login.

## Protótipos de tela vinculados

- `docs/prototipos-de-tela/tela-selecionar-cidades.png`

### Requisitos não funcionais por tela

- fluxo deve respeitar privacidade e pedir localização apenas de forma opcional;
- tela deve funcionar sem login;
- testes mobile devem cobrir seleção, limpeza, uso de localização e estados de erro quando aplicável.

## Entrega versionável

- Tipo sugerido: `MINOR`
- Motivo: adiciona capacidade de busca regional.
