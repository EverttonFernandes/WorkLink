---
task_key: WL-002
title: "Seleção de cidades e localização atual"
story_path: "docs/jira-pessoal/historias/WL-002-selecao-cidades-localizacao.md"
official_order: 11
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
  changed_files: 19
  risk_level: MEDIUM
correction_queue: []
cycle_history:
  - iteration: 0
    phase: EXECUTION
    summary: "WL-002 iniciada a partir da próxima história oficial do Kanban unificado."
    evidence:
      - "docs/jira-pessoal/historias/WL-002-selecao-cidades-localizacao.md"
  - iteration: 1
    phase: DONE
    summary: "Seleção de cidades e localização atual implementada com backend, tela mobile, testes e documentação de entrega."
    evidence:
      - "make backend-static-analysis"
      - "make backend-unit-test"
      - "make backend-integration-test"
      - "make mobile-static-analysis"
      - "make mobile-unit-test"
      - "make mobile-screen-test"
      - "make mobile-integration-test"
      - "make functional-test"
      - "docs/entregas/WL-002-selecao-cidades-localizacao.md"
---

# WL-002 — Seleção de cidades e localização atual

## Plano BDD/TDD

- Dado uma lista de cidades disponíveis, quando o usuário selecionar uma cidade, então a seleção deve conter essa cidade.
- Dado uma lista de cidades disponíveis, quando o usuário selecionar mais de uma cidade, então a seleção deve preservar as cidades selecionadas.
- Dado uma seleção existente, quando o usuário limpar a seleção, então nenhuma cidade deve permanecer selecionada.
- Dado localização atual opcional, quando ela estiver ativa, então o backend deve sugerir cidades próximas.
- Dado o fluxo sem autenticação, quando a seleção for feita, então nenhum dado de sessão autenticada deve ser exigido.

## Decisões

- A localização atual é usada apenas como entrada transitória de sugestão; não será persistida.
- Cidades podem ter coordenadas opcionais para permitir sugestão próxima sem georreferenciamento avançado.
- A tela mobile manterá estado local mínimo até histórias futuras de busca persistirem filtros.

## Resultado

- Backend expõe prévia e limpeza de seleção de cidades sem autenticação.
- Aplicação preserva seleção simples/múltipla e sugere até 5 cidades próximas quando localização atual é informada.
- Mobile renderiza tela mínima de seleção, limpeza e sugestões próximas com estado local.
- Entrega registrada em `docs/entregas/WL-002-selecao-cidades-localizacao.md`.
- Testes funcionais e integração mobile foram executados como `N/A` por ausência de cenários reais e device/emulador.
