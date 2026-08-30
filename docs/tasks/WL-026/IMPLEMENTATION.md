---
task_key: WL-026
title: Navegacao anonima com autenticacao obrigatoria antes do detalhe
phase: DONE
loop_iteration: 4
official_order: 65
version_suggestion: MINOR
progress_file: docs/tasks/WL-026/progress.txt
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
  sre_review: PASS
  security_review: PASS
  architecture_review: PASS
  final_review: PASS
  documentation: PASS
  kanban_updated: PASS
  git_commit: READY
  semantic_tag: READY
correction_queue:
  - id: WL-026-CQ-001
    severity: CRITICAL
    status: CLOSED
    origin: security
    description: Refresh token foi persistido em texto puro via shared_preferences, contrariando RNF de armazenamento seguro no app mobile.
  - id: WL-026-CQ-002
    severity: CRITICAL
    status: CLOSED
    origin: qa
    description: O backend publico ainda entrega os dados usados no perfil completo; separar resumo publico de descoberta e detalhe autenticado.
  - id: WL-026-CQ-003
    severity: HIGH
    status: CLOSED
    origin: qa
    description: Cobrir sessao corrompida, refresh recusado, logout, sessao expirada e retorno pos-cadastro/login.
  - id: WL-026-CQ-004
    severity: HIGH
    status: CLOSED
    origin: mobile-frontend
    description: Corrigir microcopy divergente e produzir evidencias visuais atuais do card anonimo, gate e retorno pos-login.
  - id: WL-026-CQ-005
    severity: MEDIUM
    status: CLOSED
    origin: qa
    description: Nao tratar todo HTTP 403 como sessao expirada; apenas 401 deve limpar autenticacao automaticamente.
metrics:
  files_changed: 53
  tests_run:
    - backend: WORKLINK_POSTGRES_PORT=55432 make backend-static-analysis PASS
    - backend: WORKLINK_POSTGRES_PORT=55432 make backend-unit-test PASS 350 testes
    - backend: WORKLINK_POSTGRES_PORT=55432 make backend-integration-test PASS
    - mobile: make mobile-static-analysis PASS
    - mobile: make mobile-unit-test PASS 172 testes cobertura 95.35%
    - mobile: make mobile-screen-test PASS 89 testes
    - mobile: WORKLINK_POSTGRES_PORT=55432 make mobile-integration-test PASS contrato Dart; integration_test N/A sem Android/iOS/Chrome no container
    - functional: WORKLINK_POSTGRES_PORT=55432 make functional-test PASS 21 cenarios reais
  ci_run: null
---

# Plano de Execucao — WL-026

## Contexto

Depois da `WL-025`, a autenticacao principal ja existe por email e senha. A `WL-026` reposiciona o gate de produto:
manter descoberta e busca publicas, mas exigir autenticacao antes de abrir o detalhe do profissional.

## Decisoes fechadas

- descoberta, filtros e listagem continuam anonimos;
- o app deve deixar claro que explorar sem conta e permitido;
- o detalhe do profissional passa a exigir autenticacao;
- perfil do cliente, profissionais salvos e contato continuam protegidos;
- apos login ou cadastro, o app deve retomar o detalhe originalmente solicitado;
- a sessao precisa ser reaproveitada ao reabrir o app;
- o contrato visual do gate continua vinculado ao prototipo de autenticacao existente.

## Descoberta funcional

- nao existe hoje um endpoint separado de detalhe do profissional; o mobile monta o detalhe a partir de dados publicos ja
  carregados na home;
- por isso, o fechamento inicial da historia sera feito com guarda de navegacao e protecao dos recursos autenticados;
- os endpoints autenticados ja existentes continuam servindo como linha de defesa para perfil do cliente, salvos e contato.

## Restricoes pragmaticas do Pattern Enforcer

- preservar a navegacao atual e evitar reescrever a arquitetura do app;
- reutilizar `CustomerAuthenticationScreen` e `CustomerAuthenticationController`;
- manter o impacto concentrado no mobile e na persistencia minima de sessao;
- nao introduzir login social, MFA, biometria ou backend paralelo de detalhe nesta historia;
- manter os nomes, textos e testes legiveis e explicitos.

## Fases

### Fase 1 — Bootstrap da historia

- [ ] Registrar artefatos locais da `WL-026`.
- [ ] Mapear fluxo atual de descoberta, detalhe e autenticacao.
- [ ] Confirmar os limites entre gate visual no mobile e contratos backend existentes.

