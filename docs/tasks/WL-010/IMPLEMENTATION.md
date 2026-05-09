---
task_key: WL-010
title: "Contato via WhatsApp e intenção de contato"
story_path: "docs/jira-pessoal/historias/WL-010-contato-whatsapp-intencao.md"
official_order: 26
phase: DONE
loop_iteration: 2
version_suggestion: MINOR
func_tests_detected: false
func_tests_path: "functional-tests/src/**/*.spec.js"
func_tests_framework: "Jest + Axios sem cenários reais executáveis no momento"
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
  semantic_tag: v0.26.0
correction_queue: []
cycle_history:
  - iteration: 0
    phase: EXECUTION
    summary: "WL-010 iniciada como próxima história oficial do Kanban unificado."
    evidence:
      - "docs/jira-pessoal/historias/WL-010-contato-whatsapp-intencao.md"
      - "Functional test discovery: infraestrutura Jest/Axios existe, mas sem cenários .spec.js reais; gate funcional N/A nesta história."
  - iteration: 1
    phase: EXECUTION
    summary: "Implementado backend e mobile para contato via WhatsApp com intenção rastreável."
    evidence:
      - "Contato backend criado em domain/application/api/infrastructure/contact."
      - "Migração V010 cria worklink.contact_intentions."
      - "Mobile cria ProfessionalContactController e ProfessionalContactScreen."
      - "make backend-unit-test: PASS, 182 testes e coverage aprovado."
      - "make mobile-unit-test: PASS, cobertura 98,01%."
      - "make mobile-screen-test: PASS."
  - iteration: 2
    phase: DONE
    summary: "Gates finais e documentação preparados para commit/tag v0.26.0."
    evidence:
      - "make backend-static-analysis: PASS."
      - "make backend-integration-test: PASS, Flyway até v010."
      - "make mobile-static-analysis: PASS."
      - "make mobile-integration-test: N/A por ausência de device/browser."
      - "make functional-test: N/A por ausência de cenários reais."
      - "make backend-image-build: PASS."
      - "docs/entregas/WL-010-contato-whatsapp-intencao.md"
---

# WL-010 — Contato via WhatsApp e intenção de contato

## Plano BDD/TDD

- Dado o usuário não autenticado, quando tentar contato, então não deve iniciar a intenção nem abrir WhatsApp.
- Dado o cliente autenticado, quando iniciar contato, então a intenção deve ser registrada antes do redirecionamento.
- Dado o profissional existente, quando iniciar contato, então o link WhatsApp deve ser gerado por adapter externo.
- Dado erro no redirecionamento mobile, quando o link não abrir, então a tela deve informar falha sem desfazer a intenção.
- Dado a tela de contato, quando renderizar, então deve informar negociação fora do app e ausência de garantia WorkLink.

## Decisões

- A regra de negócio registra a intenção e depende apenas de portas para persistência, tempo e link WhatsApp.
- A API exige principal autenticado com perfil `CUSTOMER`.
- O mobile usa controller com callbacks injetáveis para manter o adapter externo testável sem acoplar regra à tela.

## Restrições Pragmáticas e Padrões

- Não criar chat, contrato, pagamento ou garantia de execução.
- Não acoplar regra de negócio ao framework, HTTP, banco ou WhatsApp.
- Registrar intenção antes de devolver ou abrir o link externo.
- Testes devem usar `GIVEN`, `WHEN`, `THEN`.

## Log de Iterações

- Iteração 0: plano criado para backend e mobile da intenção de contato.
- Iteração 1: backend e mobile implementados com BDD/TDD, persistência antes de link externo e tela de aviso.
- Iteração 2: gates QA/SRE/segurança/arquitetura aprovados por evidências locais; entrega pronta para fechamento
  semântico `v0.26.0`.

## Aprendizados do Loop

- A autenticação simplificada já protege o ponto de contato no mobile; a WL-010 deve substituir o aviso temporário por
  fluxo real de contato.
