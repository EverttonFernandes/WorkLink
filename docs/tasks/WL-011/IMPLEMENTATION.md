---
task_key: WL-011
title: "Pós-contato estruturado"
story_path: "docs/jira-pessoal/historias/WL-011-pos-contato-estruturado.md"
official_order: 27
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
  changed_files: 38
  risk_level: MEDIUM
release:
  commit_hash: "verificado no fechamento via git rev-parse HEAD"
  semantic_tag: v0.27.0
correction_queue: []
cycle_history:
  - iteration: 0
    phase: EXECUTION
    summary: "WL-011 iniciada como próxima história oficial do Kanban unificado."
    evidence:
      - "docs/jira-pessoal/historias/WL-011-pos-contato-estruturado.md"
      - "Functional test discovery: infraestrutura Jest/Axios existe, mas sem cenários .spec.js reais; gate funcional N/A nesta história."
  - iteration: 1
    phase: EXECUTION
    summary: "Implementado backend e mobile para feedback pós-contato associado à intenção existente."
    evidence:
      - "Domínio PostContactFeedback e enums estruturados criados em domain/contact."
      - "Caso de uso RegisterPostContactFeedbackUseCase valida cliente autenticado, intenção existente e ownership."
      - "Endpoint POST /api/v1/post-contact-feedbacks registra auditoria sensível."
      - "Migração V011 cria worklink.post_contact_feedbacks com FK para contact_intentions e customer_accounts."
      - "Mobile cria PostContactFeedbackController e PostContactFeedbackScreen."
  - iteration: 2
    phase: DONE
    summary: "Gates finais e documentação preparados para commit/tag v0.27.0."
    evidence:
      - "make backend-unit-test: PASS, 192 testes e coverage aprovado."
      - "make backend-static-analysis: PASS."
      - "make backend-integration-test: PASS, Flyway até v011."
      - "make mobile-static-analysis: PASS."
      - "make mobile-unit-test: PASS, cobertura 97,91%."
      - "make mobile-screen-test: PASS, 37 testes de tela."
      - "make mobile-integration-test: N/A por ausência de device/browser."
      - "make functional-test: N/A por ausência de cenários reais."
      - "make backend-image-build: PASS."
      - "Security diff scan: PASS, nenhum segredo novo detectado."
---

# WL-011 — Pós-contato estruturado

## Plano BDD/TDD

- Dado uma intenção de contato existente, quando o cliente registrar feedback, então as respostas devem ser armazenadas.
- Dado uma intenção inexistente, quando registrar feedback, então o sistema deve rejeitar.
- Dado outro cliente autenticado, quando registrar feedback de contato alheio, então o sistema deve negar.
- Dado a tela de pós-contato, quando o usuário responder, então deve informar contato, responsividade e serviço realizado.

## Decisões

- O feedback fica no módulo de contato por ser consequência direta da intenção rastreável.
- A regra valida ownership pelo `customerIdentifier` da intenção de contato.
- O mobile usa controller com callback injetável para manter a tela independente do adapter HTTP real.

## Restrições Pragmáticas e Padrões

- Não criar ranking ou cálculo sofisticado nesta história.
- Não coletar texto livre ou dado pessoal adicional.
- Não permitir feedback sem intenção rastreável.
- Testes devem usar `GIVEN`, `WHEN`, `THEN`.

## Log de Iterações

- Iteração 0: plano criado para feedback pós-contato associado à intenção existente.
- Iteração 1: backend e mobile implementados com BDD/TDD, ownership por cliente e tela pós-contato vinculada ao fluxo
  de WhatsApp.
- Iteração 2: gates QA/SRE/segurança/arquitetura aprovados por evidências locais; entrega pronta para fechamento
  semântico `v0.27.0`.

## Aprendizados do Loop

- A `WL-010` já fornece a intenção de contato; a `WL-011` deve reutilizar essa base sem duplicar o fluxo de WhatsApp.
