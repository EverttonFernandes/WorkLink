---
name: ralph-loop/execution-plan
description: Template de State Machine para o Ralph Loop. Enriquece o IMPLEMENTATION.md com frontmatter YAML machine-readable (Exit Bar, correction_queue, cycle_history e métricas de observabilidade).
required_env: []
metadata:
  progressive_disclosure: "Abra apenas KANBAN, historia e docs normativos necessarios para montar o IMPLEMENTATION da demanda atual."
  conditional_details: "if falta IMPLEMENTATION/progress then preparar artefato; else_if plano nao e testavel then bloquear e pedir ajuste; else enriquecer state machine."
---

# Capacidade: Gerar Frontmatter Ralph Loop (`generate`)

Enriqueça o artefato `docs/tasks/<KEY>/IMPLEMENTATION.md` adicionando o frontmatter YAML abaixo **no topo do arquivo**.
Este frontmatter transforma o `IMPLEMENTATION.md` na **única fonte de verdade** do estado da tarefa durante o Ralph
Loop.

> [!IMPORTANT]
> O Ralph Loop **NÃO cria** um arquivo separado (`execution_plan.md`). O `IMPLEMENTATION.md` já existe (criado pelo
> workflow `start-work`) e contém o plano técnico aprovado. O frontmatter YAML é **adicionado** ao arquivo existente,
> unificando plano + state machine em um só artefato.

## Adaptação para Este Projeto

Ao enriquecer o `IMPLEMENTATION.md` neste projeto, o plano técnico já existente deve estar alinhado explicitamente a:

- `docs/requisitos/epico-requisitos-de-negocio.md`
- `docs/requisitos/epico-requisitos-nao-funcionais.md`
- `docs/spec-driven-development/padroes-de-testes.md`
- `docs/spec-driven-development/codigo-limpo.md`
- `docs/spec-driven-development/padrões-de-projeto-e-design-de-codigo.md`
- `docs/jira-pessoal/KANBAN-OFICIAL.md`

Se o plano não refletir esses documentos, ele deve ser corrigido antes da adição do frontmatter.

> [!WARNING]
> **Spec Interview (PRE-PLANNING Obrigatório)**: Antes de adicionar o frontmatter, valide que o plano técnico no
`IMPLEMENTATION.md` atende aos seguintes critérios. Se **qualquer um** falhar, **NÃO adicione o frontmatter** — PARE e
> pergunte ao usuário:
>
> 1. **Critérios testáveis mecanicamente?** — Cada critério de aceitação possui um comando, asserção ou condição que
     pode ser verificado automaticamente?
> 2. **Interfaces/APIs definidas?** — As assinaturas de métodos, endpoints ou contratos estão claras (explícitas ou
     implícitas no código existente)?
> 3. **Zero ambiguidade?** — Algum critério é subjetivo, vago ou aberto a interpretação? Se sim, resolva com o humano
     antes de prosseguir.
> 4. **Análise de Dependências cross-repo?** — A implementação requer alterações em **outros repositórios, libs externas
     ou módulos compartilhados**? Se sim, essas dependências DEVEM ser listadas no plano com: (a) repositório/lib
     afetado, (b) alteração necessária, (c) ordem de execução (a dependência DEVE ser resolvida ANTES do loop iniciar).
     Dependências não mapeadas bloqueiam o início do loop.
> 5. **Regras do projeto consultadas?** — `docs/requisitos/epico-requisitos-de-negocio.md`, `docs/requisitos/epico-requisitos-nao-funcionais.md`,
     `docs/spec-driven-development/padroes-de-testes.md`, `docs/spec-driven-development/codigo-limpo.md` e
     `docs/spec-driven-development/padrões-de-projeto-e-design-de-codigo.md` foram lidos? Checklists e cenários obrigatórios foram **copiados** para
     o plano? Se a regra define N cenários obrigatórios, o plano DEVE prever testes para TODOS os N cenários.
> 6. **Ordem oficial respeitada?** — A história planejada é a próxima elegível em `docs/jira-pessoal/KANBAN-OFICIAL.md`?
     Se houver história anterior aberta, o plano não pode receber frontmatter.
> 7. **Padrões obrigatórios refletidos?** — O plano explicita cobertura unitária mínima de 95%, testes com
     `GIVEN/WHEN/THEN`, código limpo universal e arquitetura Monólito Modular + DDD tático + Ports and Adapters quando
     houver backend?

## Frontmatter YAML (State Machine)

