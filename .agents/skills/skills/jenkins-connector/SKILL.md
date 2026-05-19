---
name: jenkins-connector
description: Monitora builds no Jenkins, verifica status e analisa logs de erro.
required_env: ["JENKINS_USER", "JENKINS_TOKEN"]
---

# Capacidade: Configuração Inicial (`configure`)

Script interativo para configurar suas credenciais do Jenkins globalmente na máquina.

## Execução

- **IMPORTANTE:** Para questões de segurança de credenciais, **sempre rode este script manualmente numa aba de terminal**. Não peça à Inteligência Artificial para rodá-lo por você.
- Execute no seu terminal fonteando o estado interativo: `source .agent/skills/jenkins-connector/scripts/configure.sh`
- O script pedirá seu `JENKINS_USER` e `JENKINS_TOKEN` de forma oculta e segura, exportando-os com persistência no seu `~/.bashrc`.
- _Dica_: Você pode gerar e encontrar seu token acessando: `https://dese-jenkins.umov.me/user/<seu.usuario@umov.me>/configure`

---

# Capacidade: Verificar Conexão (`check-connection`)

Verifica se as credenciais do Jenkins estão válidas.

## Execução

- Chame o script: `.agent/skills/jenkins-connector/scripts/check_connection.sh`

---

# Capacidade: Buscar Job (`search-job`)

Busca jobs no Jenkins por nome parcial (case-insensitive). Útil quando o nome exato do job não é conhecido.

Suporta **busca multi-termo**: espaços separam termos em AND lógico — todos devem estar presentes no nome do job.

## Execução

- `.agent/skills/jenkins-connector/scripts/search_job.sh "<termo>"`
- `.agent/skills/jenkins-connector/scripts/search_job.sh "termo1 termo2"` — AND: ambos devem estar no nome

## Saída

| Matches | Status           | Ação do Agente                                     |
| ------- | ---------------- | -------------------------------------------------- |
| 1       | `FOUND`          | Usa o `JOB_NAME` retornado                         |
| 2+      | `MULTIPLE_FOUND` | Apresenta as opções ao usuário para escolher       |
| 0       | `NOT_FOUND`      | Pede nome mais específico ou tenta multi-termo AND |

> [!TIP]
> Se o resultado tiver muitos jobs, use multi-termo para refinar: `search_job.sh "ENTRADA graphql"` encontra jobs que contêm **ambos** os termos.

## Convenção de Nomes por Time

Os jobs seguem uma convenção de prefixo por time e sufixo `_Pipeline`:

| Prefixo        | Time           | Jobs |
| -------------- | -------------- | ---- |
| `ENTRADA_`     | Core / Entrada | ~93  |
| `AUTOMACAO_`   | Automação      | ~80  |
| `SUSTENTACAO_` | Sustentação    | ~62  |
| `IDENTIDADE_`  | Identidade     | ~60  |
| `APLICATIVOS_` | Aplicativos    | ~14  |
| `GESTAO_`      | Gestão         | ~5   |

> [!TIP]
> Nem todos os jobs seguem esse padrão, mas é um bom ponto de partida para refinar buscas.

## Quando usar

Se o `trigger_job.sh` retornar **exit code 3** (job não encontrado), use `search_job.sh` para resolver o nome antes de tentar novamente:

1. Rode `search_job.sh "<nome_parcial>"`
2. Se `STATUS=FOUND` → use o `JOB_NAME` retornado no `trigger_job.sh`
3. Se `STATUS=MULTIPLE_FOUND` → apresente as opções ao usuário e peça para escolher
4. Se `STATUS=NOT_FOUND` → refine com multi-termo AND ou peça ao usuário um nome mais específico

---

# Capacidade: Descrever Job (`describe-job`)

Descreve os parâmetros de um job: nomes, tipos, defaults, choices e exemplo de uso pronto para o `trigger_job.sh`.

## Execução

- `.agent/skills/jenkins-connector/scripts/describe_job.sh "<JobName>"`

## Quando usar

- Quando o agente **não sabe quais parâmetros** um job espera (ex: rodando fora do projeto, sem `AGENTS.md`).
- Para **montar a query string** correta antes de chamar o `trigger_job.sh`.
- Fluxo natural: `search_job.sh` → `describe_job.sh` → `trigger_job.sh`

## Saída

```
📋 Job: ENTRADA_umovme-Business-Graphql_Pipeline
   URL: https://dese-jenkins.umov.me/job/ENTRADA_.../

🔧 Parâmetros (4):

   📌 CHECKOUT
      Tipo:    Branch/Tag
      Default: origin/main
      Desc:    Tag ou branch para o build

   📌 DEPLOY_FEDERATION
      Tipo:    Boolean
      Default: false
      Desc:    Se marcado, realiza o deploy e testes do Federation

💡 Exemplo de uso:
   trigger_job.sh "ENTRADA_..." "CHECKOUT=origin/main&DEPLOY_FEDERATION=false"

STATUS=DESCRIBED
```

---

# Capacidade: Disparar Job (`trigger-job`)

