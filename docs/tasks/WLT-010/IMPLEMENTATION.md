---
task_key: WLT-010
title: "Autorização por perfil e ownership"
story_path: "docs/jira-pessoal/historias-tecnicas/WLT-010-autorizacao-perfis-ownership.md"
official_order: 21
phase: DONE
loop_iteration: 1
version_suggestion: MINOR
func_tests_detected: false
func_tests_path: "functional-tests/src/**/*.spec.js"
func_tests_framework: "Jest + Axios"
exit_bar:
  lint: PASS
  unit_tests: PASS
  integration_tests: PASS
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
  changed_files: 27
  risk_level: HIGH
release:
  commit_hash: "verificado no fechamento via git rev-parse HEAD"
  semantic_tag: v0.21.0
correction_queue: []
cycle_history:
  - iteration: 0
    phase: EXECUTION
    summary: "WLT-010 iniciada como próxima história oficial do Kanban unificado."
    evidence:
      - "docs/jira-pessoal/historias-tecnicas/WLT-010-autorizacao-perfis-ownership.md"
  - iteration: 1
    phase: DONE
    summary: "Autorização por perfil e ownership implementada nos endpoints sensíveis existentes."
    evidence:
      - "make backend-unit-test: PASS, 132 testes, JaCoCo >= 95%"
      - "make backend-static-analysis: PASS"
      - "make backend-integration-test: PASS"
      - "make mobile-static-analysis: PASS"
      - "make mobile-unit-test: PASS, cobertura 99.51%"
      - "make mobile-screen-test: PASS, 22 testes"
      - "make mobile-integration-test: N/A"
      - "make functional-test: N/A"
      - "git diff --check: PASS"
      - "scan local de secrets: PASS, apenas placeholder esperado no Compose"
---

# WLT-010 — Autorização por perfil e ownership

## Plano BDD/TDD

- Dado um cliente, quando tentar executar ação administrativa, então o acesso deve ser negado.
- Dado um administrador, quando executar ação administrativa, então o acesso deve ser permitido.
- Dado um cliente, quando acessar dado privado próprio, então o acesso deve ser permitido.
- Dado um cliente, quando acessar dado privado de outro cliente, então o acesso deve ser negado.
- Dado um profissional, quando alterar o próprio perfil, então o acesso deve ser permitido.
- Dado um profissional, quando alterar perfil de outro profissional, então o acesso deve ser negado.
- Dado access token assinado, quando resolver principal HTTP, então o sistema deve validar assinatura e expiração.
- Dado endpoint sensível sem permissão, quando chamado, então deve retornar `401` ou `403` sem vazar detalhes internos.

## Decisões

- A política de autorização ficará na camada de aplicação e não dependerá de Spring Security.
- O parser de token ficará em infraestrutura e consumirá o mesmo segredo de assinatura da WLT-009.
- O adapter HTTP será responsável apenas por extrair `Authorization: Bearer` e transformar em principal autenticado.
- Endpoints públicos de listagem continuam públicos.
- Endpoints administrativos de catálogo exigem `ADMINISTRATOR`.
- Alteração de perfil profissional exige `PROFESSIONAL` com ownership pelo identificador do perfil, ou `ADMINISTRATOR`.

## Restrições Pragmáticas e Padrões

- Não introduzir RBAC complexo.
- Não acoplar regras de autorização a controllers ou framework.
- Não registrar access token em logs.
- Testes devem usar padrão `GIVEN`, `WHEN`, `THEN`.

## Log de Iterações

- Iteração 0: plano criado para política de autorização, parser de token e proteção de endpoints sensíveis existentes.
- Iteração 1: política de autorização, parser HMAC-SHA-256, resolver HTTP e proteção de endpoints implementados com testes BDD/TDD.

## Aprendizados do Loop

- A WLT-009 fornece token assinado com `sub`, `profile`, `iat` e `exp`; a WLT-010 deve validar esse contrato sem espalhar parsing de JWT pela aplicação.
- A autorização inicial deve permanecer explícita por ação sensível e ownership para evitar RBAC prematuro.
