---
name: git-operator
description: Automação de versionamento semântico, tags e operações de git flow.
required_env: []
metadata:
  progressive_disclosure: "Leia somente regras e documentos exigidos pela operacao Git atual; aprofunde em docs/tasks, docs/entregas e rules apenas no fechamento real."
  conditional_details: "if commit/tag/push/fechamento then use main-push-quality-and-versioning e post-push-ci-green; else_if organizar historico then valide KANBAN e entrega; else nao acione."
---

# Adaptação para Este Projeto

Neste projeto, esta skill deve operar em coerência com:

- `docs/jira-pessoal/KANBAN-OFICIAL.md`
- `docs/jira-pessoal/KANBAN.md`
- `docs/jira-pessoal/KANBAN-TECNICO.md`
- `docs/jira-pessoal/PLANO-DE-ENTREGAS-OFICIAL.md`
- `docs/jira-pessoal/EPICO-WORKLINK-V1.md`
- `docs/jira-pessoal/EPICO-TECNICO-WORKLINK-V1.md`
- `docs/tasks/`
- `docs/entregas/`
- `docs/entregas/TEMPLATE-DE-ENTREGA.md`

## Regra de Contexto

Commits, checkpoints e fechamento de versão não podem ser tratados como operações soltas.

Eles devem respeitar:

- a ordem cronológica das histórias
- a documentação da história em `docs/tasks/<KEY>/IMPLEMENTATION.md`
- a documentação final da entrega em `docs/entregas/`
- o plano versionável em `docs/jira-pessoal/PLANO-DE-ENTREGAS-OFICIAL.md`

`KANBAN-OFICIAL.md` é a fonte oficial da ordem. `KANBAN.md` e `KANBAN-TECNICO.md` são apenas visões filtradas.

## Regra para Fechamento Semântico

Quando esta skill for usada no fechamento de uma entrega:

- o documento cronológico da entrega já deve existir em `docs/entregas/`
- a história correspondente já deve estar aprovada nos gates aplicáveis
- a sugestão de versão semântica já deve existir
- o tipo semântico deve estar coerente com a entrega real: `MAJOR`, `MINOR` ou `PATCH`
- a tag semântica deve ser criada apontando para o EXATO commit que fecha a história
- não é aceitável criar a tag depois em outro commit ou depender de ajuste manual posterior

Se isso ainda não estiver pronto, o fechamento está incompleto.

## Regra de Execução Obrigatória no Fechamento

No fluxo deste projeto, `git-operator` não deve apenas sugerir o fechamento.

Ele deve executar de fato:

1. staging seletivo apenas dos arquivos da história atual
2. commit isolado da história atual
3. criação da tag semântica correspondente
4. validação programática de que a tag aponta para o mesmo commit recém-criado

Se qualquer uma dessas quatro etapas falhar, a história NÃO está fechada.

## Regra de Staging Seletivo

Antes de qualquer commit:

- leia `git status --short`
- identifique os arquivos relacionados à história atual
- não inclua mudanças não relacionadas ou feitas pelo usuário para outra demanda
- inclua, quando fizer parte do fechamento, os artefatos documentais da própria história:
    - `docs/tasks/<KEY>/IMPLEMENTATION.md`
    - `docs/tasks/<KEY>/progress.txt`
    - história em `docs/jira-pessoal/historias/` ou `docs/jira-pessoal/historias-tecnicas/`
    - `docs/jira-pessoal/KANBAN-OFICIAL.md`
    - visão filtrada correspondente, se atualizada
    - documento em `docs/entregas/`

Se houver dúvida sobre arquivo relacionado, não faça staging automático.

## Regra de Tags Semânticas

Formato obrigatório da tag:

```text
vMAJOR.MINOR.PATCH
```

Algoritmo:

1. Identifique a última tag semântica com `git tag --list 'v[0-9]*.[0-9]*.[0-9]*' --sort=-v:refname`.
2. Se não existir tag anterior, use `v0.0.0` como base.
3. Aplique o incremento sugerido e aprovado:
    - `MAJOR`: incrementa major e zera minor/patch.
    - `MINOR`: incrementa minor e zera patch.
    - `PATCH`: incrementa patch.
4. Crie tag anotada sobre o commit de fechamento:
    - `git tag -a <nova_tag> -m "<KEY> - <titulo da entrega>"`