Dispara um job parametrizado via API. Retorna o `QUEUE_ID` para rastreamento determinístico.

## Modo 1: Explícito (Parâmetros fornecidos)

Se o workflow ou usuário forneceu `JobName` e `Params`, use-os diretamente sem nenhuma auto-detecção.

1.  **Execução**: `.agent/skills/jenkins-connector/scripts/trigger_job.sh "<JobName>" "<QueryString>"`

## Modo 2: Auto-detect (Dentro do projeto)

Se o workflow ativou `trigger-job` **sem especificar** `JobName`, o agente deve resolver automaticamente:

1.  **Detectar JobName** (em ordem de prioridade):
    1. Leia `AGENTS.md` na raiz do projeto, seção `🛠 CI/CD`.
    2. Se não encontrar, leia o `README.md` do projeto.
    3. Se não encontrar em nenhum: **PARE** e pergunte ao usuário.
    4. Se o `trigger_job.sh` retornar **exit code 3** (job não encontrado), use `search_job.sh` para resolver o nome parcial antes de tentar novamente.
2.  **Detectar Params**:
    1. Se `AGENTS.md` ou `README.md` explicar os parâmetros, use-os.
    2. Se não, leia o `Jenkinsfile` do projeto para identificar os parâmetros esperados.
    3. **Padrão comum**: `CHECKOUT=origin/<branch_atual>` (usando `git branch --show-current`).
3.  **Execução**: `.agent/skills/jenkins-connector/scripts/trigger_job.sh "<JobName>" "<QueryString>"`

## Modo 3: Descoberta (Fora do projeto)

Se o agente **não está dentro do projeto** e o usuário forneceu informações parciais (ex: "rode a pipeline do business-graphql com a última tag"), encadeie as capacidades:

1.  **Resolver JobName**: `search_job.sh "<nome_parcial>"`
2.  **Descobrir Params**: `describe_job.sh "<JobName>"` — identifica os parâmetros, tipos e defaults.
3.  **Resolver valores dinâmicos** do usuário:

    | Pedido do usuário                 | Como resolver                                                                           |
    | --------------------------------- | --------------------------------------------------------------------------------------- |
    | "última tag" / "tag mais recente" | `git ls-remote --tags --sort=-v:refname git@bitbucket.org:umovme/<repo>.git \| head -1` |
    | "branch X"                        | Usar `origin/<branch>` diretamente                                                      |
    | "branch atual"                    | `git branch --show-current` (se dentro do projeto)                                      |
    | "commit específico"               | Usar o SHA diretamente                                                                  |

    > **Dica de resolução do repo**: O nome do repositório geralmente está embutido no nome do job. Ex: `ENTRADA_umovme-Business-Graphql_Pipeline` → repo `umovme-business-graphql`.

4.  **Execução**: `.agent/skills/jenkins-connector/scripts/trigger_job.sh "<JobName>" "<QueryString>"`

## Saída

O script imprime na última linha `QUEUE_ID=<N>`, que pode ser usado com `--queue-id` no `watch_build.sh`:

```
✅ Build Triggered Successfully!
   Queue ID: 12345
STATUS=TRIGGERED
QUEUE_ID=12345
```

## Flag Opcional: `--force`

Quando o `trigger_job.sh` detecta um build ativo para a mesma branch, ele retorna `STATUS=ALREADY_RUNNING` sem disparar um novo. Com `--force`, o comportamento muda:

1. Para o build ativo via `stop_build.sh`
2. Dispara um novo build com os parâmetros solicitados

```bash
.agent/skills/jenkins-connector/scripts/trigger_job.sh "<JobName>" "<Params>" --force
```

Sem `--force`, a mensagem de `ALREADY_RUNNING` agora inclui uma dica: `💡 Use --force para cancelar o build ativo e disparar um novo.`

# Capacidade: Monitorar Build do Job (`watch-job`)

Monitora o último build de um job para a branch atual. Suporta dois modos de uso:

## Modo 1: Via Queue ID (Recomendado após trigger)

Após disparar um build, use o `QUEUE_ID` retornado pelo trigger para rastrear **exatamente** o build disparado. Sem ambiguidade, sem race conditions.

1.  **Execução**: `.agent/skills/jenkins-connector/scripts/watch_build.sh "<JobName>" --queue-id <ID>`
2.  O script consulta a queue API até obter o build number, então trava nele.
3.  A branch é detectada automaticamente dos parâmetros do build.

## Modo 2: Explícito (Parâmetros fornecidos)

Se o workflow forneceu `JobName` e `BranchName`, use-os diretamente.

1.  **Execução**: `.agent/skills/jenkins-connector/scripts/watch_build.sh "<JobName>" "<BranchName>"`

## Modo 3: Auto-detect (Sem parâmetros)

Se o workflow ativou `watch-job` sem especificar parâmetros:

1.  **Detectar JobName** (mesma lógica do `trigger-job`):
    1. Leia `AGENTS.md` na raiz do projeto, seção `🛠 CI/CD`.
    2. Se não encontrar, leia o `README.md` do projeto.
    3. Se não encontrar: **PARE** e pergunte ao usuário.
