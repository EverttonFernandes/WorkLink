# ADR-0003 — Cobertura unitária mínima de 95%

## Status

Aceita.

## Contexto

O projeto será implementado de forma incremental por agentes e precisa de backpressure objetivo para evitar regressões.

## Decisão

Testes unitários do backend e do mobile devem manter cobertura mínima de 95% nos gates locais e CI/CD.

## Consequências

- Código novo deve nascer com testes no padrão Given/When/Then.
- Cobertura baixa bloqueia fechamento de história.
- Testes de integração, funcionais e tela complementam, mas não substituem testes unitários.
