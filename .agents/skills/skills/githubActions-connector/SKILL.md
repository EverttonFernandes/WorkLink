---
name: githubActions-connector
description: Monitora workflows no GitHub Actions, verifica status, dispara execuções e analisa logs de falha da pipeline de CI/CD.
required_env: ["GITHUB_TOKEN"]
---

# Papel desta skill no WorkLink

Esta skill e o conector oficial entre os agentes do projeto e o GitHub Actions do WorkLink.

Ela existe para:

- monitorar CI
- investigar falhas de pipeline
- disparar workflows com `workflow_dispatch` quando existirem
- cancelar runs problemáticos
- analisar logs com parcimônia de contexto
- apoiar a governança de CI/CD sem romper os guardrails do projeto

Ela **não** deve:

- substituir a leitura do workflow real
- inventar etapas inexistentes no `ci.yml`
- afirmar sucesso sem evidência de run concluído
- disparar automações destrutivas por conveniência
- tratar CD como permitido só porque CI existe

# Capacidade: Configuração Inicial (`configure`)

Script interativo para configurar o `GITHUB_TOKEN` globalmente na máquina.

## Execução

- Por segurança, rode manualmente em um terminal seu.
- Execute: `source .agents/skills/skills/githubActions-connector/scripts/configure.sh`
- O script persiste `GITHUB_TOKEN` no `~/.bashrc`.
- Token recomendado: Fine-grained PAT com `Actions: Read and write`, `Contents: Read`, `Metadata: Read`.

## Guardrail

- Nunca peça para a IA executar esse script por você quando houver interação de credencial.
- O token não deve ser impresso em logs, commits, docs ou respostas.
- Se `origin` já embute token temporário apenas para automação local, prefira `GITHUB_TOKEN` explícito para uso humano.

---

# Capacidade: Verificar Conexão (`check-connection`)

Valida credenciais e acesso ao repositório atual no GitHub Actions.

## Execução

- `.agents/skills/skills/githubActions-connector/scripts/check_connection.sh`

## Observação

- O repositório é autodetectado a partir do `origin`.

## Guardrail

- Antes de qualquer ação de trigger/cancel/watch, valide conexão quando houver dúvida de credencial.
- Em caso de falha de autenticação, pare o fluxo e corrija a credencial antes de seguir.

---

# Capacidade: Buscar Workflow (`search-workflow`)

Busca workflows por nome parcial ou caminho em `.github/workflows`.

## Execução

- `.agents/skills/skills/githubActions-connector/scripts/search_workflow.sh "<termo>"`
- `.agents/skills/skills/githubActions-connector/scripts/search_workflow.sh "ci mobile"` — AND lógico entre termos

## Saída

| Matches | Status           | Ação do Agente                          |
| ------- | ---------------- | --------------------------------------- |
| 1       | `FOUND`          | Usa `WORKFLOW_ID`/`WORKFLOW_PATH`       |
| 2+      | `MULTIPLE_FOUND` | Apresenta opções ao usuário             |
| 0       | `NOT_FOUND`      | Refina o nome ou pede contexto adicional |

## Guardrail

- No WorkLink, o primeiro workflow a inspecionar é `ci.yml`.
- Não assuma que existe workflow de release ou deploy sem confirmar em `.github/workflows/`.
- Se houver múltiplos workflows, apresente nome, path e estado antes de escolher.

---

# Capacidade: Descrever Workflow (`describe-workflow`)

Descreve um workflow do GitHub Actions: nome, path, estado, triggers e inputs de `workflow_dispatch`.

## Execução

- `.agents/skills/skills/githubActions-connector/scripts/describe_workflow.sh "<workflow-id|name|path>"`

## Quando usar

- Quando o agente não sabe quais `inputs` o workflow espera
- Antes de chamar `trigger_workflow.sh`
- Fluxo natural: `search_workflow.sh` → `describe_workflow.sh` → `trigger_workflow.sh`

## Guardrail

- Sempre leia o arquivo YAML real do workflow antes de concluir quais `inputs`, `branches`, `paths` ou `jobs` existem.
- Não deduza `workflow_dispatch` se ele não existir no YAML.
- Se o workflow não expõe `inputs`, não invente payload de disparo.

---

# Capacidade: Disparar Workflow (`trigger-workflow`)

Dispara um workflow via `workflow_dispatch`.

## Execução

