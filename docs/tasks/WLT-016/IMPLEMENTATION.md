---
task_key: WLT-016
title: "Disponibilidade e escalabilidade stateless"
story_path: "docs/jira-pessoal/historias-tecnicas/WLT-016-disponibilidade-escalabilidade-stateless.md"
official_order: 32
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
  changed_files: 11
  risk_level: MEDIUM
release:
  commit_hash: ""
  semantic_tag: v0.32.0
correction_queue: []
cycle_history:
  - iteration: 0
    phase: EXECUTION
    summary: "WLT-016 iniciada como próxima história oficial do Kanban unificado."
    evidence:
      - "docs/jira-pessoal/historias-tecnicas/WLT-016-disponibilidade-escalabilidade-stateless.md"
      - "Functional test discovery: infraestrutura Jest/Axios existe, mas sem cenários .spec.js reais; gate funcional N/A nesta história."
  - iteration: 1
    phase: DONE
    summary: "API reforçada para execução stateless com graceful shutdown, readiness real e limites operacionais."
    evidence:
      - "make backend-static-analysis: PASS"
      - "make backend-unit-test: PASS, 228 testes, cobertura mínima atendida"
      - "make backend-integration-test: PASS, Flyway v014"
      - "make backend-image-build: PASS"
      - "make functional-test: N/A sem cenários reais"
      - "docker compose up -d worklink-api: PASS"
      - "GET /actuator/health/readiness: PASS, status UP"
---

# WLT-016 — Disponibilidade e escalabilidade stateless

## Plano BDD/TDD

- Dado a API em produção, quando receber encerramento do processo, então deve usar graceful shutdown.
- Dado a API atrás de load balancer, quando readiness for consultado, então deve considerar dependências necessárias.
- Dado integrações externas futuras, quando configuradas, então devem possuir timeout e retry finito.
- Dado storage e sessões, quando executar múltiplas instâncias, então nenhum estado crítico deve depender do filesystem ou
  memória local do container.
- Dado cache futuro, quando houver bloqueio de profissional ou denúncia grave, então cache aplicável deve ser invalidado
  rapidamente e nunca ser fonte da verdade.

## Decisões

- A V1 não adicionará cache funcional sem necessidade real de produto.
- Sessões de refresh já são persistidas no PostgreSQL; access tokens são assinados e stateless.
- Arquivos seguem representados por metadados e object keys; o container da API não deve persistir upload local.
- Timeouts e retries externos serão tratados como contrato configurável antes de haver novos adapters HTTP reais.

## Restrições Pragmáticas e Padrões

- Não introduzir Kubernetes, service mesh, filas ou cache distribuído sem caso de uso concreto.
- Não usar sessão HTTP como mecanismo de autenticação.
- Não salvar arquivos no filesystem do container.
- Manter ports and adapters para qualquer integração externa futura.

## Log de Iterações

- Iteração 0: plano criado para reforço operacional stateless.
- Iteração 1: configuração operacional e documentação concluídas com validação em container.

## Aprendizados do Loop

- WLT-015 já entregou Actuator, logs e probes; WLT-016 deve complementar prontidão operacional, não duplicar
  observabilidade.
- Readiness com banco é suficiente para V1 porque PostgreSQL é a dependência transacional obrigatória; cache funcional
  não foi introduzido por ausência de gargalo real.