2.  **Detectar BranchName**: `git rev-parse --abbrev-ref HEAD`.
3.  **Execução**: `.agent/skills/jenkins-connector/scripts/watch_build.sh "<JobName>" "<BranchName>"`

## Fluxo recomendado: Trigger + Watch

```bash
# 1. Trigger — captura QUEUE_ID
trigger_job.sh "MyJob" "CHECKOUT=origin/my-branch"
# Saída inclui: QUEUE_ID=12345

# 2. Watch — usa QUEUE_ID para rastrear o build exato
watch_build.sh "MyJob" --queue-id 12345
```

## Flag Opcional: `--only-new`

- Por padrão, o script aceita builds **já em execução** que correspondam à branch. Isso é útil para monitorar um build que já foi disparado.
- Use `--only-new` quando quiser ignorar builds pré-existentes e esperar **apenas por um novo build** iniciado após a invocação do script.
- Exemplo: `.agent/skills/jenkins-connector/scripts/watch_build.sh "<JobName>" "<BranchName>" --only-new`
- **Nota:** `--queue-id` torna `--only-new` desnecessário, pois o build é rastreado deterministicamente.

## Comportamento

- O script faz polling a cada 10s no endpoint `lastBuild`.
- Ao encontrar o **primeiro build matching** para a `BranchName`, **trava nele** (Sticky Build) — a URL muda de `lastBuild` para o build específico.
- Com `--queue-id`, o build é pré-travado imediatamente após resolução da queue (sem polling de `lastBuild`).
- Após o lock, o script **nunca troca** para builds mais novos; monitora até a conclusão.
- Exibe progresso dos stages via wfapi enquanto está "building".
- Exit codes:
  - `0` = SUCCESS
  - `1` = FAILURE (falha no código: testes, lint, etc.)
  - `2` = Erro de sistema (timeout, ABORTED, infra)

# Capacidade: Parar Build (`stop-build`)

Cancela um build em execução no Jenkins. Útil para interromper builds com parâmetros incorretos antes de disparar um novo.

## Modo 1: Por Número de Build

```bash
.agent/skills/jenkins-connector/scripts/stop_build.sh "<JobName>" <BuildNumber>
```

## Modo 2: Último Build

```bash
.agent/skills/jenkins-connector/scripts/stop_build.sh "<JobName>" --latest
```

## Modo 3: Por Branch

Busca nos últimos 5 builds um que esteja ativo para a branch especificada.

```bash
.agent/skills/jenkins-connector/scripts/stop_build.sh "<JobName>" --branch "<BranchName>"
```

## Comportamento

| Cenário                    | Ação            | Output                                |
| -------------------------- | --------------- | ------------------------------------- |
| Build em execução          | POST `/stop`    | `✅ Build #N cancelado com sucesso`   |
| Build já finalizado        | Detecta e avisa | `⚠️ Build #N já finalizou (RESULT)`   |
| Build não encontrado       | Erro            | `❌ Build #N não encontrado`          |
| `--branch` sem build ativo | Avisa           | `⚠️ Nenhum build ativo para branch X` |

## Saída

O script imprime na última linha `STATUS=STOPPED` e `BUILD_NUMBER=<N>`, que podem ser usados por outros scripts:

```
✅ Build #652 cancelado com sucesso.

BUILD_NUMBER=652
STATUS=STOPPED
```

## Fluxo recomendado: Stop + Trigger + Watch

```bash
# 1. Parar build com parâmetros errados
stop_build.sh "MyJob" --latest

# 2. Disparar novo build com parâmetros corretos
trigger_job.sh "MyJob" "CHECKOUT=origin/main&DEPLOY_FEDERATION=true"

# 3. Monitorar o novo build
watch_build.sh "MyJob" --queue-id 12345
```

---

# Capacidade: Analisar Falha (`analyze-failure`)

Análise de falha otimizada para LLMs. Usa wfapi para obter logs **só do stage que falhou** (~10-50 linhas em vez de milhares).

## Instrução

1.  **Parâmetros**:
    - **JobName**: Nome do job no Jenkins.
    - **BuildNumber** (opcional, default `lastBuild`): Número do build.
    - **MaxLogLines** (opcional, default `100`): Limite de linhas no log retornado.

2.  **Execução**:
    - `.agent/skills/jenkins-connector/scripts/analyze_build.sh "<JobName>" [BuildNumber] [MaxLogLines]`

3.  **Comportamento**:
    - **Primeiro**: Tenta wfapi (estruturado) — identifica o stage e step exatos que falharam.
    - **Fallback**: Se wfapi não disponível, usa grep em `consoleText` com padrões de erro.
    - **Último recurso**: `tail` das últimas N linhas.
    - Nunca carrega o log completo na janela de contexto.

4.  **Saída**:
    - Resumo visual dos stages (✅/❌).
    - Nome do stage e step que falhou.
    - Log filtrado do step (tipicamente 10-50 linhas).
