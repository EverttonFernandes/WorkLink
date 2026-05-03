# Entrega WLT-002 — Arquitetura modular hexagonal

## Identificador

- História: `WLT-002`
- Data: `2026-05-03`
- Tipo semântico sugerido: `MINOR`

## Objetivo de negócio

Preparar o backend para evoluir com regras de negócio do WorkLink sem acoplar domínio a framework, banco, cache, storage ou integrações externas.

## Personas afetadas

- Usuário cliente: sem mudança funcional direta nesta entrega.
- Profissional: sem mudança funcional direta nesta entrega.
- Administrador: sem mudança funcional direta nesta entrega.
- Plataforma: ganha fronteiras arquiteturais para evolução segura e manutenível.

## Requisitos atendidos

- RNF02: qualidade, manutenibilidade e testabilidade.
- RNF15: documentação viva e rastreabilidade arquitetural.

## O que foi implementado

- Documento arquitetural do backend em `docs/arquitetura/backend-modular-hexagonal.md`.
- Mapa dos bounded contexts iniciais.
- Regras de responsabilidade para `api`, `application`, `domain` e `infrastructure`.
- Dependência ArchUnit no backend.
- Teste automatizado `ModularHexagonalArchitectureTest`.

## O que não foi implementado

- Regras funcionais do WorkLink.
- Entidades de domínio sem demanda real.
- Interfaces ou adapters sem comportamento real.
- Microserviços.
- CQRS completo.
- Event Sourcing.

## Fluxos, telas, endpoints ou módulos envolvidos

- Backend: documentação e guardrail arquitetural.
- Mobile: `N/A`.
- Funcionais/E2E: `N/A`.

## Estratégia de testes

- Unitários/arquitetura backend: `make backend-test`.
- Integração backend: `mvn verify` dentro do `make backend-test`.
- Funcionais/E2E: `N/A` nesta história estrutural.
- Mobile: `N/A` nesta história backend.

## Evidências de validação

- `make backend-test`: passou em Docker.
- `mvn test`: `5 tests, 0 failures, 0 errors`.
- `mvn verify`: `BUILD SUCCESS`.
- `docker compose config`: passou.
- `git diff --check`: passou.
- Varredura de termos sensíveis: apenas ocorrências documentais.

## Riscos ou limitações remanescentes

- As camadas ainda não possuem classes reais porque as histórias funcionais ainda não começaram.
- O guardrail aceita camadas vazias para evitar criação artificial de domínio.
- As regras ArchUnit devem evoluir quando surgirem integrações, persistência e adapters concretos.

## Arquivos ou módulos relevantes

- `docs/arquitetura/backend-modular-hexagonal.md`
- `worklink-api/pom.xml`
- `worklink-api/src/test/java/br/com/worklink/architecture/ModularHexagonalArchitectureTest.java`
- `docs/tasks/WLT-002/`

## Justificativa do versionamento

A entrega adiciona uma capacidade técnica nova ao projeto: arquitetura backend documentada e protegida por teste automatizado. Por isso, a versão semântica sugerida é `MINOR`.