### Fase 2 — Sessao e navegacao

- [ ] Persistir sessao autenticada para reaproveitamento ao reabrir o app.
- [ ] Restaurar sessao durante o bootstrap do aplicativo.
- [ ] Criar helper unico para exigir autenticacao e retomar a acao protegida.
- [ ] Bloquear abertura anonima do detalhe do profissional.

### Fase 3 — UX e aderencia visual

- [ ] Exibir CTA claro de explorar sem login, entrar e criar conta agora.
- [ ] Ajustar microcopy da autenticacao para refletir o novo gate no detalhe.
- [ ] Preservar descoberta publica sem esconder profissionais da listagem.

### Fase 4 — Qualidade

- [ ] Atualizar testes unitarios de gateway para sessao persistida.
- [ ] Atualizar widget tests do fluxo principal.
- [ ] Rodar analise estatica e suites mobile aplicaveis.

## Validacoes planejadas

- `make mobile-static-analysis`
- `flutter test` direcionado para `test/unit/app/worklink_application_gateway_test.dart`
- `flutter test` direcionado para `test/widget/worklink_app_widget_test.dart`
- ampliacao para suites adicionais se o diff tocar mais contratos do que o previsto

## Riscos

- persistencia local de sessao precisa ser simples e confiavel para nao quebrar preview nem testes;
- sem endpoint dedicado de detalhe, a blindagem principal desta historia fica no fluxo mobile;
- mudanca de jornada pode invalidar expectativas de testes antigos do perfil publico.

## Log de iteracoes

### Iteracao 0

- Historia bootstrapada manualmente porque o workflow `.agents/workflows/start-work.md` nao esta presente neste checkout.
- Confirmado que `WL-026` e a proxima historia oficial em `To Do`.
- Confirmado que o detalhe do profissional e atualmente montado no mobile a partir da home publica.

### Iteracao 1

- Implementada persistencia minima de sessao com restauracao no bootstrap do app.
- Adicionado gate de autenticacao antes da abertura do detalhe do profissional.
- Adicionada faixa inicial da jornada anonima com CTAs claros para entrar, criar conta ou continuar sem login.
- Ajustado retorno pos-login para abrir automaticamente o perfil solicitado.
- Reforcado tratamento de expiracao de sessao para recursos protegidos do cliente.
- `flutter analyze`, unitarios de gateway e widgets do fluxo principal passaram no container.
- A suite funcional real via `make functional-test` passou integralmente com 17 testes.
- Teste de integracao mobile ficou `N/A` nesta janela porque o projeto nao possui target desktop gerado e nao havia device Android/iOS conectado ao container.

### Iteracao 2

- A revisao normativa de seguranca identificou que `shared_preferences` nao atende ao requisito de armazenamento seguro
  para refresh token.
- Aberta a correcao critica `WL-026-CQ-001`.
- A saida do loop foi bloqueada ate substituir a persistencia por armazenamento seguro e limitar os dados persistidos ao
  minimo necessario para restaurar a sessao.

### Iteracao 3

- QA e Mobile Front-end Specialist executaram revisoes independentes.
- QA identificou que o endpoint publico de profissionais ainda expõe dados suficientes para reconstruir o detalhe,
  tornando o gate apenas visual.
- Os gates de testes foram reabertos como `FAIL` ate existir contrato autenticado de detalhe, cobertura de sessao e
  evidencias visuais atuais.
- O especialista mobile reprovou microcopy antiga, texto sem acento e ausencia de screenshots/goldens da jornada nova.
- Aberta correcao para diferenciar `401` de `403`, evitando logout indevido por simples falta de permissao.

### Iteracao 4

- Corrigida a persistencia de sessao no mobile para armazenar somente refresh token e expiracao em
  `flutter_secure_storage` com encrypted shared preferences no Android.
- Separado o contrato de descoberta publica do contrato de detalhe autenticado no backend.
- Adicionado endpoint autenticado para detalhe do profissional e endpoint operacional para registrar tentativa anonima de
  acesso ao detalhe.
- Ajustado o mobile para carregar dados completos somente apos autenticacao e diferenciar `401` de `403`.
- Atualizadas evidencias visuais/goldens da jornada anonima, gate de login e retorno ao perfil autenticado.
- Reexecutados os gates oficiais em Docker com sucesso:
  `backend-static-analysis`, `backend-unit-test`, `backend-integration-test`, `mobile-static-analysis`,
  `mobile-unit-test`, `mobile-screen-test`, `mobile-integration-test` e `functional-test`.
