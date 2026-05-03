---
task_key: WLT-001
title: "Monorepo e stack base"
story_path: "docs/jira-pessoal/historias-tecnicas/WLT-001-monorepo-stack-base.md"
official_order: 1
phase: DONE
loop_iteration: 2
version_suggestion: MINOR
func_tests_detected: false
func_tests_path: ""
func_tests_framework: ""
exit_bar:
  lint: PASS
  unit_tests: PASS
  integration_tests: N/A
  func_tests: N/A
  mobile_tests: PASS
  coverage: PASS
  sonar: N/A
  sre: PASS
  security: PASS
  arch_review: PASS
  final_review: PASS
metrics:
  unit_coverage_minimum: 95
  mobile_unit_coverage_minimum: 95
  mobile_unit_coverage_observed: "100.00% (3/3)"
  changed_files: 21
  risk_level: LOW
correction_queue: []
cycle_history:
  - iteration: 0
    phase: PLANNING
    summary: "start-work iniciado; plano inicial criado para aprovação humana."
    evidence:
      - "docs/tasks/WLT-001/TASK.md"
      - "docs/tasks/WLT-001/progress.txt"
      - "docs/tasks/WLT-001/IMPLEMENTATION.md"
  - iteration: 1
    phase: EXECUTION
    summary: "Scaffold mínimo do monorepo criado para backend Java/Spring Boot, mobile Flutter, testes funcionais e Docker."
    evidence:
      - "README.md"
      - "worklink-api/pom.xml"
      - "worklink-mobile/pubspec.yaml"
      - "functional-tests/README.md"
      - "docker/README.md"
  - iteration: 1
    phase: VALIDATION
    summary: "Validação local bloqueada por ambiente: Java 21 e Flutter SDK indisponíveis no host."
    evidence:
      - "java -version: OpenJDK 17.0.17"
      - "mvn test: BUILD FAILURE; release version 21 not supported"
      - "flutter --version: command not found"
  - iteration: 2
    phase: CONTAINERIZED_VALIDATION
    summary: "Validação movida para Docker Compose, sem instalar JDK 21, Maven ou Flutter diretamente na máquina."
    evidence:
      - "docker compose config: PASS"
      - "make backend-test: PASS via maven:3.9.9-eclipse-temurin-21"
      - "make mobile-test: PASS via ghcr.io/cirruslabs/flutter:3.24.5"
      - "Flutter coverage: 100.00% (3/3)"
---

# WLT-001 — Monorepo e stack base

## Status

História concluída.

Fase atual: `DONE`.

A estrutura base do monorepo foi criada e validada usando somente containers Docker para ferramentas de build e teste.

## Fontes consultadas

- `docs/jira-pessoal/KANBAN-OFICIAL.md`
- `docs/jira-pessoal/historias-tecnicas/WLT-001-monorepo-stack-base.md`
- `docs/jira-pessoal/EPICO-TECNICO-WORKLINK-V1.md`
- `docs/requisitos/epico-requisitos-nao-funcionais.md`
- `docs/spec-driven-development/spec-driven-development.md`
- `docs/spec-driven-development/padroes-de-testes.md`
- `docs/spec-driven-development/codigo-limpo.md`
- `docs/spec-driven-development/padrões-de-projeto-e-design-de-codigo.md`

## Objetivo da história

Criar a estrutura base do monorepo para permitir evolução coordenada de:

- backend Java 21/Spring Boot;
- mobile Flutter/Dart;
- testes funcionais;
- Docker;
- documentação viva do projeto.

## Escopo implementado

- Estrutura `worklink-api` com aplicação Spring Boot mínima em Java 21.
- Estrutura `worklink-mobile` com aplicação Flutter mínima e teste widget.
- Estrutura `functional-tests` reservada para testes funcionais/E2E.
- Estrutura `docker` com documentação operacional.
- `compose.yml` com validação containerizada de backend e mobile.
- `Makefile` com comandos `backend-test`, `mobile-test` e `test`.
- Documentação raiz do monorepo.

## Fora do escopo preservado

- Microserviços.
- Kubernetes.
- Pipeline completa.
- Publicação mobile.
- Modelagem profunda de domínio.
- Implementação de regras funcionais do WorkLink.
- Banco de dados real e migrations completas.
- Imagens finais de produção multi-stage.

## Diretrizes respeitadas

- Monorepo simples e explícito.
- Nenhuma arquitetura distribuída antecipada.
- Nenhuma regra de negócio acoplada a framework, SDK ou infraestrutura.
- Build e testes executáveis em Docker, sem instalar JDK 21, Maven ou Flutter no host.
- Cobertura unitária mínima de 95% preservada para o código testável existente.

## Validações executadas

- `docker compose config`: passou.
- `make backend-test`: passou em container `maven:3.9.9-eclipse-temurin-21`.
- `make mobile-test`: passou em container `ghcr.io/cirruslabs/flutter:3.24.5`.
- Cobertura mobile calculada a partir de `worklink-mobile/coverage/lcov.info`: `100.00% (3/3)`.
- Busca por secrets/credenciais: sem credenciais reais detectadas nos arquivos da entrega.

## Observações de cobertura

- Backend: o bootstrap `WorkLinkApplication` foi excluído do JaCoCo por não conter regra de negócio testável nesta história. O gate JaCoCo permanece configurado com mínimo de `95%` para classes analisáveis.
- Mobile: o bootstrap `main()` foi excluído da cobertura por ser ponto de entrada de framework. O widget inicial possui cobertura de `100.00%`.

## Resultado

WLT-001 entrega a base mínima para iniciar a evolução do WorkLink com backend, mobile, testes, Docker e documentação rastreável.
