---
task_key: WLT-014
title: "Storage seguro de arquivos"
story_path: "docs/jira-pessoal/historias-tecnicas/WLT-014-storage-seguro-arquivos.md"
official_order: 15
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
  changed_files: 20
  risk_level: MEDIUM
release:
  commit_hash: "verificado no fechamento via git rev-parse HEAD"
  semantic_tag: v0.15.0
correction_queue: []
cycle_history:
  - iteration: 0
    phase: EXECUTION
    summary: "WLT-014 iniciada como próxima história oficial do Kanban unificado."
    evidence:
      - "docs/jira-pessoal/historias-tecnicas/WLT-014-storage-seguro-arquivos.md"
  - iteration: 1
    phase: DONE
    summary: "Storage seguro entregue com dominio isolado, metadados persistidos, validacoes de allow-list e API sem exposicao de chave interna."
    evidence:
      - "make backend-static-analysis: PASS"
      - "make backend-unit-test: PASS, 81 testes, JaCoCo >= 95%"
      - "make backend-integration-test: PASS"
      - "make mobile-static-analysis: PASS"
      - "make mobile-unit-test: PASS, cobertura 100.00%"
      - "make mobile-screen-test: PASS"
      - "make mobile-integration-test: N/A por ausencia de emulador/simulador/Chrome"
      - "make functional-test: N/A sem cenarios reais"
      - "git diff --check: PASS"
      - "scan de segredos: apenas referencia parametrizada ${WORKLINK_POSTGRES_PASSWORD}"
---

# WLT-014 — Storage seguro de arquivos

## Plano BDD/TDD

- Dado um arquivo de foto com tipo e extensão permitidos, quando preparar upload, então deve gerar identificador e chave interna aleatória.
- Dado uma evidência de denúncia, quando preparar upload, então deve ser confidencial e não pública.
- Dado um nome original perigoso, quando preparar upload, então deve bloquear extensão não permitida.
- Dado um arquivo acima do limite, quando preparar upload, então deve bloquear por tamanho.
- Dado um arquivo válido, quando persistir metadados, então o banco deve salvar apenas metadados e não conteúdo binário.
- Dado a API de preparação, quando chamada com metadados válidos, então deve retornar metadados públicos sem expor caminho interno.

## Decisões

- A fundação não usa SDK S3 nesta entrega para preservar Ports and Adapters e evitar acoplamento prematuro.
- O objeto real será enviado ao storage por adapter futuro; esta entrega prepara metadados, validações e chave interna.
- O endpoint retorna identificador e política de acesso, mas não retorna `storageObjectKey`.
- Anexos de denúncia já nascem `CONFIDENTIAL`; autorização/auditoria real será concluída nas histórias de segurança.

## Restrições Pragmáticas e Padrões

- Domínio não pode depender de Spring, JDBC, MinIO ou S3.
- Banco armazena metadados, nunca bytes do arquivo.
- Chave interna não deve usar nome original do arquivo.
- Validações devem ser allow-list de tipos/extensões, não deny-list frágil.

## Log de Iterações

- Iteração 0: plano criado, escopo limitado à fundação segura de metadados e preparação de upload.
- Iteração 1: testes BDD/TDD de domínio, caso de uso, API e adapter guiaram a implementação; gates finais aprovados.

## Aprendizados do Loop

- MinIO e variáveis de storage já existem no ambiente local; o incremento desta história deve endurecer o contrato interno antes do upload real.
- A fronteira HTTP e o caso de uso aceitam propósito como texto e convertem para domínio na aplicação, evitando acoplamento do contrato externo ao enum de domínio.
