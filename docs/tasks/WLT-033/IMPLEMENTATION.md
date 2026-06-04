---
task_key: WLT-033
title: Canal de confirmacao de codigo na autenticacao mobile
phase: READY_TO_CLOSE
loop_iteration: 2
official_order: 54
version_suggestion: PATCH
exit_bar:
  acceptance_criteria: PASS
  clean_code: PASS
  unit_tests: PASS
  widget_tests: PASS
  functional_tests: PASS
  mobile_frontend_review: PASS
  sre_review: PASS
  security_review: PASS
  architecture_review: PASS
  final_review: PASS
  documentation: PASS
  kanban_updated: PASS
  git_commit: PENDING
  semantic_tag: PENDING
correction_queue:
  - id: WLT-033-AUTH-001
    severity: CRITICAL
    status: RESOLVED
    description: "Remover ambiguidade do canal de verificacao, explicitando SMS, WhatsApp e email na UI, contrato e documentacao."
metrics:
  files_changed: 20
  tests_run:
    - "flutter test autenticacao/gateway/servico: PASS"
    - "mvn -Dtest=AuthenticationControllerTest,AuthenticationUseCaseTest test: PASS"
    - "make mobile-static-analysis: PASS"
    - "make backend-static-analysis: PASS"
    - "make mobile-unit-test: PASS, 159 testes, cobertura 95,23%"
    - "make mobile-screen-test: PASS, 75 testes"
    - "make backend-unit-test: PASS, 313 testes, Jacoco aprovado"
    - "make functional-test: PASS, 5 suites, 12 testes"
  ci_run: null
---

# Plano de Execucao - WLT-033

## Contexto

A WLT-033 corrige o debito `DTM-004`: a tela de autenticacao mobile indicava envio de codigo para telefone, sem deixar claro se o canal real era SMS, WhatsApp, email ou simulacao de homologacao.

## Decisao de Produto V1

- O identificador primario da conta cliente continua sendo o telefone celular.
- A V1 deve permitir escolha de canal de recebimento entre `SMS`, `WhatsApp` e `email`.
- Quando `email` for escolhido, a UI deve pedir um endereco de email antes de solicitar o codigo.
- Em homologacao, o envio pode ser simulado; a UI e a documentacao devem deixar isso honesto.
- O backend deve preservar resposta generica e nao vazar codigo OTP, mantendo LGPD e seguranca.

## Escopo

1. Registrar a decisao de produto e criterios de aceite.
2. Ajustar estado, controller e UI de autenticacao mobile para canal multicanal.
3. Ajustar contrato mobile/backend para transportar canal preferido e email opcional.
4. Atualizar testes unitarios/widget/servico/backend aplicaveis.
5. Atualizar documentacao de entrega, kanban, commit e tag PATCH.

## Criterios de Aceite

- [x] O canal de verificacao esta decidido e documentado.
- [x] A decisao explicita suporte a `SMS`, `WhatsApp` e `email`.
- [x] A UI informa o canal correto, sem ambiguidade.
- [x] O fluxo de homologacao deixa claro quando o envio e simulado.
- [x] QA, Seguranca e Final Reviewer aprovam o fluxo.

## Log de Iteracoes

- Iteracao 1: historia iniciada a partir do Kanban Oficial, preservando alteracoes preexistentes fora do escopo.
- Iteracao 1: implementado suporte multicanal no estado/controller/UI mobile, contrato HTTP mobile/backend e testes focados.
- Iteracao 2: QA aprovou analise estatica, unitarios mobile/backend, widgets/goldens e funcionais. SRE aprovou execucao reproduzivel via Docker apos reativar Docker Desktop. Seguranca aprovou resposta generica, ausencia de OTP na resposta, ausencia de secrets e minimizacao do email. Arquitetura aprovou mudanca pequena em contrato/use case/gateway sem novo provedor prematuro. Final Reviewer aprovou criterios de aceite e documentacao.
