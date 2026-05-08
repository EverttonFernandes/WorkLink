---
task_key: WL-006
title: "Cadastro progressivo do profissional"
story_path: "docs/jira-pessoal/historias/WL-006-cadastro-progressivo-profissional.md"
official_order: 16
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
  changed_files: 34
  risk_level: MEDIUM
release:
  commit_hash: "verificado no fechamento via git rev-parse HEAD"
  semantic_tag: v0.16.0
correction_queue: []
cycle_history:
  - iteration: 0
    phase: EXECUTION
    summary: "WL-006 iniciada como próxima história oficial do Kanban unificado."
    evidence:
      - "docs/jira-pessoal/historias/WL-006-cadastro-progressivo-profissional.md"
      - "docs/prototipos-de-tela/tela-cadastro-do-profissional.png"
  - iteration: 1
    phase: DONE
    summary: "Cadastro progressivo entregue com edicao backend, completude calculada, tela mobile e testes BDD/TDD."
    evidence:
      - "make backend-static-analysis: PASS"
      - "make backend-unit-test: PASS, 88 testes, JaCoCo >= 95%"
      - "make backend-integration-test: PASS, Flyway v005 aplicado"
      - "make mobile-static-analysis: PASS"
      - "make mobile-unit-test: PASS, cobertura 100.00%"
      - "make mobile-screen-test: PASS"
      - "make mobile-integration-test: N/A por ausencia de emulador/simulador/Chrome"
      - "make functional-test: N/A sem cenarios reais"
      - "git diff --check: PASS"
      - "scan de segredos: apenas referencia parametrizada ${WORKLINK_POSTGRES_PASSWORD}"
---

# WL-006 — Cadastro progressivo do profissional

## Plano BDD/TDD

- Dado um cadastro mínimo válido, quando registrar profissional, então o perfil deve nascer básico e com completude mínima.
- Dado um profissional existente, quando completar foto, documento, links, portfólio e serviços, então a completude deve aumentar sem ativar garantia de qualidade.
- Dado campos opcionais vazios, quando editar perfil, então os dados mínimos devem permanecer válidos e a completude deve refletir apenas dados informados.
- Dado um profissional inexistente, quando tentar completar perfil, então a aplicação deve rejeitar com erro de negócio.
- Dado a tela mobile de cadastro, quando preencher campos mínimos e opcionais, então a indicação visual de completude deve evoluir.
- Dado a tela mobile de cadastro, quando salvar e continuar depois, então deve emitir o rascunho sem exigir campos opcionais.

## Decisões

- A história não implementa autenticação real; o identificador do profissional é informado no contrato enquanto auth/ownership não estiverem prontos.
- Foto e portfólio serão referenciados por identificadores de arquivos preparados na WLT-014, sem upload binário nesta entrega.
- Completude é sinal de preenchimento, não promessa de qualidade.
- Regras de completude ficam no domínio/backend e em modelo/controlador mobile, não nos widgets.

## Restrições Pragmáticas e Padrões

- Domínio não depende de Spring, JDBC, Flutter, MinIO ou S3.
- Widgets não contêm regra de negócio de completude.
- Campos sensíveis como CPF/CNPJ não devem aparecer em logs nem em telas públicas.
- Testes devem manter padrão GIVEN/WHEN/THEN.

## Log de Iterações

- Iteração 0: plano criado com escopo de edição progressiva backend e tela mobile inicial.
- Iteração 1: domínio, use case, API, JDBC, migração e tela mobile implementados; gates finais aprovados.

## Aprendizados do Loop

- WLT-014 já oferece a base de metadados para foto/portfólio; esta história deve usar referências seguras quando necessário.
- Completude deve ser tratada como sinal de preenchimento e nunca como garantia de qualidade.
- Coberturas unitárias mobile precisam limpar `coverage/` antes de cada suíte para não misturar lcov de widget tests.
