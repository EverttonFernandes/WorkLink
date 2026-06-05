---
task_key: WLT-036
title: Contas das lojas e requisitos de publicacao
phase: READY_TO_CLOSE
loop_iteration: 2
official_order: 60
version_suggestion: MINOR
progress_file: docs/tasks/WLT-036/progress.txt
exit_bar:
  acceptance_criteria: PASS
  clean_code: N/A
  lint: N/A
  unit_tests: N/A
  integration_tests: N/A
  func_tests: N/A
  mobile_tests: N/A
  coverage: N/A
  sre_review: PASS
  security_review: PASS
  architecture_review: PASS
  final_review: PASS
  documentation: PASS
  kanban_updated: PASS
  git_commit: PENDING
  semantic_tag: PENDING
correction_queue: []
metrics:
  files_changed: 11
  tests_run:
    - "git diff --check: PASS"
    - "make mobile-signing-governance: PASS"
  ci_run: null
---

# Plano de Execucao - WLT-036

## Contexto

A estrategia oficial do WorkLink passa a ser publicar aplicativo mobile nas lojas, com Play Store como primeira loja e
App Store na sequencia. Esta historia prepara a base cadastral, documental, legal e operacional antes de gerar builds de
loja.

## Decisao de Produto

- O foco principal e aplicativo nas lojas, nao web/PWA.
- Play Store vem primeiro por menor custo e menor burocracia inicial.
- Apple App Store continua no plano, mas depende de conta Apple Developer e TestFlight.
- A loja distribui o app, mas nao substitui backend, banco, autenticação, mensageria ou suporte.
- Publicacao publica fica bloqueada ate API cloud, autenticação real e politica de privacidade estarem prontos.
- Como a conta pessoal da Play Console sera nova, o plano deve considerar teste fechado com pelo menos 12 testers por 14
  dias continuos antes de solicitar acesso a producao.

## Escopo

1. Documentar passo a passo manual da Play Console para conta pessoal.
2. Criar checklist de ficha da loja Android.
3. Criar checklist de App Store Connect/TestFlight para a etapa iOS.
4. Preparar rascunho de metadados publicos do WorkLink.
5. Mapear declaracoes de privacidade, Data Safety e dados de seguranca.
6. Registrar pendencias manuais do Everton em `docs/operacao/`.
7. Atualizar entrega e Kanban quando os artefatos estiverem prontos.

## Criterios de Aceite

- [x] Conta Google Play Console criada ou caminho manual documentado.
- [x] Decisao sobre Apple Developer Program documentada.
- [x] Checklist de publicacao Android criado.
- [x] Checklist de publicacao iOS criado.
- [x] Politica de privacidade inicial planejada.
- [x] Assets minimos de loja listados.
- [x] Pendencias manuais do Everton registradas em `docs/operacao/`.

## Estrategia de Validacao

- Validar documentacao com fontes oficiais atuais da Google Play e Apple Developer.
- Rodar `git diff --check`.
- Rodar checagem de secrets mobile se algum arquivo de operacao citar assinatura/lojas.

## Fontes Oficiais Consultadas

- Google Play Console Help: criar e configurar app.
- Google Play Console Help: setup pelo dashboard.
- Google Play Console Help: Data Safety.
- Google Play User Data Policy.
- Apple Developer Program: enrollment e requisitos.
- Apple Developer Program: beneficios, TestFlight e distribuicao.

## Log de Iteracoes

- Iteracao 1: plano criado manualmente porque WLT-036 ainda nao tinha `docs/tasks/WLT-036`.
- Iteracao 1: runbooks e checklists criados para Play Console, App Store Connect, metadados de loja e rascunho de
  politica de privacidade. A conta Google Play Console depende de acao manual do Everton, mas o criterio da WLT-036
  aceita conta criada ou caminho manual documentado.
- Iteracao 1: validacoes `git diff --check` e `make mobile-signing-governance` passaram.
- Iteracao 2: WLT-036 preparada para fechamento. A estrategia de loja esta documentada e o app permanece bloqueado para
  producao ate WLT-037, WLT-038, WLT-039 e WLT-041.
