---
task_key: WL-007
title: "Badges de confiança e completude"
story_path: "docs/jira-pessoal/historias/WL-007-badges-confianca-completude.md"
official_order: 17
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
  changed_files: 11
  risk_level: MEDIUM
release:
  commit_hash: "verificado no fechamento via git rev-parse HEAD"
  semantic_tag: v0.17.0
correction_queue: []
cycle_history:
  - iteration: 0
    phase: EXECUTION
    summary: "WL-007 iniciada como próxima história oficial do Kanban unificado."
    evidence:
      - "docs/jira-pessoal/historias/WL-007-badges-confianca-completude.md"
  - iteration: 1
    phase: DONE
    summary: "Badges de completude e confiança implementados sem expor documento sensível."
    evidence:
      - "make backend-static-analysis: PASS"
      - "make backend-unit-test: PASS, 88 testes, JaCoCo PASS"
      - "make backend-integration-test: PASS, Flyway v005"
      - "make mobile-static-analysis: PASS"
      - "make mobile-unit-test: PASS, cobertura 100.00%"
      - "make mobile-screen-test: PASS"
      - "make mobile-integration-test: N/A sem emulator/simulator/Chrome"
      - "make functional-test: N/A sem cenarios reais"
      - "git diff --check: PASS"
      - "secret scan: PASS, somente compose.yml usa variavel WORKLINK_POSTGRES_PASSWORD"
---

# WL-007 — Badges de confiança e completude

## Plano BDD/TDD

- Dado um profissional mínimo, quando consultar badges, então deve exibir perfil básico.
- Dado um profissional completo, quando consultar badges, então deve exibir perfil completo.
- Dado telefone validado, quando consultar badges, então deve exibir telefone verificado.
- Dado documento informado, quando consultar resposta pública, então deve exibir apenas sinal booleano sem expor documento.
- Dado a interface de perfil, quando exibir badges, então não deve prometer garantia de qualidade.

## Decisões

- Documento informado vira `documentProvided`; o número não sai na resposta HTTP pública.
- Telefone verificado fica preparado como sinal booleano, mas validação real é de história futura.
- Badge é sinal de completude/confiança, não garantia do serviço.

## Restrições Pragmáticas e Padrões

- Não expor CPF/CNPJ em API pública, UI pública, logs ou eventos.
- Não acoplar badge a garantia de qualidade.
- Testes devem usar padrão GIVEN/WHEN/THEN.

## Log de Iterações

- Iteração 0: plano criado e risco de exposição de `documentNumber` identificado.
- Iteração 1: API publica passou a expor `documentProvided`, mobile derivou badges por completude/telefone/documento e todos os gates aplicáveis passaram.

## Aprendizados do Loop

- WL-006 criou o dado sensível; WL-007 deve transformar esse dado em sinal seguro de produto.
- Badges de confiança precisam continuar como sinais objetivos; garantia de qualidade permanece fora do escopo.