```yaml
---
# ══════════════════════════════════════════════
# 🎛️ RALPH LOOP STATE MACHINE — NÃO EDITE MANUALMENTE
# ══════════════════════════════════════════════
task_key: "<KEY>"
branch: "<BRANCH>"
phase: PLANNING           # PLANNING | AWAITING_APPROVAL | EXECUTION | AUDIT | DONE
loop_iteration: 0
max_iterations: 12        # Limite por janela de execução. Ao atingir o limite, persistir estado e reiniciar com fresh context.
fresh_context_after_iteration: 3
progress_file: "docs/tasks/<KEY>/progress.txt"
completion_promise: PENDING   # PENDING | COMPLETE

# 🧪 Detecção de Testes Funcionais (Preenchido automaticamente na Phase PLANNING, iteração 0)
func_tests_detected: false   # true | false — Detectado pelo Orquestrador na primeira iteração
func_tests_path: ""          # Caminho raiz dos testes funcionais (ex: src/test-functional, __functional_test__)
func_tests_framework: ""     # Framework detectado (ex: failsafe, cucumber, playwright, jest)

# 📊 Exit Bar (O "Checklist de Ouro" para encerrar)
# 🚨 STATUS VÁLIDOS: PASS | FAIL | PENDING | N/A
# ⛔ STATUS PROIBIDOS: SKIP, ABORTED, SKIPPED, ou qualquer outro inventado.
# Se um gate não pode ser executado localmente, use N/A com justificativa
# documentada no Log de Iterações. Exceção: security não aceita N/A.
# NUNCA use SKIP.
exit_bar:
  lint:          PENDING    # PASS | FAIL | PENDING
  unit_tests:    PENDING    # PASS | FAIL | PENDING
  integration_tests: PENDING # PASS | FAIL | PENDING | N/A (N/A somente se não há integração aplicável/configurada)
  func_tests:    PENDING    # PASS | FAIL | PENDING | N/A (N/A somente se func_tests_detected: false)
  mobile_tests:  PENDING    # PASS | FAIL | PENDING | N/A (N/A se não há app mobile ou escopo mobile)
  sonar:         PENDING    # PASS | FAIL | PENDING | N/A (N/A somente se não há Sonar configurado no projeto)
  coverage:      PENDING    # PASS | FAIL | PENDING | N/A (PASS exige cobertura unitária >= 95% quando há suíte unitária)
  sre:           PENDING    # PASS | FAIL | PENDING | N/A (N/A se a história não toca SRE/DevOps/operabilidade)
  security:      PENDING    # PASS | FAIL | PENDING — revisão do security-specialist + security-guardian local
  arch_review:   PENDING    # PASS | FAIL | PENDING (NEEDS_CHANGES/REJECTED do arquiteto viram FAIL)
  final_review:  PENDING    # PASS | FAIL | PENDING

# 🔄 Registro do Ciclo Atual
last_cycle:
  agent: null
  action: null
  result: null
  timestamp: ""

# 🚧 Fila de Correções Pendentes (Alimentada pelos subagentes/Orquestrador)
# Cada item aqui vira uma tarefa para o Agente_Executor
correction_queue: []

# 📜 Histórico de Ciclos (Para manter o contexto curto e eficiente)
cycle_history: []

# 📈 Métricas de Observabilidade (Preenchido pelo Orquestrador)
metrics:
  first_pass_gates: []       # Gates que passaram na primeira tentativa (ex: [lint, unit_tests])
  total_iterations: 0
  gates_failed_count: 0      # Total acumulado de gates que falharam
  mode_collapse_events: 0    # Quantas vezes Mode Collapse foi detectado
  convergence_notes: ""      # Observações sobre eficiência do loop
---
```

## Seções Obrigatórias no Corpo do IMPLEMENTATION.md

Após o frontmatter, o corpo do `IMPLEMENTATION.md` deve conter (além das seções já existentes do plano técnico):

### Seção: Log de Iterações (Ralph Loop)

```markdown
## 📋 Log de Iterações (Ralph Loop)
<!-- Preenchido automaticamente pelo Orquestrador durante o loop -->
<!-- Novos ciclos são adicionados no topo (mais recente primeiro) -->
```

### Seção: Aprendizados do Loop

```markdown
## 📒 Aprendizados do Loop
<!-- Preenchido pelo Orquestrador ao final de ciclos relevantes -->
<!-- Gotchas, padrões problemáticos e decisões técnicas que funcionaram/falharam -->
<!-- Usado para Context Refresh: novas janelas leem esta seção para saber o que evitar -->
```

## Instruções de Uso

1. O `IMPLEMENTATION.md` já deve existir (criado pelo `start-work`).
2. Adicione o frontmatter YAML no topo do arquivo existente.
3. Substitua `<KEY>` e `<BRANCH>` com valores reais.
4. Adicione as seções "Log de Iterações" e "Aprendizados do Loop" ao final do corpo.
5. Após aprovação final do humano, atualize `phase: EXECUTION` e inicie o Ralph Loop.

## Artefato complementar obrigatório

Além do `IMPLEMENTATION.md`, este projeto deve usar:

- `docs/tasks/<KEY>/progress.txt`

Esse arquivo deve ser criado ou atualizado para registrar:

- falha observada
- hipótese de correção
- ação tomada
- resultado da tentativa

Ele é a memória curta operacional do loop entre janelas.

## Checklist Mínimo do Plano Técnico Neste Projeto

Antes de considerar o plano apto para receber o frontmatter, confirme que o corpo do `IMPLEMENTATION.md` já explicita:

- aderência ao negócio documentado em `docs/requisitos/epico-requisitos-de-negocio.md`
- aderência aos RNFs documentados em `docs/requisitos/epico-requisitos-nao-funcionais.md`
- confirmação de que a história é a próxima elegível em `docs/jira-pessoal/KANBAN-OFICIAL.md`
- estratégia de testes baseada em `docs/spec-driven-development/padroes-de-testes.md`
- estratégia para manter cobertura unitária mínima de 95%
- requisitos de código limpo universal de `docs/spec-driven-development/codigo-limpo.md`
- testes planejados com `GIVEN`, `WHEN`, `THEN`
- critérios de design de `docs/spec-driven-development/padrões-de-projeto-e-design-de-codigo.md`
- aderência a Monólito Modular, DDD tático e Ports and Adapters quando a história tocar backend
- riscos de SRE e segurança aplicáveis, sem misturar responsabilidades entre agentes
