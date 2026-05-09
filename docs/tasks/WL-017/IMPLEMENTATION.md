---
task_key: WL-017
title: "Métricas funcionais e base para ranking futuro"
story_path: "docs/jira-pessoal/historias/WL-017-metricas-ranking-futuro.md"
official_order: 34
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
  mobile_tests: N/A
  coverage: PASS
  sonar: N/A
  sre: PASS
  security: PASS
  arch_review: PASS
  final_review: PASS
metrics:
  unit_coverage_minimum: 95
  changed_files: 32
  risk_level: MEDIUM
release:
  commit_hash: ""
  semantic_tag: v0.34.0
correction_queue: []
cycle_history:
  - iteration: 0
    phase: EXECUTION
    summary: "WL-017 iniciada como próxima história oficial do Kanban unificado."
    evidence:
      - "docs/jira-pessoal/historias/WL-017-metricas-ranking-futuro.md"
      - "Não há protótipo de tela para métricas/ranking; entrega focada no backend."
  - iteration: 1
    phase: DONE
    summary: "Métricas funcionais entregues com persistência de buscas, agregados administrativos e base para ranking futuro sem algoritmo sofisticado."
    evidence:
      - "make backend-static-analysis: PASS"
      - "make backend-unit-test: PASS, 255 testes, cobertura mínima de 95% atendida"
      - "make backend-integration-test: PASS, Flyway v016"
      - "make backend-image-build: PASS"
      - "make functional-test: N/A sem cenários reais"
      - "git diff --check: PASS"
      - "varredura de segredos no diff adicionado: PASS"
---

# WL-017 — Métricas funcionais e base para ranking futuro

## Plano BDD/TDD

- Dado uma busca por profissionais, quando a descoberta é consultada, então um evento de busca deve ser persistido com
  filtros e quantidade de resultados.
- Dado um contato iniciado, quando métricas funcionais forem consultadas, então contatos devem ser agregados por
  profissional, categoria e cidade.
- Dado feedback pós-contato, quando métricas funcionais forem consultadas, então sinais de responsividade devem aparecer.
- Dado profissionais disponíveis e indisponíveis, quando métricas funcionais forem consultadas, então disponibilidade deve
  ser agregada.
- Dado avaliações existentes, quando métricas funcionais forem consultadas, então reputação deve ser agregada.
- Dado a V1, quando métricas forem consultadas, então nenhum algoritmo de ranking sofisticado deve ordenar resultados por
  score opaco.

## Decisões

- A V1 registra e consulta sinais agregados; não define ranking final.
- Contatos, feedbacks, avaliações e disponibilidade já existem como dados persistidos e serão reaproveitados.
- Buscas precisam de persistência própria porque ainda não havia tabela de eventos de descoberta.

## Restrições Pragmáticas e Padrões

- Métricas ficam na aplicação e infraestrutura; API apenas adapta HTTP.
- Consulta administrativa exige `ADMINISTRATOR`.
- Dados pessoais não devem ser expostos nos agregados.
- Não criar motor de busca ou scoring antes de necessidade real.

## Log de Iterações

- Iteração 0: plano criado para backend analítico mínimo.
- Iteração 1: implementação concluída e validada com gates backend, integração, imagem Docker e segurança local.

## Aprendizados do Loop

- WL-016 já fornece endpoints administrativos e autorização para expor métricas internas.
- A base de ranking futuro deve permanecer explicável e auditável; a V1 registra sinais sem ordenar profissionais por
  score opaco.
