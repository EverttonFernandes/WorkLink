---
task_key: WL-013
title: "Exibição de avaliações no perfil"
story_path: "docs/jira-pessoal/historias/WL-013-exibicao-avaliacoes-perfil.md"
official_order: 29
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
  changed_files: 35
  risk_level: MEDIUM
release:
  commit_hash: ""
  semantic_tag: v0.29.0
correction_queue: []
cycle_history:
  - iteration: 0
    phase: EXECUTION
    summary: "WL-013 iniciada como próxima história oficial do Kanban unificado."
    evidence:
      - "docs/jira-pessoal/historias/WL-013-exibicao-avaliacoes-perfil.md"
      - "Functional test discovery: infraestrutura Jest/Axios existe, mas sem cenários .spec.js reais; gate funcional N/A nesta história."
  - iteration: 1
    phase: DONE
    summary: "WL-013 implementada com exibição pública de avaliações, solicitação rastreável de análise e gates concluídos."
    evidence:
      - "make backend-unit-test: PASS, 215 testes e cobertura mínima atendida"
      - "make backend-static-analysis: PASS"
      - "make backend-integration-test: PASS, Flyway até v013"
      - "make mobile-static-analysis: PASS"
      - "make mobile-unit-test: PASS, cobertura 97,60%"
      - "make mobile-screen-test: PASS, 44 testes"
      - "make mobile-integration-test: N/A sem emulador/simulador/Chrome"
      - "make functional-test: N/A sem cenários reais"
      - "make backend-image-build: PASS"
      - "git diff --check: PASS"
      - "Security diff scan: PASS"
---

# WL-013 — Exibição de avaliações no perfil

## Plano BDD/TDD

- Dado um profissional com avaliações, quando consultar a projeção pública, então deve retornar média, quantidade e
  comentários.
- Dado uma avaliação anônima, quando exibir publicamente, então deve ocultar identidade do autor.
- Dado uma avaliação sem comentário, quando exibir publicamente, então ela deve contar na média sem item textual vazio.
- Dado um profissional sem avaliações, quando abrir perfil, então deve mostrar estado sem avaliações sem quebrar layout.
- Dado um profissional autenticado, quando solicitar análise de avaliação indevida, então o pedido deve ser registrado de
  forma rastreável.

## Decisões

- A WL-013 não cria ranking; apenas calcula média simples e quantidade.
- A projeção pública deve nascer no módulo `review`, preservando anonimato e evitando vazamento de autoria interna.
- A tela mobile de perfil deve receber uma estrutura de avaliações em vez de texto livre.

## Restrições Pragmáticas e Padrões

- Não expor `internalAuthorIdentifier`.
- Não criar moderação completa nesta história.
- Não acoplar regra de negócio ao framework.
- Testes devem usar `GIVEN`, `WHEN`, `THEN`.

## Log de Iterações

- Iteração 0: plano criado para exibição pública de avaliações e solicitação simples de análise.
- Iteração 1: implementação concluída no backend e mobile, com testes BDD/TDD e documentação de entrega.

## Aprendizados do Loop

- A WL-012 fornece avaliações com autoria interna e autoria pública já projetada; a WL-013 deve consumir somente a
  superfície pública segura.
- O gate de cobertura do backend protegeu a história: os testes foram ampliados para cobrir o mapeamento JDBC de leitura
  das avaliações.