5. Valide:
    - `git rev-parse HEAD`
    - `git rev-parse <nova_tag>^{}`
    - os dois hashes devem ser idênticos.

Se a tag já existir, pare e peça decisão humana. Não sobrescreva tag.

# Capacidade: Fechar História (`close-story`)

Use no encerramento real de uma história `WL-*` ou `WLT-*`.

## Pré-requisitos

- história é a próxima elegível em `docs/jira-pessoal/KANBAN-OFICIAL.md`
- `IMPLEMENTATION.md` existe
- `progress.txt` existe
- documento da entrega existe em `docs/entregas/`
- gates aplicáveis foram aprovados
- tipo semântico foi sugerido e justificado
- working tree foi revisada para staging seletivo

## Execução

1. Validar ordem no `KANBAN-OFICIAL.md`.
2. Validar presença dos artefatos obrigatórios.
3. Validar que a entrega documentada corresponde à história atual.
4. Fazer staging seletivo.
5. Gerar commit com Conventional Commits em português, identificador da história e trailer `Co-authored-by`.
6. Criar tag semântica anotada.
7. Validar que `HEAD` e tag apontam para o mesmo commit.
8. Reportar commit hash e tag criada.

Se qualquer etapa falhar, não considere a história fechada.

# Capacidade: Gerar Mensagem de Commit (`commit-msg`)

Quando você precisar commitar suas alterações, **não invente** a mensagem. Siga estritamente o padrão Conventional
Commits.

## Regras

1. **Analise as mudanças** em `git diff --cached`.
2. **Identifique o Tipo**:
    - `feat`: Nova funcionalidade (correlaciona com Minor version).
    - `fix`: Correção de bug (correlaciona com Patch version).
    - `docs`: Documentação.
    - `chore`: Configurações de build, deps, ferramentas (sem alteração de prod).
    - `refactor`: Alteração de código que não muda funcionalidade.
    - `test`: Adição ou correção de testes.
3. **Formato**:
    - `type(scope): descrição curta em português [KEY]`
    - Última linha obrigatória em commits assistidos por IA: `Co-authored-by: <LLM usada>`.
    - Não invente endereço de email para LLM; se fizer sentido, cite apenas o provedor junto ao modelo.
    - **Regra para KEY**:
        - Se o commit estiver ligado a uma história, incluir obrigatoriamente `[WL-000]` ou `[WLT-000]`.
        - Se não existir história associada, não incluir identificador.
    - Exemplos:
        - `feat(auth): adiciona autenticação por telefone [WL-009]`
        - `chore(ci): adiciona pipeline de validação backend [WLT-017]`
        - `docs(backlog): atualiza kanban oficial unificado`

## Instrução para o Agente

Gere a mensagem sempre em **PORTUGUÊS** e preserve o trailer com corpo separado:
`git commit -m "<mensagem gerada>" -m "Co-authored-by: Claude Opus 4.6"`

### Regra adicional deste projeto

Se o commit estiver ligado ao fechamento de uma história:

- valide se a história correspondente já tem `IMPLEMENTATION.md`
- valide se existe documentação da entrega em `docs/entregas/`
- valide se o commit não está pulando a ordem cronológica do `KANBAN-OFICIAL.md`
- valide que a tag semântica será criada sobre esse mesmo commit de fechamento
- após commitar, confirme programaticamente que `HEAD` e a tag criada apontam para o mesmo commit

### Regra crítica deste projeto

Não encerre com “pronto para commit/tag”: fechamento correto exige commit, tag e hash validado.

## Compatibilidade com Husky (Pre-Commit Hooks)

Muitos projetos usam Husky para rodar lint/testes antes do commit.

1. **NUNCA** use a flag `--no-verify` ou `-n` para pular verificações.
2. Se o comando `git commit` falhar:
    - Leia o log de erro retornado pelo hook.
    - **NÃO** tente commitar novamente sem corrigir o erro.
    - Registre a falha e encaminhe para o agente responsável pelo gate que falhou.
    - Só tente novamente depois da correção e nova validação.

---

# Capacidade: Sincronizar com Remoto (`sync`)

Responsável por enviar (push) as alterações locais para a branch remota de trabalho.

## Regras de Segurança

