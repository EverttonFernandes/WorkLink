---
task_key: WLT-038
title: Mensageria de autenticacao real e controle de custos
phase: IN_PROGRESS
loop_iteration: 1
official_order: 63
version_suggestion: MINOR
progress_file: docs/tasks/WLT-038/progress.txt
func_tests_detected: true
func_tests_path: functional-tests/src/specs
func_tests_framework: Jest
exit_bar:
  acceptance_criteria: PASS
  clean_code: PASS
  lint: PASS
  unit_tests: PASS
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
  files_changed: 13
  tests_run:
    - "docker compose --env-file .env run --rm backend-tests mvn -q test -Dtest=AuthenticationUseCaseTest,AuthenticationControllerTest,AuthenticationOtpDeliveryAdapterTest,WorkLinkUseCaseConfigurationTest: PASS"
    - "docker compose --env-file .env run --rm backend-tests mvn -q -DskipITs test: PASS"
    - "git diff --check: PASS"
  ci_run: null
---

# Plano de Execucao - WLT-038

## Contexto

A WL-025 consolidou autenticacao propria por email e senha como trilha principal do aplicativo. A WLT-038 existe para
evitar dois riscos ao mesmo tempo:

1. o produto publicar nas lojas com dependencias pagas parcialmente ligadas e mal controladas;
2. o codigo perder a capacidade de evoluir futuramente para OTP real, email OTP ou login social quando isso fizer sentido.

Hoje o backend ja possui:

- `local-authentication-enabled` e `otp-authentication-enabled`;
- flags para `sms`, `whatsapp`, `google`, `microsoft` e `facebook`;
- adapter `disabled` e adapter SMTP para recuperacao de senha;
- suporte de teste para exposicao controlada do token de recuperacao;
- fluxo OTP ainda compilavel, mas desligado por padrao.

## Decisao de Produto/SRE/Security

- O login proprio continua sendo o unico canal principal do lancamento.
- OTP real, WhatsApp Business, Google, Microsoft e Facebook permanecem em stand by.
- WhatsApp deep link para contato com profissional continua liberado porque nao gera custo para o WorkLink.
- Nenhum canal pago deve ser ativado sem:
  - feature flag dedicada;
  - secrets reais fora do Git;
  - sandbox funcional ou fake adapter homologado;
  - teto mensal documentado;
  - rate limit e trilha de auditoria sem vazar OTP/token.

## Descoberta funcional e tecnica

- Suite funcional detectada em `functional-tests/src/specs`.
- O backend ja injeta flags de autenticacao em `WorkLinkUseCaseConfiguration`.
- O fluxo de recuperacao de senha ja diferencia `disabled`, `smtp` e `test-support`.
- Ainda nao existe contrato unificado para mensageria autenticadora com modo `sandbox` e politica de custo/limite.
- Ainda nao existe documento consolidado que responda quais acoes exigem verificacao forte antes das lojas.

## Restricoes pragmaticas do Pattern Enforcer

- Preservar a arquitetura hexagonal existente.
- Nao introduzir SDK real de provedor externo sem necessidade imediata.
- Preferir adapters fake/sandbox e contratos pequenos antes de qualquer integracao paga.
- Nao deslocar a UX principal da WL-025 para OTP/social nesta historia.
- Nao expor OTP, token, segredo, email reset ou numero bruto em logs fora do estritamente necessario.

## Fases

### Fase 1 - Planejamento e contrato operacional

- [ ] Mapear todos os canais atuais e futuros no backend/mobile/documentacao.
- [ ] Definir matriz de custo, risco, ativacao e dependencias por canal.
- [ ] Definir quais acoes do produto exigem verificacao forte e quais permanecem liberadas com login proprio.

### Fase 2 - Backend e configuracao

- [ ] Introduzir contrato explicito para entrega/sandbox de OTP/autenticacao real.
- [ ] Implementar adapter fake/sandbox para ambiente controlado.
- [ ] Centralizar feature flags e modos de entrega para evitar ativacao acidental.
- [ ] Implementar limites anti-abuso minimos e eventos de auditoria sem PII sensivel em claro.

### Fase 3 - Testes e gates

- [ ] Criar/ajustar testes unitarios e de integracao para sucesso, falha, limite e reenvio.
- [ ] Verificar compatibilidade com a suite funcional existente.
- [ ] Revisar impactos de seguranca, observabilidade e operacao.

### Fase 4 - Documentacao e saida

- [ ] Documentar segredos, sandbox, provedores futuros e teto de custo.
- [ ] Atualizar entrega da historia.
- [ ] Fechar Kanban, commit e tag quando a Exit Bar estiver verde.

## Validacoes planejadas

- `mvn -q test`
- `mvn -q verify`
- `git diff --check`
- busca local por exposicao acidental de OTP/token em logs e respostas
- revalidacao dirigida da suite funcional se o contrato HTTP mudar

## Riscos

- Ativar OTP real cedo demais e abrir custo recorrente sem retorno.
- Criar uma API de mensageria abstrata demais para a necessidade atual.
- Misturar verificacao forte com login cotidiano e piorar UX sem necessidade.
- Quebrar a recuperacao de senha entregue na WL-025 ao generalizar demais o envio.

## Bloqueios manuais esperados

- Escolha final de provedor pago, se houver, continua manual e posterior.
- Secrets reais de SMS/WhatsApp/social nao devem entrar nesta historia.
- Orcamento mensal e aprovacao de produto para ativacao real dependem do Everton.

## Log de Iteracoes

- Iteracao 1: WLT-038 iniciada como proxima historia elegivel apos o fechamento versionado da WL-025 (`v0.54.0`).
- Iteracao 1: bootstrap manual executado porque o workflow `.agents/workflows/start-work.md` nao existe mais no repo; o
  fluxo equivalente foi reconstruido via `ralph-loop`, `product-manager`, `execution-plan` e leitura do Kanban.
- Iteracao 1: mapeado que o backend ja possui flags para OTP/social, adapter SMTP para recuperacao de senha e modo
  `disabled` por padrao, reduzindo o escopo do primeiro incremento.
- Iteracao 1: criado o contrato `DeliverAuthenticationOtpPort` com adapters `disabled` e `sandbox`.
- Iteracao 1: o request de OTP passou a respeitar canais realmente habilitados, validar canal solicitado e aplicar
  cooldown de reenvio por telefone.
- Iteracao 1: documentado custo zero no lancamento, modo sandbox e matriz de acoes com/sem verificacao forte em
  `docs/operacao/autenticacao-mensageria-custos.md`.
- Iteracao 1: revalidacao ampla de testes unitarios backend passou usando a stack Docker do projeto.

## Hipotese de saida desta janela

Entregar a infraestrutura de configuracao e sandbox que permita manter canais externos preparados, seguros e desligados,
sem depender ainda de provedor pago real.

## Conclusao desta historia

A WLT-038 pode ser fechada tecnicamente sem depender de acao manual imediata, porque o objetivo era preparar, limitar e
documentar os canais opcionais, nao ativa-los em producao.
