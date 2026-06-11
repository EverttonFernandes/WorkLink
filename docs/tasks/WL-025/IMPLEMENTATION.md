---
task_key: WL-025
title: Autenticacao propria por email e senha
phase: PLANNED
loop_iteration: 0
official_order: 62
version_suggestion: MINOR
progress_file: docs/tasks/WL-025/progress.txt
exit_bar:
  acceptance_criteria: PENDING
  clean_code: PENDING
  lint: PENDING
  unit_tests: PENDING
  integration_tests: PENDING
  func_tests: PENDING
  mobile_tests: PENDING
  coverage: PENDING
  sre_review: PENDING
  security_review: PENDING
  architecture_review: PENDING
  final_review: PENDING
  documentation: PASS
  kanban_updated: PASS
  git_commit: PENDING
  semantic_tag: PENDING
correction_queue: []
metrics:
  files_changed: 0
  tests_run: []
  ci_run: null
---

# Plano de Execucao — WL-025

## Contexto

O canal principal atual depende de telefone e codigo. Para reduzir custo e dependencia de provedores no lancamento, o
Profissional Perto adotara autenticacao propria por email e senha. Nome completo e celular continuam no cadastro, enquanto
Google, Facebook, WhatsApp Business, SMS e OTP permanecem desativados para evolucao posterior.

## Decisoes fechadas

- Login principal: email e senha.
- Cadastro: nome completo, celular, email, senha, confirmacao de senha e aceite legal.
- Celular inicialmente nao verificado.
- Navegacao e descoberta continuam anonimas.
- Login exigido antes de contato e acoes sensiveis.
- Canais externos ficam ocultos e desligados por feature flag.
- A tela existente sera adaptada sem redesenho da identidade visual.
- A recuperacao de senha faz parte da entrega minima.

## Fases

### Fase 1 — Contratos e seguranca

- [ ] Mapear contratos atuais de OTP, tokens, contas e perfis.
- [ ] Definir modelo de credencial local e migracao compativel.
- [ ] Definir hash de senha, politica de senha, rate limit e auditoria.
- [ ] Definir recuperacao de senha sem enumeracao de usuarios.
- [ ] Definir feature flags dos canais presentes e futuros.

### Fase 2 — Backend

- [ ] Implementar cadastro local.
- [ ] Implementar login local.
- [ ] Implementar recuperacao/redefinicao.
- [ ] Integrar sessao, refresh, logout e revogacao.
- [ ] Criar migrations e adapters.
- [ ] Criar testes unitarios e integracao.

### Fase 3 — Mobile e UX/UI

- [ ] Criar matriz de aderencia ao prototipo de autenticacao.
- [ ] Adaptar state/controller/service/gateway.
- [ ] Adaptar login, cadastro e recuperacao mantendo o design atual.
- [ ] Ocultar canais externos desativados.
- [ ] Atualizar widget tests, integracao, preview e goldens.

### Fase 4 — Funcional e operacao

- [ ] Atualizar massa e specs funcionais.
- [ ] Validar cadastro e login contra backend real.
- [ ] Validar protecao contra abuso e logs.
- [ ] Documentar configuracao, recuperacao e rollback.

### Fase 5 — Exit Bar

- [ ] QA funcional e visual.
- [ ] Revisao de seguranca e privacidade.
- [ ] Revisao SRE.
- [ ] Revisao de arquitetura.
- [ ] Final Reviewer.
- [ ] Documentacao de entrega, commit e tag semantica.

## Validacoes planejadas

- Analise estatica backend e mobile.
- Testes unitarios backend com gate de cobertura.
- Testes unitarios mobile com gate de cobertura.
- Testes de integracao backend e mobile.
- Testes de widget e goldens.
- Testes funcionais E2E de cadastro, login, logout e recuperacao.
- Auditoria de logs e secrets.
- Security Guardian sobre o diff final.

## Riscos

- Conta existente baseada somente em telefone exigir estrategia de migracao.
- Recuperacao de senha depender de email transacional configurado.
- Celular nao verificado ser confundido com sinal de confianca.
- Rate limit insuficiente permitir brute force ou credential stuffing.
- Alteracao de campos provocar regressao visual no prototipo homologado.

## Bloqueios conhecidos

- WLT-037 precisa fornecer backend cloud antes da validacao de loja.
- Provedor de email transacional para recuperacao precisa ser escolhido antes da producao, ainda que use free tier.
- RF16/RF17 permanecem como requisito futuro de verificacao e nao devem ser apagados.
