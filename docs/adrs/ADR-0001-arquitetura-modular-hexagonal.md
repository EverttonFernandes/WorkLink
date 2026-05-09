# ADR-0001 — Arquitetura modular hexagonal no backend

## Status

Aceita.

## Contexto

O WorkLink precisa evoluir por histórias pequenas sem acoplar regra de negócio a Spring, JDBC, HTTP, storage ou outros
detalhes externos.

## Decisão

O backend usa DDD tático com portas e adaptadores. Regras de aplicação ficam em `application`, regras de negócio em
`domain`, entrada HTTP em `api` e integrações em `infrastructure`.

## Consequências

- Controllers não devem conter regra de negócio.
- Adaptadores não devem ser chamados diretamente por domínio ou casos de uso.
- Dependências externas são isoladas atrás de portas.
- A arquitetura pode crescer por necessidade real, sem criar camadas especulativas.
