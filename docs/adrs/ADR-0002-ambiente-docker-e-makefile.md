# ADR-0002 — Ambiente reproduzível via Docker e Makefile

## Status

Aceita.

## Contexto

O projeto não deve exigir instalação local de Java, Maven, Flutter, Node ou bancos para validação cotidiana.

## Decisão

Os comandos oficiais ficam no `Makefile` e executam ferramentas dentro de containers definidos em `compose.yml`.

## Consequências

- Gates devem ter alvo `make` quando forem recorrentes.
- Caches de build ficam em volumes Docker.
- O `.env` local é criado a partir de `.env.example` e não é versionado.
- Qualquer nova ferramenta deve priorizar execução em container.
