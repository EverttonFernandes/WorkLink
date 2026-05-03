# WLT-001 — Monorepo e stack base

## Fonte

- História: `docs/jira-pessoal/historias-tecnicas/WLT-001-monorepo-stack-base.md`
- Ordem oficial: 01 em `docs/jira-pessoal/KANBAN-OFICIAL.md`
- Tipo: Técnica
- Versão sugerida: `MINOR`

## Objetivo

Criar a estrutura base do monorepo para backend, mobile, testes funcionais, Docker e documentação.

## Valor técnico

Permite evoluir backend, app mobile, testes e documentação em uma base coordenada.

## RNFs relacionados

- RNF01
- RNF02
- RNF15

## Escopo incluído

- Estrutura `worklink-api`.
- Estrutura `worklink-mobile`.
- Estrutura `functional-tests`.
- Estrutura `docker`.
- Estrutura `docs`.
- Preparação para Java 21/Spring Boot e Flutter/Dart.

## Fora do escopo

- Microserviços.
- Kubernetes obrigatório.
- Publicação mobile.
- Pipeline completa.

## Critérios de aceite

- O repositório deve seguir a estrutura de monorepo definida no épico técnico.
- Backend deve ter base compatível com Java 21 e Spring Boot.
- Mobile deve ter base compatível com Flutter/Dart.
- Testes funcionais devem ter pasta dedicada.
- Documentação deve ter pasta dedicada.
- A estrutura não deve introduzir arquitetura distribuída complexa.
