---
task_key: WL-008
title: "Disponibilidade do profissional"
story_path: "docs/jira-pessoal/historias/WL-008-disponibilidade-profissional.md"
official_order: 18
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
  changed_files: 35
  risk_level: MEDIUM
release:
  commit_hash: "verificado no fechamento via git rev-parse HEAD"
  semantic_tag: v0.18.0
correction_queue: []
cycle_history:
  - iteration: 0
    phase: EXECUTION
    summary: "WL-008 iniciada como próxima história oficial do Kanban unificado."
    evidence:
      - "docs/jira-pessoal/historias/WL-008-disponibilidade-profissional.md"
  - iteration: 1
    phase: DONE
    summary: "Disponibilidade do profissional implementada como enum fechado no domínio, persistida no PostgreSQL, exposta na API e exibida no mobile sem promessa de garantia."
    evidence:
      - "make backend-static-analysis: PASS"
      - "make backend-integration-test: PASS, 91 testes unitários, 1 teste de integração e JaCoCo PASS"
      - "make mobile-static-analysis: PASS"
      - "make mobile-unit-test: PASS, cobertura 99.51%"
      - "make mobile-screen-test: PASS"
      - "make mobile-integration-test: N/A, sem Android Emulator, iOS Simulator ou Chrome disponível"
      - "make functional-test: N/A, sem cenários funcionais reais"
      - "git diff --check: PASS"
      - "Varredura local de segredos: PASS, apenas compose.yml usa variável de senha do PostgreSQL"
---

# WL-008 — Disponibilidade do profissional

## Plano BDD/TDD

- Dado um profissional, quando informar disponibilidade, então o status deve ficar restrito aos valores permitidos da V1.
- Dado um profissional disponível, quando listar ou abrir perfil, então o badge de disponibilidade deve aparecer.
- Dado um profissional indisponível temporariamente, quando listar profissionais, então ele deve perder destaque.
- Dado qualquer disponibilidade, quando exibir a UI, então o texto não deve prometer garantia de atendimento.

## Decisões

- Disponibilidade será um enum fechado no domínio e persistência.
- O default para profissionais existentes será `ACCEPTING_NEW_CLIENTS`.
- Indisponibilidade reduz destaque por ordenação/prioridade, sem remover o profissional.

## Restrições Pragmáticas e Padrões

- Não criar agenda ou reserva de horário nesta história.
- Não tratar disponibilidade como garantia de atendimento.
- Testes devem usar padrão `GIVEN`, `WHEN`, `THEN`.

## Log de Iterações

- Iteração 0: plano criado e escopo definido em torno de enum fechado, API pública e UI mobile.
- Iteração 1: implementação, testes, revisão arquitetural, segurança e documentação concluídos.

## Aprendizados do Loop

- A tela já possuía `availabilityLabel`; WL-008 deve trocar texto solto por regra rastreável e consistente.
- Execuções paralelas de testes Flutter que escrevem em `build/` podem competir entre si; gates mobile devem rodar de forma sequencial quando ambos usam Flutter Test.
