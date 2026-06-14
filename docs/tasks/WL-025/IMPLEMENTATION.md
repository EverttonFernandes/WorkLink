---
task_key: WL-025
title: Autenticacao propria por email e senha
phase: IN_PROGRESS
loop_iteration: 4
official_order: 62
version_suggestion: MINOR
progress_file: docs/tasks/WL-025/progress.txt
func_tests_detected: true
func_tests_path: functional-tests/src/specs
func_tests_framework: Jest
exit_bar:
  acceptance_criteria: PASS
  clean_code: PASS
  lint: PASS
  unit_tests: PASS
  integration_tests: PASS
  func_tests: PASS
  mobile_tests: PASS
  coverage: PASS
  sre_review: PENDING
  security_review: PENDING
  architecture_review: PENDING
  final_review: PENDING
  documentation: PASS
  kanban_updated: PASS
  git_commit: PENDING
  semantic_tag: PENDING
correction_queue:
  - id: WL-025-CQ-001
    severity: LOW
    status: RESOLVED
    description: Testes mobile revalidados com sucesso apos a recuperacao do Docker Desktop e ajuste do teste de sucesso autenticado.
metrics:
  files_changed: 0
  tests_run:
    - backend: mvn -q test
    - backend: mvn -q verify
    - backend: jacoco instructions 95.18 percent, lines 95.93 percent
    - functional: jest --runInBand (17 specs PASS)
    - mobile: flutter analyze PASS
    - mobile: flutter test test/widget/visual/wlt_030_visual_evidence_test.dart --update-goldens PASS
    - mobile: flutter test test/unit PASS
    - mobile: flutter test test/widget PASS
  ci_run: null
---

# Plano de Execucao — WL-025

## Contexto

O canal principal atual depende de telefone e codigo. Para reduzir custo e dependencia de provedores no lancamento, o
Profissional Perto adotara autenticacao propria por email e senha. Nome completo e celular continuam no cadastro, enquanto
Google/Gmail, Microsoft/Outlook, Facebook, WhatsApp Business, SMS e OTP permanecem desativados para evolucao posterior.

## Decisoes fechadas

- Login principal: email e senha.
- Cadastro: nome completo, celular, email, senha, confirmacao de senha e aceite legal.
- Celular inicialmente nao verificado.
- Navegacao e descoberta continuam anonimas.
- Login exigido antes de contato e acoes sensiveis.
- Canais externos ficam ocultos e desligados por feature flag.
- A tela existente sera adaptada sem redesenho da identidade visual.
- A recuperacao de senha faz parte da entrega minima.

## Descoberta funcional

- Suite funcional detectada em `functional-tests/src/specs`.
- Framework: Jest/Node, executado pelo target `make functional-test`.
- O fluxo existente autentica por OTP e deve ganhar cadastro/login local sem remover a cobertura legada.
- Testes de integracao backend continuam separados via Maven Failsafe (`*IntegrationTest.java`).

## Restricoes pragmaticas do Pattern Enforcer

- Preservar a arquitetura hexagonal existente: dominio sem Spring, casos de uso na aplicacao e JDBC na infraestrutura.
- Reutilizar a emissao, rotacao e revogacao atuais de access/refresh tokens.
- Adicionar credencial local de forma compativel com contas antigas baseadas apenas em telefone.
- Nao introduzir SDK social, provedor pago ou MFA nesta historia.
- Nao registrar senha, hash, token de sessao ou token de recuperacao.
- Manter o fluxo OTP compilavel e testado, mas oculto/desabilitado por configuracao no produto.
- Preferir portas pequenas e modelos coesos; evitar um framework completo de identidade enquanto o dominio nao o exige.

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

- WLT-037 foi formalmente replanejada para o backlog por depender de provisionamento e credenciais manuais. Ela continua
  obrigatoria antes da validacao de loja, mas nao bloqueia a implementacao e os testes locais da WL-025.
- Provedor de email transacional para recuperacao precisa ser escolhido antes da producao, ainda que use free tier.
- RF16/RF17 permanecem como requisito futuro de verificacao e nao devem ser apagados.
- A integracao WSL/Docker Desktop foi instavel durante a iteracao, mas voltou a permitir a revalidacao final dos testes
  mobile. O incidente permanece apenas como nota operacional para futuras execucoes.

## Log de iteracoes

### Iteracao 3

- Corrigido takeover potencial de conta legada: o cadastro publico nao vincula senha a telefone preexistente no legado.
- Restrito o suporte de token de recuperacao a `local/test`, com `default false` no `compose.yml`.
- Introduzido adapter SMTP opcional para recuperacao de senha em producao.
- Tornados atomicos o consumo do token de recuperacao e a revogacao do refresh token.
- Atualizados `Makefile`, template cloud e documentacao operacional para refletir o novo contrato.
- Revalidacao automatizada ficou bloqueada por indisponibilidade do daemon Docker no ambiente atual.

### Iteracao 4

- `mvn -q test` e `mvn -q verify` ficaram verdes para o backend, com Failsafe validando a migracao `V022`.
- Cobertura backend revalidada acima do gate oficial: 95.18 por cento em instrucoes e 95.93 por cento em linhas.
- Suite funcional E2E passou integralmente com 17 testes, incluindo cadastro local, login, refresh, logout e recuperacao.
- Encontrado e corrigido um problema operacional no `Makefile`: os alvos de validacao full-stack nao forçavam rebuild do
  `worklink-api`, permitindo testes contra imagem stale e gerando falso 404 no endpoint de suporte.
- `flutter analyze`, `flutter test test/widget/visual/wlt_030_visual_evidence_test.dart --update-goldens` e
  `flutter test test/unit` passaram antes do novo colapso do daemon/guest-services do Docker Desktop.
- A revalidacao final de `flutter test test/widget` permaneceu pendente por falha externa de montagem WSL/Docker, nao por
  erro de dominio ou de compilacao identificado na historia.

### Iteracao 5

- Docker Desktop voltou a responder e a suite `flutter test test/widget` passou integralmente.
- O unico ajuste adicional necessario foi alinhar o teste de sucesso autenticado ao texto atual da UI (`Conta autenticada`).
- Com isso, backend, funcional, goldens, testes unitarios mobile e widgets ficaram verdes na historia.
