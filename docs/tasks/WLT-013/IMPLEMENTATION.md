---
task_key: WLT-013
title: "Criptografia e proteção de dados"
story_path: "docs/jira-pessoal/historias-tecnicas/WLT-013-criptografia-protecao-dados.md"
official_order: 19
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
  changed_files: 24
  risk_level: HIGH
release:
  commit_hash: "verificado no fechamento via git rev-parse HEAD"
  semantic_tag: v0.19.0
correction_queue: []
cycle_history:
  - iteration: 0
    phase: EXECUTION
    summary: "WLT-013 iniciada como próxima história oficial do Kanban unificado."
    evidence:
      - "docs/jira-pessoal/historias-tecnicas/WLT-013-criptografia-protecao-dados.md"
  - iteration: 1
    phase: DONE
    summary: "Proteção de dados sensíveis implementada e validada."
    evidence:
      - "make backend-unit-test: PASS, 94 testes, JaCoCo PASS"
      - "make backend-static-analysis: PASS"
      - "make backend-integration-test: PASS, Flyway v007"
      - "make mobile-static-analysis: PASS"
      - "make mobile-unit-test: PASS, 99.51%"
      - "make mobile-screen-test: PASS"
      - "make mobile-integration-test: N/A"
      - "make functional-test: N/A"
---

# WLT-013 — Criptografia e proteção de dados

## Plano BDD/TDD

- Dado um CPF/CNPJ informado no cadastro progressivo, quando persistir o profissional, então apenas o hash protegido deve ser salvo.
- Dado um valor sensível de OTP ou refresh token, quando aplicar proteção, então o resultado deve ser determinístico, não reversível e dependente do pepper.
- Dado configuração de ambiente real, quando documentar/validar operação, então TLS deve ser obrigatório fora do ambiente local.
- Dado arquivo confidencial, quando preparar storage, então o metadado deve manter acesso confidencial e não expor chave interna ao consumidor.
- Dado erro ou auditoria, quando revisar logging, então dados sensíveis não devem ser logados.

## Decisões

- Usar HMAC-SHA-256 com pepper configurável como proteção de campo para deduplicação sem plaintext.
- Manter hashing atrás de porta de aplicação para preservar Ports and Adapters.
- Trocar `document_number` por `document_number_hash` via migração, descartando eventual valor legado sem proteção.
- Preparar finalidades de hash para `DOCUMENT_NUMBER`, `OTP` e `REFRESH_TOKEN`; os fluxos reais de OTP/token serão implementados nas histórias de autenticação.

## Restrições Pragmáticas e Padrões

- Não introduzir KMS, HSM ou SDK externo nesta história.
- Não acoplar criptografia ao domínio.
- Não persistir CPF/CNPJ em claro.
- Testes devem usar padrão `GIVEN`, `WHEN`, `THEN`.

## Log de Iterações

- Iteração 0: plano criado em torno de hashing com pepper, migração de proteção e preparação para autenticação.
- Iteração 1: porta de aplicação, adaptador HMAC, migração V007, testes e documentação final concluídos.

## Aprendizados do Loop

- O campo de documento já era tratado como sinal de completude; a V1 pode preservar esse sinal sem armazenar o documento em claro.
- OTP e refresh token ainda não têm fluxo real, então a entrega correta para WLT-013 é fixar a fronteira de proteção agora e obrigar as histórias de autenticação a usarem essa porta.

## Evidências Finais

- `make backend-unit-test`: PASS, 94 testes, cobertura JaCoCo aprovada.
- `make backend-static-analysis`: PASS, 0 violações Checkstyle.
- `make backend-integration-test`: PASS, 94 unitários + 1 integração, Flyway aplicado até v007.
- `make mobile-static-analysis`: PASS.
- `make mobile-unit-test`: PASS, 99.51% de cobertura unitária mobile.
- `make mobile-screen-test`: PASS, 22 testes de tela/widget.
- `make mobile-integration-test`: N/A por ausência de Android Emulator, iOS Simulator ou Chrome.
- `make functional-test`: N/A por ausência de cenários funcionais reais.
- Revisão de segurança local: dados sensíveis não foram adicionados a logs e CPF/CNPJ não é mais persistido em claro após V007.
