---
task_key: WL-012
title: "Avaliação anônima com rastreabilidade interna"
story_path: "docs/jira-pessoal/historias/WL-012-avaliacao-anonima-rastreavel.md"
official_order: 28
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
  changed_files: 34
  risk_level: MEDIUM
release:
  commit_hash: ""
  semantic_tag: v0.28.0
correction_queue: []
cycle_history:
  - iteration: 0
    phase: EXECUTION
    summary: "WL-012 iniciada como próxima história oficial do Kanban unificado."
    evidence:
      - "docs/jira-pessoal/historias/WL-012-avaliacao-anonima-rastreavel.md"
      - "Functional test discovery: infraestrutura Jest/Axios existe, mas sem cenários .spec.js reais; gate funcional N/A nesta história."
  - iteration: 1
    phase: EXECUTION
    summary: "Backend da avaliação profissional implementado com elegibilidade por contato/pós-contato, anonimato público e autoria interna."
    evidence:
      - "make backend-unit-test: PASS, 203 testes e cobertura mínima atendida."
      - "make backend-static-analysis: PASS."
      - "make backend-integration-test: PASS, Flyway até v012."
  - iteration: 2
    phase: DONE
    summary: "Mobile, documentação e gates finais concluídos para a entrega WL-012."
    evidence:
      - "make mobile-static-analysis: PASS."
      - "make mobile-unit-test: PASS, cobertura 97,83%."
      - "make mobile-screen-test: PASS, 43 testes."
      - "make mobile-integration-test: N/A por ausência de Android Emulator, iOS Simulator ou Chrome."
      - "make functional-test: N/A por ausência de cenários reais."
      - "make backend-image-build: PASS."
      - "git diff --check: PASS."
      - "Security diff scan: PASS."
---

# WL-012 — Avaliação anônima com rastreabilidade interna

## Plano BDD/TDD

- Dado um contato registrado com pós-contato de serviço realizado, quando o cliente avaliar, então a avaliação deve ser
  armazenada.
- Dado um contato sem pós-contato de serviço realizado, quando o cliente avaliar, então o sistema deve rejeitar.
- Dado outro cliente autenticado, quando avaliar contato alheio, então o sistema deve negar.
- Dado avaliação anônima, quando projetar resposta pública, então a autoria interna deve ser preservada e a pública
  ocultada.
- Dado a tela de avaliação, quando o usuário não informar nota, então o envio deve ser bloqueado.

## Decisões

- A avaliação fica em módulo próprio de reputação para preparar a `WL-013` sem acoplar ao contato.
- A elegibilidade usa a intenção de contato da `WL-010` e o pós-contato da `WL-011`.
- Comentário é opcional e tratado como texto limpo, sem obrigar dado pessoal adicional.
- A resposta pública não retorna o identificador interno do autor.

## Restrições Pragmáticas e Padrões

- Não implementar ranking nesta história.
- Não expor autoria interna em DTO público.
- Não permitir avaliação sem contato e sem serviço realizado.
- Testes devem usar `GIVEN`, `WHEN`, `THEN`.

## Log de Iterações

- Iteração 0: plano criado para avaliação profissional com anonimato público e autoria interna.
- Iteração 1: backend fechado com domínio, caso de uso, endpoint, adapter JDBC, auditoria sensível e migração V012.
- Iteração 2: mobile fechado com tela de avaliação, fluxo a partir do pós-contato realizado, docs e gates.

## Aprendizados do Loop

- A `WL-011` fornece o sinal de serviço realizado; a `WL-012` deve depender desse sinal em vez de confiar somente no
  envio de formulário.
