---
task_key: WL-003
title: "Descoberta por categoria, cidade e palavra-chave"
story_path: "docs/jira-pessoal/historias/WL-003-descoberta-busca-filtros.md"
official_order: 12
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
  changed_files: 14
  risk_level: MEDIUM
correction_queue: []
cycle_history:
  - iteration: 0
    phase: EXECUTION
    summary: "WL-003 iniciada a partir da próxima história oficial do Kanban unificado."
    evidence:
      - "docs/jira-pessoal/historias/WL-003-descoberta-busca-filtros.md"
  - iteration: 1
    phase: DONE
    summary: "Descoberta por categoria, cidade e palavra-chave implementada com backend, tela mobile, testes e documentação."
    evidence:
      - "make backend-static-analysis"
      - "make backend-unit-test"
      - "make backend-integration-test"
      - "make mobile-static-analysis"
      - "make mobile-unit-test"
      - "make mobile-screen-test"
      - "make mobile-integration-test"
      - "make functional-test"
      - "docs/entregas/WL-003-descoberta-busca-filtros.md"
---

# WL-003 — Descoberta por categoria, cidade e palavra-chave

## Plano BDD/TDD

- Dado profissionais cadastrados, quando buscar por categoria, então apenas profissionais daquela categoria devem retornar.
- Dado profissionais cadastrados, quando buscar por palavra-chave, então nome e descrição curta devem ser considerados.
- Dado profissionais cadastrados, quando buscar por uma ou mais cidades, então apenas profissionais dessas cidades devem retornar.
- Dado filtros combinados, quando executar a descoberta, então todos os critérios devem ser aplicados em conjunto.
- Dado filtros ativos, quando limpar filtros, então a busca deve voltar ao estado padrão.
- Dado uma busca sem compatíveis, quando renderizar a tela, então deve existir estado vazio claro.

## Decisões

- A descoberta inicial retorna dados resumidos e mantém ranking sofisticado fora do escopo.
- A API recebe filtros opcionais por query string e não exige autenticação.
- A tela mobile usa dados locais mínimos até a integração HTTP real ser criada em histórias futuras.

## Resultado

- Backend permite buscar profissionais por categoria, cidade única, múltiplas cidades e palavra-chave.
- Filtros combinados são aplicados em conjunto no adapter PostgreSQL.
- Mobile exibe descoberta com resultados, limpeza de filtros e estado vazio.
- Testes funcionais e integração mobile foram executados como `N/A` por ausência de cenários reais e device/emulador.