- `.agents/skills/skills/githubActions-connector/scripts/trigger_workflow.sh "<workflow-id|name|path>" "<ref>" '{"input":"valor"}'`
- `.agents/skills/skills/githubActions-connector/scripts/trigger_workflow.sh "<workflow>" "refs/heads/main" '{}' --force`

## Comportamento

- Resolve o workflow por `id`, `name`, `path` ou nome do arquivo
- Aceita `ref` explícito (`refs/heads/main`, `refs/tags/v1.2.3`)
- `--force` cancela runs ativos do mesmo workflow na mesma branch antes de disparar outro

## Saída

- `STATUS=TRIGGERED`
- `RUN_ID=<id>` quando a resolução do run disparado for encontrada

## Guardrails do WorkLink

- Só dispare workflow quando:
  - o workflow realmente possuir `workflow_dispatch`, ou
  - o usuário pedir explicitamente uma nova execução e o fluxo suportar isso
- Nunca dispare workflow apenas para “ver se passa”.
- Antes de disparar novamente, analise o último run falho se a falha ainda não estiver explicada.
- `--force` só deve ser usado quando houver justificativa objetiva:
  - run travado
  - run com parâmetros errados
  - branch bloqueada por execução obsoleta
- Não cancele runs bem-sucedidos, nem runs de terceiros sem motivo técnico claro.
- Em workflows de release/deploy futuros, só dispare após:
  - CI verde
  - versionamento semântico criado
  - documentação da entrega pronta
  - aprovação explícita do usuário para a publicação

---

# Capacidade: Monitorar Run (`watch-run`)

Monitora um run do GitHub Actions até a conclusão.

## Execução

- `.agents/skills/skills/githubActions-connector/scripts/watch_run.sh "<workflow>" --run-id <id>`
- `.agents/skills/skills/githubActions-connector/scripts/watch_run.sh "<workflow>" "main"`
- `.agents/skills/skills/githubActions-connector/scripts/watch_run.sh "<workflow>" "main" --only-new`

## Comportamento

- Se receber `--run-id`, monitora exatamente aquele run
- Sem `run-id`, busca o primeiro run compatível com o workflow e branch/ref
- Faz polling da API do GitHub Actions até concluir

## Exit codes

- `0` = `success`
- `1` = `failure`
- `2` = erro de sistema, timeout, cancelamento ou conclusão não-sucesso

## Guardrail

- Não declare sucesso com base em job parcial; o run precisa estar `completed` com `conclusion=success`.
- Ao monitorar, trate o job falho como fonte primária, não apenas o resumo da UI.
- Em caso de `cancelled`, `timed_out` ou comportamento incoerente, classifique como problema de infra/sistema, não como bug de negócio por padrão.

---

# Capacidade: Parar Run (`stop-run`)

Cancela um run em execução do GitHub Actions.

## Execução

- `.agents/skills/skills/githubActions-connector/scripts/stop_run.sh "<workflow>" <run-id>`
- `.agents/skills/skills/githubActions-connector/scripts/stop_run.sh "<workflow>" --latest`
- `.agents/skills/skills/githubActions-connector/scripts/stop_run.sh "<workflow>" --branch "<branch>"`

## Saída

- `RUN_ID=<id>`
- `STATUS=STOPPED`

## Guardrail

- Cancelamento é exceção, não padrão.
- Antes de cancelar por branch, verifique se o run ativo realmente corresponde ao contexto atual.
- Nunca use cancelamento para mascarar falha; primeiro capture evidência mínima do erro.

---

# Capacidade: Analisar Falha (`analyze-failure`)

Análise de falha otimizada para LLMs sobre jobs do GitHub Actions.

## Execução

- `.agents/skills/skills/githubActions-connector/scripts/analyze_run.sh "<workflow>" [run-id] [max-lines]`

## Comportamento

- Resolve o run alvo
- Busca o primeiro job com `conclusion=failure`
- Baixa o log do job
- Retorna trechos filtrados com erros e o final do log, sem carregar a execução inteira

## Saída

- resumo do run
- id do job falho
- linhas relevantes do erro
- `STATUS=ANALYZED`

## Guardrails de Análise

- Primeiro identifique **qual job falhou**.
- Depois identifique **qual step falhou**.
- Só então leia o trecho de log relevante.
- Nunca use apenas a última linha do log como diagnóstico final.
- Diferencie:
  - falha de código/teste
  - falha de ambiente
  - falha de credencial/permissão
  - falha de runner/emulador
  - falha da própria action terceirizada
- Ao responder, cite:
  - `run id`
  - `job`
  - `step`
  - causa provável
  - evidência textual curta
  - próximo ajuste sugerido