1. Antes de sincronizar, execute `git status --short`.
2. Se houver mudanças não commitadas, **não** execute `git pull --rebase`; primeiro feche ou isole o trabalho atual.
3. **Sempre** faça um `pull` antes de tentar o push para evitar rejeição.
4. Use `git pull --rebase` para manter o histórico linear.
5. Se houver conflitos no pull, **PARE** e notifique o usuário. Não tente resolver merge conflicts complexos sozinho.

## Instrução para o Agente

1. `git status --short`
2. `git pull --rebase origin <branch_atual>`
3. `git push origin <branch_atual>`
4. Se houver tag de fechamento: `git push origin <tag>`
5. **Se falhar (non-fast-forward)**:
    - Execute `git pull --rebase origin <branch_atual>` novamente (para pegar o que entrou nesse meio tempo).
    - Tente `git push origin <branch_atual>` novamente.

## Observação para Este Projeto

Como o projeto usa um fluxo cronológico por histórias, a sincronização não deve acontecer como atalho para esconder
estado inconsistente.

Antes de sincronizar:

- confirme se a história atual está devidamente registrada
- confirme se o estado documental acompanha o estado do código
- se houver tag de fechamento recém-criada, faça push da branch e da tag correspondente de forma explícita

---

# Capacidade: Iniciar Tarefa (`checkout-task`)

**Opcional**. Use apenas quando instruído pelo Orquestrador para isolar o trabalho (Sandbox).

## Instrução para o Agente

1. Vá para a branch base (geralmente `main`).
2. Garanta que está atualizada: `git pull --rebase origin main`.
3. Crie a branch da task: `git checkout -b <nome-branch>`.
    - Padrão de nome: `agent/<KEY>-<slug-curto>`

### Adaptação para Este Projeto

Neste projeto, o ideal é que o nome da branch reflita a história em execução.

Exemplo:

- `agent/WLT-001-monorepo-stack-base`
- `agent/WL-010-contato-whatsapp-intencao`

---

# Capacidade: Finalizar Tarefa (`squash-task`)

**Opcional**. Use para integrar uma branch de tarefa (Sandbox) de volta para a main com um único commit limpo (Squash).

## Instrução para o Agente

1. Identifique a branch atual (`agent/...`).
2. Volte para a main: `git checkout main`.
3. Atualize a main: `git pull --rebase origin main`.
4. Faça o Squash Merge: `git merge --squash <branch-anterior>`.
5. Realize o Commit Final (Use a **Capacidade: Gerar Mensagem de Commit**).
6. Suba para a origem: `git push origin main`.
7. Limpeza Local: somente se explicitamente solicitado, use `git branch -d <branch-anterior>` após confirmar merge.
8. Limpeza Remota: somente se explicitamente solicitado, use `git push origin --delete <branch-anterior>`.

---

# Capacidade: Unificar Commits da Branch (`squash-branch`)

Use somente quando explicitamente solicitado para transformar todos os commits da branch atual em um único commit
(Squash) e atualizar o Pull Request via Force
Push. Útil para limpar o histórico antes de solicitar Code Review.

Não use `squash-branch` como parte automática do fechamento cronológico do Ralph Loop. O fechamento oficial da história
deve ser um commit isolado criado pela capacidade `close-story`.

## Pré-requisitos

1. Você deve estar na branch que deseja unificar (ex: `agent/WLT-001-monorepo-stack-base`).
2. A branch deve ter uma base clara (geralmente `origin/main`).

## Instrução para o Agente

1. **Garanta a Base**:
    - Execute `git fetch origin` para ter os dados mais recentes.
2. **Identifique o Ponto de Divergência**:
    - Descubra o commit ancestral comum entre a branch atual e a `main`:
    - `git merge-base origin/main HEAD`
    - (Guarde o hash retornado, vamos chamar de `<ANCESTOR_HASH>`).
3. **Soft Reset**:
    - `git reset --soft <ANCESTOR_HASH>`
    - _Isso "desfaz" os commits intermediários mas mantém todas as alterações em "Staged" (Index)._
4. **Criar Commit Unificado**:
    - Gere uma mensagem de commit que resume todo o trabalho (siga a regra `type(scope): ...`).
    - `git commit -m "<mensagem-final>"`
5. **Force Push**:
    - Como o histórico foi reescrito localmente, use `git push origin HEAD --force-with-lease`.
