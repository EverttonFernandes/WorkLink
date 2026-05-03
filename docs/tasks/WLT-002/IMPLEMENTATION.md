---
task_key: WLT-002
title: "Arquitetura modular hexagonal"
story_path: "docs/jira-pessoal/historias-tecnicas/WLT-002-arquitetura-modular-hexagonal.md"
official_order: 2
phase: DONE
loop_iteration: 2
version_suggestion: MINOR
func_tests_detected: false
func_tests_path: ""
func_tests_framework: ""
exit_bar:
  lint: PASS
  unit_tests: PASS
  integration_tests: PASS
  func_tests: N/A
  mobile_tests: N/A
  coverage: PASS
  sonar: N/A
  sre: PASS
  security: PASS
  arch_review: PASS
  final_review: PASS
metrics:
  unit_coverage_minimum: 95
  backend_tests_observed: "5 tests, 0 failures, 0 errors"
  changed_files: 6
  risk_level: LOW
correction_queue: []
cycle_history:
  - iteration: 0
    phase: PLANNING
    summary: "WLT-002 iniciada a partir do Kanban Oficial."
    evidence:
      - "docs/jira-pessoal/historias-tecnicas/WLT-002-arquitetura-modular-hexagonal.md"
      - "docs/spec-driven-development/padrões-de-projeto-e-design-de-codigo.md"
      - "docs/spec-driven-development/codigo-limpo.md"
      - "docs/spec-driven-development/padroes-de-testes.md"
  - iteration: 1
    phase: EXECUTION
    summary: "Documentação arquitetural e teste ArchUnit adicionados sem criar domínio artificial."
    evidence:
      - "docs/arquitetura/backend-modular-hexagonal.md"
      - "worklink-api/src/test/java/br/com/worklink/architecture/ModularHexagonalArchitectureTest.java"
      - "worklink-api/pom.xml"
  - iteration: 1
    phase: VALIDATION
    summary: "Primeira execução falhou porque as camadas ainda estão vazias; guardrail ajustado para aceitar camadas opcionais até surgirem classes reais."
    evidence:
      - "ArchUnit: failOnEmptyShould por pacotes vazios"
      - "Correção: allowEmptyShould(true) e withOptionalLayers(true)"
  - iteration: 2
    phase: VALIDATION
    summary: "Validação backend em Docker passou."
    evidence:
      - "make backend-test: PASS"
      - "mvn test: 5 tests, 0 failures, 0 errors"
      - "mvn verify: BUILD SUCCESS"
      - "docker compose config: PASS"
      - "git diff --check: PASS"
      - "rg secrets: apenas ocorrências documentais"
---

# WLT-002 — Arquitetura modular hexagonal

## Status

História concluída.

Fase atual: `DONE`.

## Objetivo

Definir e aplicar a base arquitetural do backend como monólito modular com DDD tático e Ports and Adapters.

## Decisão de escopo

Esta história não inventou domínio antes das histórias funcionais.

A entrega realizada foi:

- registrar a arquitetura esperada;
- criar guardrail automatizado contra violações;
- manter a aplicação executável;
- deixar a evolução pronta para os bounded contexts reais.

## Bounded contexts iniciais

- `identityaccess`: autenticação, autorização, sessão, tokens, OTP e identidade.
- `customer`: usuário cliente.
- `professional`: profissional, perfil, portfólio e completude.
- `discovery`: busca, filtros, listagem e ranking simples.
- `contact`: intenção de contato e redirecionamento para WhatsApp.
- `postcontactfeedback`: feedback após contato.
- `reviewreputation`: avaliações, reputação e sinais de qualidade.
- `reportmoderation`: denúncias, moderação, bloqueios e contestação.
- `location`: cidades, localização e regiões atendidas.
- `notification`: notificações futuras.
- `admin`: funcionalidades administrativas.

## Estrutura interna por contexto

Cada contexto deve evoluir com as camadas:

- `api`: controllers, DTOs HTTP, presenters e componentes de borda.
- `application`: casos de uso, portas de entrada/saída, comandos e orquestração.
- `domain`: entidades, value objects, specifications, invariantes e serviços de domínio.
- `infrastructure`: adapters concretos para banco, cache, storage, mensageria, HTTP, SDKs e providers.

## Regras protegidas por teste

- `domain` não deve depender de Spring, JPA, Redis, storage, HTTP, SDK externo ou infraestrutura.
- `application` não deve depender de `api` ou `infrastructure`.
- `api` não deve acessar `infrastructure` diretamente.
- O fluxo de dependência entre camadas deve seguir Ports and Adapters.

## Estratégia de testes

- `ModularHexagonalArchitectureTest` usa ArchUnit.
- As regras aceitam camadas vazias neste momento para evitar criação de classes artificiais.
- Quando classes reais forem adicionadas em `api`, `application`, `domain` ou `infrastructure`, as mesmas regras passam a bloquear violações concretas.

## Validações executadas

- `make backend-test`: passou em Docker.
- `mvn test`: `5 tests, 0 failures, 0 errors`.
- `mvn verify`: `BUILD SUCCESS`.
- `docker compose config`: passou.
- `git diff --check`: passou.
- Varredura de termos sensíveis: apenas ocorrências documentais, sem credenciais reais.

## Resultado

WLT-002 entrega a base arquitetural mínima e pragmática para o backend evoluir com monólito modular, DDD tático e Ports and Adapters, sem excesso de engenharia.