---

# Adaptação para o contexto deste projeto

Esta skill substitui o uso de Jenkins pelo GitHub Actions no WorkLink.

Use como base principal:

- `.github/workflows/ci.yml`
- `.github/workflows/`
- `docs/tasks/`
- `Makefile`
- `docs/requisitos/epico-requisitos-nao-funcionais.md`
- `docs/spec-driven-development/padroes-de-testes.md`
- `docs/release/release-mobile.md`
- `docs/jira-pessoal/KANBAN-OFICIAL.md`

Em caso de dúvida sobre o workflow correto deste projeto, priorize:

1. `search_workflow.sh "ci"`
2. `describe_workflow.sh ".github/workflows/ci.yml"`
3. `analyze_run.sh ".github/workflows/ci.yml"`

# Guardrails completos do cenário WorkLink

## 1. Workflow oficial

Hoje, o workflow oficial de CI do projeto é:

- `.github/workflows/ci.yml`

Se existir qualquer outro workflow no futuro, ele deve ser tratado como complementar até prova em contrário.

## 2. Fonte de verdade dos gates

Para o WorkLink, esta skill deve considerar como gates mínimos da CI:

- backend quality gates
- mobile quality gates
- API Docker image
- dependency scan
- mobile integration on Android emulator

Se um desses falhar, a CI do WorkLink deve ser tratada como **quebrada**.

## 3. Regra de qualidade do projeto

Ao analisar um run do WorkLink, esta skill deve lembrar que o projeto exige:

- testes no padrão `GIVEN / WHEN / THEN`
- cobertura unitária mínima de `95%` para backend e mobile
- ambiente reproduzível em Docker
- arquitetura sem acoplamento indevido entre domínio e framework
- CI/CD já nascendo com os requisitos não funcionais ativos

Portanto, quando a pipeline falhar, a skill deve verificar primeiro:

1. regressão de testes
2. quebra de coverage
3. problema de container/build
4. problema de emulador/device
5. problema de workflow/action externa

## 4. Regra para falhas mobile

No WorkLink, falhas no job de emulador Android devem ser classificadas com mais precisão:

- se o erro ocorrer **antes** do script do usuário:
  - trate como falha de runner/emulador/action
- se o erro ocorrer durante `flutter drive` ou `integration_test`:
  - trate como falha potencial do app, do teste ou da ponte device/app
- se o erro for `adb`, `DeadSystemException`, `device offline`, boot instável:
  - trate primeiro como infraestrutura do AVD/runner
- se o erro for `VM Service timed out`, `assert`, `widget not found`, `HTTP contract`:
  - trate como falha do fluxo mobile/teste/app até prova em contrário

## 5. Regra de CD e release

Esta skill deve assumir postura conservadora sobre CD.

Para o WorkLink:

- CI pode ser monitorada, analisada e reexecutada
- CD/publicação só deve ocorrer com autorização explícita do usuário
- publicação mobile deve respeitar:
  - Android -> Internal Testing primeiro
  - iOS -> TestFlight primeiro

Checklist pré-release obrigatório, conforme `docs/release/release-mobile.md`:

- gates de backend e mobile aprovados
- versionamento semântico e tag criados
- `.env.example` atualizado
- política de privacidade e permissões revisadas
- plano de incidente conhecido

## 6. Regra de versionamento e documentação

Se esta skill for usada dentro de um ciclo de entrega do Ralph Loop, ela deve considerar que uma entrega só está realmente pronta quando:

- história anterior concluída
- CI coerente com a mudança
- documentação da entrega atualizada
- commit da história criado
- tag semântica criada sobre o mesmo commit

Ou seja: pipeline verde não substitui documentação, versionamento nem rastreabilidade.

## 7. Regra de economia de contexto

Ao analisar falhas:

- prefira um job por vez
- leia apenas o step falho e contexto próximo
- evite despejar log inteiro
- use `analyze_run.sh` antes de abrir logs massivos manualmente

## 8. Regra de resposta do agente

Ao usar esta skill no WorkLink, a resposta final do agente deve sempre informar:

- workflow analisado
- run id
- job afetado
- step afetado
- classe da falha
- evidência objetiva
- ajuste aplicado ou próximo passo recomendado

O foco esperado desta skill no WorkLink é:

- monitorar CI
- investigar falhas de pipeline
- disparar workflows com `workflow_dispatch` quando existirem
- cancelar runs problemáticos
- ler logs do GitHub Actions com parcimônia de contexto
