---
task_key: WL-014
title: "Denúncia de profissional"
story_path: "docs/jira-pessoal/historias/WL-014-denuncia-profissional.md"
official_order: 30
phase: DONE
loop_iteration: 1
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
  changed_files: 29
  risk_level: HIGH
release:
  commit_hash: ""
  semantic_tag: v0.30.0
correction_queue: []
cycle_history:
  - iteration: 0
    phase: EXECUTION
    summary: "WL-014 iniciada como próxima história oficial do Kanban unificado."
    evidence:
      - "docs/jira-pessoal/historias/WL-014-denuncia-profissional.md"
      - "Functional test discovery: infraestrutura Jest/Axios existe, mas sem cenários .spec.js reais; gate funcional N/A nesta história."
  - iteration: 1
    phase: DONE
    summary: "Canal mínimo de denúncia implementado com motivo obrigatório, descrição opcional, evidência opcional, orientação para casos graves, auditoria e tela mobile."
    evidence:
      - "make backend-unit-test: PASS, 226 testes e cobertura mínima atendida."
      - "make backend-static-analysis: PASS."
      - "make backend-integration-test: PASS, Flyway até v014."
      - "make mobile-static-analysis: PASS."
      - "make mobile-unit-test: PASS, cobertura 96,58%."
      - "make mobile-screen-test: PASS, 48 testes de tela."
      - "make mobile-integration-test: N/A por ausência de Android Emulator, iOS Simulator ou Chrome."
      - "make functional-test: N/A por ausência de cenários reais."
      - "make backend-image-build: PASS."
      - "git diff --check: PASS."
      - "Security diff scan: PASS."
---

# WL-014 — Denúncia de profissional

## Plano BDD/TDD

- Dado um usuário autenticado, quando denunciar profissional com motivo válido, então a denúncia deve ser registrada para
  análise.
- Dado uma denúncia sem motivo, quando registrar, então o sistema deve bloquear a operação.
- Dado uma denúncia com evidência, quando registrar, então deve vincular apenas o identificador do arquivo seguro.
- Dado um motivo grave, quando registrar ou exibir a tela, então deve orientar busca por autoridades competentes.
- Dado o perfil do profissional, quando tocar em denunciar, então deve abrir a tela de denúncia.

## Decisões

- A WL-014 cria canal mínimo de denúncia, não moderação completa.
- Evidência será representada por identificador de arquivo já preparado pelo storage seguro.
- A descrição é permitida e normalizada, sem ser obrigatória no backend.
- Motivos graves retornam orientação institucional, sem promessa jurídica.

## Restrições Pragmáticas e Padrões

- Não expor dados internos de denúncia em superfícies públicas.
- Não criar workflow administrativo nesta história.
- Não acoplar regra de denúncia ao controller HTTP ou tela mobile.
- Testes devem usar `GIVEN`, `WHEN`, `THEN`.

## Log de Iterações

- Iteração 0: plano criado para canal mínimo de denúncia com auditoria, privacidade e evidência opcional.
- Iteração 1: implementação concluída e validada com gates backend, mobile, SRE, segurança e revisão final.

## Aprendizados do Loop

- WLT-014 já fornece `REPORT_ATTACHMENT` e `REPORT_EVIDENCE` como arquivos confidenciais; a denúncia deve referenciar
  apenas o identificador seguro do arquivo.
- Motivo inválido deve ser tratado no caso de uso como violação de aplicação para evitar vazamento de erro técnico pelo
  contrato HTTP.
