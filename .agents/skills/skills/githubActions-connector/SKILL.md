---
name: githubActions-connector
description: Monitora workflows no GitHub Actions, verifica status, dispara execuções e analisa logs de falha da pipeline de CI/CD.
required_env: ["GITHUB_TOKEN"]
max_lines: 300
---

# Skill: GitHub Actions Connector

Use esta skill para investigar e operar CI/CD do WorkLink no GitHub Actions com evidência objetiva.

## Fontes Do Projeto

- `.github/workflows/ci.yml`
- `.github/workflows/`
- `Makefile`
- `docs/tasks/`
- `docs/release/release-mobile.md`
- `docs/jira-pessoal/KANBAN-OFICIAL.md`
- `docs/spec-driven-development/padroes-de-testes.md`
- `.agents/rules/main-push-quality-and-versioning.md`
- `.agents/rules/post-push-ci-green.md`

## Pré-Requisito

Valide autenticação quando houver dúvida:

```bash
.agents/skills/skills/githubActions-connector/scripts/check_connection.sh
```

Token recomendado: fine-grained PAT com `Actions: Read and write`, `Contents: Read`, `Metadata: Read`.

Nunca exponha token em logs, docs, commits ou respostas.

## Comandos

Buscar workflow:

```bash
.agents/skills/skills/githubActions-connector/scripts/search_workflow.sh "ci"
```

Descrever workflow:

```bash
.agents/skills/skills/githubActions-connector/scripts/describe_workflow.sh ".github/workflows/ci.yml"
```

Disparar workflow com `workflow_dispatch`:

```bash
.agents/skills/skills/githubActions-connector/scripts/trigger_workflow.sh "<workflow>" "refs/heads/main" '{}'
```

Monitorar run:

```bash
.agents/skills/skills/githubActions-connector/scripts/watch_run.sh "<workflow>" --run-id <id>
```

Analisar falha:

```bash
.agents/skills/skills/githubActions-connector/scripts/analyze_run.sh "<workflow>" [run-id] [max-lines]
```

Cancelar run:

```bash
.agents/skills/skills/githubActions-connector/scripts/stop_run.sh "<workflow>" <run-id>
```

## Regras De Uso

- Leia o YAML real antes de concluir triggers, inputs, branches, paths ou jobs.
- Não declare sucesso por job parcial; o run precisa estar `completed` com `conclusion=success`.
- Depois de push para `main`, monitore o run do commit publicado antes de declarar entrega concluída.
- Não dispare workflow apenas para "ver se passa".
- Antes de reexecutar, analise o último run falho quando a causa ainda não estiver clara.
- Use `--force` só para run travado, parâmetros errados ou execução obsoleta bloqueando a branch.
- Cancelamento é exceção; capture evidência mínima antes.

## Diagnóstico De Falha

Ao analisar um run:

1. identifique workflow e run id;
2. identifique job falho;
3. identifique step falho;
4. leia só o trecho relevante do log;
5. classifique a falha;
6. proponha correção ou próximo passo.

Classes de falha:

- código ou teste;
- coverage;
- container ou build;
- runner, emulador ou device;
- credencial ou permissão;
- action terceirizada;
- rede transitória.

## Gates WorkLink

Trate a CI como quebrada se falhar:

- backend quality gates;
- mobile quality gates;
- API Docker image;
- dependency scan;
- mobile integration on Android emulator.

Falhas Android:

- erro antes do script do usuário: provável runner, AVD ou action;
- `flutter drive`, assertion, widget não encontrado ou contrato HTTP: provável app ou teste;
- `adb`, `device offline`, `DeadSystemException`: provável infraestrutura do emulador;
- `VM Service timed out`: investigar ponte device/app e timing do teste.

## CD E Release

CI pode ser monitorada, analisada e reexecutada quando aplicável.

Publicação mobile exige autorização explícita do usuário:

- Android: Internal Testing primeiro;
- iOS: TestFlight primeiro.

Pré-release mínimo:

- testes locais obrigatórios verdes;
- CI verde;
- versionamento semântico e tag no mesmo commit;
- `.env.example` atualizado quando aplicável;
- política de privacidade e permissões revisadas;
- plano de incidente conhecido.

## Resposta Esperada

Ao final, informe:

- workflow;
- run id;
- job;
- step;
- classe da falha;
- evidência curta;
- ajuste aplicado ou próximo passo recomendado.
