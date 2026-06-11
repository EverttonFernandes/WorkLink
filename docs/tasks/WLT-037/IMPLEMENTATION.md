---
task_key: WLT-037
title: Backend cloud minimo para aplicativo nas lojas
phase: IN_PROGRESS
loop_iteration: 2
official_order: 61
version_suggestion: MINOR
progress_file: docs/tasks/WLT-037/progress.txt
exit_bar:
  acceptance_criteria: PENDING
  clean_code: PASS
  lint: PASS
  unit_tests: N/A
  integration_tests: N/A
  func_tests: N/A
  mobile_tests: N/A
  coverage: N/A
  sre_review: PASS
  security_review: PASS
  architecture_review: PASS
  final_review: FAIL
  documentation: PASS
  kanban_updated: PASS
  git_commit: PENDING
  semantic_tag: PENDING
correction_queue: []
metrics:
  files_changed: 11
  tests_run:
    - "sh -n scripts/run_cloud_database_migrations.sh: PASS"
    - "sh -n scripts/check_cloud_api_readiness.sh scripts/test_cloud_deployment_contract.sh: PASS"
    - "make -n cloud-db-migrate: PASS"
    - "make -n cloud-api-readiness-check WORKLINK_CLOUD_API_BASE_URL=https://api.example.com: PASS"
    - "make cloud-deployment-contract-test: PASS"
    - "git diff --check: PASS"
    - "make mobile-signing-governance: PASS"
    - "DOCKER=docker.exe make backend-image-build: PASS"
    - "DOCKER=docker.exe make api: PASS"
    - "curl -fsS http://localhost:8080/actuator/health/readiness: PASS"
    - "rg --pcre2 secret patterns no diff WLT-037: PASS, apenas referencias a variaveis sem valores"
    - "Security Guardian local sobre diff WLT-037: PASS, score 20"
  ci_run: null
---

# Plano de Execucao - WLT-037

## Contexto

O WorkLink publicado nas lojas precisa consumir uma API HTTPS estavel. O erro do APK `v0.49.0` mostrou que tunnel
temporario ou backend local nao servem para validacao de loja.

## Decisao de Produto/SRE

- A primeira infra deve priorizar custo zero enquanto o produto ainda esta validando tracao.
- Koyeb Free Instance + Supabase/Neon Free Postgres passa a ser a rota preferencial inicial.
- DigitalOcean passa a ser rota de upgrade quando houver uso real, receita ou instabilidade relevante no free tier.
- App Platform + PostgreSQL gerenciado e o caminho mais simples, mas pode ter custo maior.
- Droplet unica com Docker Compose e o caminho mais barato, mas aumenta responsabilidade operacional.
- Publicacao em loja permanece bloqueada ate existir URL HTTPS estavel e banco persistente.

## Escopo desta janela

1. Criar runbook de backend cloud para lojas.
2. Criar checklist de variaveis/secrets de producao controlada.
3. Criar app spec exemplo para DigitalOcean App Platform.
4. Criar procedimento reproduzivel de migrations cloud via Flyway Docker.
5. Criar gate local de readiness para a API cloud.
6. Criar teste de contrato offline para evitar deploy com placeholders/URLs instaveis.
7. Adicionar gate de contrato cloud na CI.
8. Documentar custo mensal tecnico minimo.
9. Atualizar Kanban para WLT-037 em andamento.

## Criterios de Aceite

- [ ] API responde em HTTPS estavel.
- [ ] PostgreSQL cloud conectado e com migrations aplicadas.
- [ ] Health/readiness aprovados.
- [ ] App mobile consegue carregar dados reais da API cloud.
- [x] Secrets não são versionados.
- [x] Custo mensal inicial documentado.
- [x] Procedimento de recuperação básica documentado.

## Validacoes Planejadas

- `sh -n scripts/run_cloud_database_migrations.sh`
- `sh -n scripts/check_cloud_api_readiness.sh scripts/test_cloud_deployment_contract.sh`
- `make -n cloud-db-migrate`
- `make -n cloud-api-readiness-check WORKLINK_CLOUD_API_BASE_URL=https://api.example.com`
- `make cloud-deployment-contract-test`
- `make backend-image-build`
- `DOCKER=docker.exe make api`
- `curl -fsS http://localhost:8080/actuator/health/readiness`
- `git diff --check`
- `make mobile-signing-governance`

## Bloqueios Manuais Esperados

- Conta cloud com billing ativo.
- Banco PostgreSQL criado.
- URL publica HTTPS ou dominio.
- Secrets reais configurados fora do Git.

## Log de Iteracoes

- Iteracao 1: WLT-037 iniciada apos fechamento versionado da WLT-036 (`v0.53.0`).
- Iteracao 1: criado runbook cloud, app spec exemplo DigitalOcean, target `cloud-db-migrate` e script Flyway Docker.
- Iteracao 1: validacoes leves e build da imagem da API passaram; fechamento permanece bloqueado por ambiente cloud real.
- Iteracao 1: criado gate `cloud-api-readiness-check` para rejeitar HTTP, localhost, `127.0.0.1` e tunnels temporarios.
- Iteracao 1: criado `cloud-deployment-contract-test` para validar contrato offline de deploy/migrations.
- Iteracao 1: auditoria local de seguranca aprovada; placeholders `CHANGE_ME` existem apenas em arquivo `.example` e nao
  representam secrets reais.
- Iteracao 1: Final Reviewer permanece FAIL para fechamento porque os criterios de API HTTPS, PostgreSQL cloud,
  migrations cloud e teste mobile contra URL cloud dependem de provisionamento real.
- Iteracao 2: API local subida via Docker Desktop e readiness local validado como `UP`.
- Iteracao 2: CI passou a validar contrato de deploy cloud em job dedicado.
- Iteracao 2: custo minimo DigitalOcean documentado: App Platform `apps-s-1vcpu-0.5gb` por US$ 5/mes + PostgreSQL
  development database 512 MB por US$ 7/mes, total tecnico minimo de US$ 12/mes antes de impostos/cambio/trafego extra.
- Iteracao 2: procedimento de recuperacao basica documentado para falha de deploy, migration, banco e app publicado.
- Iteracao 2: checklist manual DigitalOcean criado para guiar Everton no provisionamento sem expor secrets no Git.
- Iteracao 2: busca local de secrets apontou apenas referencias a variaveis sem valores reais (`WORKLINK_CLOUD_DATABASE_PASSWORD`
  e `SONAR_TOKEN`).
- Iteracao 3: decisao de produto mudou para free-first. Rota preferencial atualizada para Koyeb Free Instance com
  Supabase/Neon Free Postgres, mantendo DigitalOcean como upgrade futuro.

## Bloqueio Atual

A historia nao pode ser fechada sem acao manual de provedor:

1. criar/selecionar ambiente cloud gratuito;
2. criar PostgreSQL persistente;
3. configurar secrets reais fora do Git;
4. expor API em URL HTTPS estavel;
5. executar `make cloud-db-migrate`;
6. executar `make cloud-api-readiness-check WORKLINK_CLOUD_API_BASE_URL=https://...`;
7. gerar build mobile apontando para a API cloud e validar carga de dados reais.
