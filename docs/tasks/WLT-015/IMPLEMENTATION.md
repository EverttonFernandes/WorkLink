---
task_key: WLT-015
title: "Observabilidade, logs e métricas"
story_path: "docs/jira-pessoal/historias-tecnicas/WLT-015-observabilidade-logs-metricas.md"
official_order: 24
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
  changed_files: 21
  risk_level: MEDIUM
release:
  commit_hash: "verificado no fechamento via git rev-parse HEAD"
  semantic_tag: v0.24.0
correction_queue: []
cycle_history:
  - iteration: 0
    phase: EXECUTION
    summary: "WLT-015 iniciada como próxima história oficial do Kanban unificado."
    evidence:
      - "docs/jira-pessoal/historias-tecnicas/WLT-015-observabilidade-logs-metricas.md"
      - "Functional test discovery: infraestrutura Jest/Axios existe, mas sem cenários .spec.js reais; gate funcional N/A nesta história."
  - iteration: 1
    phase: EXECUTION
    summary: "Implementados correlation id, eventos operacionais, sanitização e Actuator com testes BDD/TDD."
    evidence:
      - "make backend-unit-test: PASS, 172 testes e coverage aprovado."
      - "make backend-static-analysis: PASS."
      - "make backend-integration-test: PASS."
      - "make mobile-static-analysis: PASS."
      - "make mobile-unit-test: PASS, cobertura 99,51%."
      - "make mobile-screen-test: PASS."
      - "make mobile-integration-test: N/A por ausência de device/browser."
      - "make functional-test: N/A por ausência de cenários reais."
      - "make backend-image-build: PASS."
  - iteration: 2
    phase: DONE
    summary: "Documentação, Kanban e gates finais preparados para commit/tag v0.24.0."
    evidence:
      - "docs/arquitetura/observabilidade-logs-metricas.md"
      - "docs/entregas/WLT-015-observabilidade-logs-metricas.md"
      - "Primeiro rerun de backend-unit-test falhou por target Maven inconsistente; target removido via container e suite limpa passou."
      - "git diff --check: PASS."
      - "Varredura de segredos: PASS com placeholder esperado em compose.yml."
---

# WLT-015 — Observabilidade, logs e métricas

## Plano BDD/TDD

- Dado uma requisição HTTP sem correlation id, quando a API processar a requisição, então deve gerar e devolver correlation id.
- Dado uma requisição HTTP com correlation id válido, quando a API processar a requisição, então deve preservar o mesmo identificador.
- Dado um evento operacional com valor sensível, quando o evento for registrado, então o log deve conter valor mascarado.
- Dado a aplicação em execução, quando consultar health/metrics, então Actuator deve expor endpoints mínimos.
- Dado uma falha relevante, quando for registrada como evento operacional, então deve existir severidade, tipo, mensagem e contexto seguro.

## Decisões

- Correlation id ficará na borda HTTP e no MDC, sem vazar para regras de negócio.
- Eventos operacionais ficarão atrás de porta de aplicação, permitindo trocar destino de logs no futuro.
- Sanitização de logs será explícita para OTP, tokens, secrets, documentos, telefone e payloads confidenciais.
- Actuator expõe somente endpoints mínimos: `health`, `info` e `metrics`.

## Restrições Pragmáticas e Padrões

- Não adicionar ELK, Prometheus, Grafana ou tracing distribuído nesta entrega.
- Não logar payload bruto.
- Não acoplar regras de negócio a framework de observabilidade.
- Testes devem usar `GIVEN`, `WHEN`, `THEN`.

## Log de Iterações

- Iteração 0: plano criado para observabilidade mínima e segura.
- Iteração 1: testes e implementação concluíram correlation id HTTP, sanitização, porta de evento operacional e
  configuração mínima de Actuator.
- Iteração 2: QA, SRE, segurança, arquitetura e revisão final aprovados por evidências locais; entrega pronta para
  fechamento semântico `v0.24.0`.

## Aprendizados do Loop

- A WLT-015 deve complementar auditoria sem transformar log operacional em trilha de auditoria de negócio.
- Fixtures de testes de sanitização não devem conter padrões literais que pareçam segredos para a varredura local.
- Quando o build Docker gera/reusa `target`, uma limpeza via container pode ser necessária para forçar recompilação
  completa antes do gate final.
