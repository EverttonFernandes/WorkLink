---
task_key: WL-016
title: "Administração mínima e moderação"
story_path: "docs/jira-pessoal/historias/WL-016-admin-minimo-moderacao.md"
official_order: 33
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
  changed_files: 40
  risk_level: HIGH
release:
  commit_hash: ""
  semantic_tag: v0.33.0
correction_queue: []
cycle_history:
  - iteration: 0
    phase: EXECUTION
    summary: "WL-016 iniciada como próxima história oficial do Kanban unificado."
    evidence:
      - "docs/jira-pessoal/historias/WL-016-admin-minimo-moderacao.md"
      - "Não há protótipo de tela administrativa em docs/prototipos-de-tela; entrega focada no backend operacional."
  - iteration: 1
    phase: DONE
    summary: "Administração mínima entregue com backend administrativo, bloqueio de profissionais, moderação de leitura e métricas básicas."
    evidence:
      - "make backend-static-analysis: PASS"
      - "make backend-unit-test: PASS, 249 testes, cobertura mínima de 95% atendida"
      - "make backend-integration-test: PASS, Flyway v015"
      - "make backend-image-build: PASS"
      - "make functional-test: N/A sem cenários reais"
      - "git diff --check: PASS"
      - "varredura de segredos no diff adicionado: PASS"
---

# WL-016 — Administração mínima e moderação

## Plano BDD/TDD

- Dado um administrador, quando listar profissionais, então deve visualizar cadastrados e status de bloqueio.
- Dado um administrador, quando bloquear profissional, então o profissional deve deixar de aparecer na descoberta.
- Dado um administrador, quando desbloquear profissional, então o profissional pode voltar à descoberta.
- Dado um cliente ou profissional, quando acessar rotas administrativas, então deve receber acesso negado.
- Dado um administrador, quando consultar moderação, então deve visualizar denúncias e contestações de avaliação.
- Dado um administrador, quando consultar métricas, então deve visualizar contadores básicos.

## Decisões

- A gestão de categorias já existe por `POST /api/v1/categories` e exige perfil administrador.
- A WL-016 não cria frontend administrativo porque não há protótipo admin no projeto.
- A moderação de denúncias e contestações será inicialmente de leitura; workflow de decisão fica fora do escopo.

## Restrições Pragmáticas e Padrões

- Regras administrativas ficam na aplicação, com API apenas adaptando HTTP.
- Endpoints administrativos exigem `ADMINISTRATOR`.
- Ações sensíveis devem ser auditadas.
- Profissional bloqueado não pode aparecer na descoberta pública.

## Log de Iterações

- Iteração 0: plano criado para backend administrativo mínimo.
- Iteração 1: implementação concluída e validada com gates backend, integração, imagem Docker e segurança local.

## Aprendizados do Loop

- WLT-010/WLT-011/WLT-015/WLT-016 já fornecem autorização, auditoria, observabilidade e prontidão operacional para esta
  história.
- A tela administrativa fica fora da V1 atual porque não há protótipo vinculado; a entrega expõe a capacidade operacional
  pelo backend.
