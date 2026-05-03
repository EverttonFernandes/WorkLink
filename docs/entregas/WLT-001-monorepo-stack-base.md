# Entrega WLT-001 — Monorepo e stack base

## Identificador

- História: `WLT-001`
- Data: `2026-05-03`
- Tipo semântico sugerido: `MINOR`

## Objetivo de negócio

Criar a base técnica inicial para evoluir o WorkLink em um monorepo único, com backend, mobile, testes, Docker e documentação organizados.

## Personas afetadas

- Usuário cliente: sem mudança funcional direta nesta entrega.
- Profissional: sem mudança funcional direta nesta entrega.
- Administrador: sem mudança funcional direta nesta entrega.
- Plataforma: passa a ter estrutura mínima rastreável para desenvolvimento incremental.

## Requisitos atendidos

- RNF01: arquitetura e organização base do projeto.
- RNF02: qualidade, testabilidade e validação automatizada inicial.
- RNF15: documentação viva e rastreabilidade da entrega.

## O que foi implementado

- Estrutura `worklink-api` com Spring Boot e Java 21.
- Estrutura `worklink-mobile` com Flutter/Dart.
- Estrutura `functional-tests`.
- Estrutura `docker`.
- `compose.yml` para executar validações em containers Docker.
- `Makefile` com comandos padronizados de teste.
- Documentação raiz e documentação operacional da história.

## O que não foi implementado

- Regras funcionais do WorkLink.
- Banco de dados real.
- Pipeline completa de CI/CD.
- Imagens finais de produção multi-stage.
- Kubernetes ou arquitetura distribuída.

## Fluxos, telas, endpoints ou módulos envolvidos

- Backend: bootstrap `WorkLinkApplication`.
- Mobile: app inicial `WorkLinkApp`.
- Testes: unidade/backend e widget/mobile.
- Infraestrutura local: `compose.yml` e `Makefile`.

## Estratégia de testes

- Unitários backend: `make backend-test`.
- Integração: `N/A` nesta história estrutural.
- Funcionais/E2E: `N/A` nesta história estrutural.
- Mobile: `make mobile-test`.

## Evidências de validação

- `docker compose config`: passou.
- `make backend-test`: passou em `maven:3.9.9-eclipse-temurin-21`.
- `make mobile-test`: passou em `ghcr.io/cirruslabs/flutter:3.24.5`.
- Cobertura mobile: `100.00% (3/3)`.
- JaCoCo backend configurado com mínimo de `95%`.
- Validação feita sem instalar JDK 21, Maven ou Flutter diretamente na máquina.

## Riscos ou limitações remanescentes

- As imagens Docker de build/teste consomem espaço relevante no host.
- O backend ainda não possui classes de domínio ou casos de uso testáveis.
- O Docker de produção multi-stage será tratado nas histórias técnicas específicas.

## Arquivos ou módulos relevantes

- `README.md`
- `compose.yml`
- `Makefile`
- `worklink-api/`
- `worklink-mobile/`
- `functional-tests/`
- `docker/`
- `docs/tasks/WLT-001/`

## Justificativa do versionamento

A entrega cria uma capacidade nova de projeto: monorepo inicial com backend, mobile, testes, Docker e documentação. Por isso, a versão semântica sugerida é `MINOR`.
