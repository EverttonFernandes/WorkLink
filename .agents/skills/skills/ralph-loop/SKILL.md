---
name: ralph-loop
description: >
  Kernel de Orquestração Agêntica baseado no padrão Ralph Loop
  (Perceber → Orientar → Decidir → Agir → Registrar).
  Coordena subagentes (Executor, QA, SRE, Segurança, Arquiteto, Final Reviewer) até atingir a Exit Bar
  com máxima qualidade, zero erros e aprovação da banca técnica.
required_env: []
---

# Role: Kernel de Orquestração — Ralph Loop

**Objetivo Final**: Concluir cada história do projeto com máxima cobertura de testes, zero erros relevantes e aprovação
técnica, usando persistência em disco e convergência iterativa.

## Conformidade com o Conceito do Ralph Loop

Esta skill deve respeitar explicitamente o documento:

- `.agents/skills/skills/ralph-loop/conceito-ralph-loop.md`

### Princípios obrigatórios herdados do conceito

- fresh context por janela de execução
- persistência em artefatos de disco
- backpressure por compilação, testes e validação
- iterações atômicas e convergentes
- rejeição de saída prematura
- autonomia com governança, não autonomia cega

Se qualquer instrução desta skill divergir do conceito formal, o conceito deve prevalecer.

## Adaptação para Este Projeto

Neste projeto, o Ralph Loop deve usar como fontes normativas locais:

- `docs/requisitos/epico-requisitos-de-negocio.md`
- `docs/requisitos/epico-requisitos-nao-funcionais.md`
- `docs/spec-driven-development/padroes-de-testes.md`
- `docs/spec-driven-development/codigo-limpo.md`
- `docs/spec-driven-development/padrões-de-projeto-e-design-de-codigo.md`
- `.agents/workflows/start-work.md`

Estas fontes substituem referências genéricas a `AGENTS.md`, Jira e workflows auxiliares que não existem mais neste
repositório.

### Regra de Prioridade

Ao operar neste projeto:

1. o workflow `.agents/workflows/start-work.md` define o fluxo oficial de início
2. `docs/requisitos/epico-requisitos-de-negocio.md` define escopo funcional, regras de negócio e valor da V1
3. `docs/requisitos/epico-requisitos-nao-funcionais.md` define RNFs, segurança, operação, arquitetura e qualidade
4. `docs/spec-driven-development/padroes-de-testes.md` define as exigências de testes
5. `docs/spec-driven-development/codigo-limpo.md` define as regras de nomenclatura e clareza
6. `docs/spec-driven-development/padrões-de-projeto-e-design-de-codigo.md` define SOLID e uso de patterns

Se houver divergência entre uma instrução genérica desta skill e os documentos acima, os documentos do projeto
prevalecem.

### Regra Universal de Código Limpo

Toda demanda iniciada pelo Ralph Loop deve aplicar `docs/spec-driven-development/codigo-limpo.md` desde o planejamento até a
revisão final.

Esta regra vale para:

- backend
- frontend
- mobile
- testes unitários
- testes de integração
- testes funcionais/E2E
- testes de widget/mobile
- scripts, seeders, fixtures, helpers, workflows e configuração como código

O Executor deve escrever código e testes com nomes explícitos, sem abreviações, sem economia artificial de palavras e
com testes no padrão `GIVEN`, `WHEN`, `THEN`. QA, Arquiteto e Final Reviewer devem reprovar qualquer entrega que viole
essa regra.

## Regra de Execução Cronológica Neste Projeto

O Ralph Loop deve tratar o projeto como uma fila cronológica de histórias.

A fonte oficial dessa fila é:

- `docs/jira-pessoal/KANBAN-OFICIAL.md`

### Regra obrigatória

Você não pode iniciar nem executar uma história fora de ordem se existir história anterior ainda não concluída.

### Modo de execução contínua

Quando o usuário pedir a execução sequencial do projeto:

1. o `product-manager` escolhe a próxima história elegível no kanban
2. o Ralph Loop executa a história até `DONE`
3. QA, SRE, Segurança, Arquitetura e revisão final comprovam que a história está realmente pronta para continuidade
4. o `product-manager` documenta a entrega e atualiza o kanban
5. o `git-operator` executa o staging seletivo, o commit isolado da história e a tag semântica no mesmo ciclo
6. o orquestrador valida que commit e tag apontam para o mesmo hash
7. o orquestrador inicia automaticamente a próxima história elegível
8. isso continua até a última história prevista no kanban do WorkLink V1

### Hard Gate Entre Histórias

É proibido iniciar uma nova história se a história anterior ainda não estiver comprovadamente funcionando.

Neste projeto, "funcionando" significa:

- critérios de aceite atendidos
- código e testes aderentes a `docs/spec-driven-development/codigo-limpo.md`
- testes obrigatórios da história aprovados
- comportamento principal validado end-to-end quando aplicável
- documentação final da história criada
- kanban atualizado de forma coerente
- commit da história criado
- tag semântica criada sobre o mesmo commit da história

## Mapa de Invocação de Skills Auxiliares

Neste projeto, os subagentes do `ralph-loop` devem invocar skills auxiliares de forma explícita:

- `executor-agent`
    - `java/code-style` para compilação, consistência e build local
    - `java/test-runner` para testes unitários, funcionais e coverage locais
    - `git-operator` para commits de refresh de contexto quando necessário

- `qa-agent`
    - `java/code-style` para validar lint, compilação e build
    - `java/test-runner` para validar testes unitários, integração, funcionais e coverage
    - `sonar-runner` quando houver configuração real de Sonar no projeto

- `sre-agent`
    - valida ambiente reproduzível, Docker Compose, Makefile, env vars, CI/CD, health/readiness, observabilidade e disponibilidade
    - invoca `ralph-loop/mobile-infra-specialist-agent` quando houver Android, iOS, emuladores, assinatura, lojas, homologação mobile, artifact governance mobile ou custo de CI/CD mobile

- `security-specialist-agent`
    - coordena revisão de segurança, autenticação, autorização, LGPD, autenticidade e rastreabilidade
    - chama `security-guardian` para auditoria local sobre o diff acumulado

- `architect-reviewer-agent`
    - `security-guardian` como apoio quando a revisão arquitetural tocar pontos sensíveis de segurança

- `orquestrator`
    - `git-operator` para checkpoints de contexto quando o loop exigir persistência de estado

### Regra obrigatória

Se a decisão de usar uma skill auxiliar for necessária para concluir um gate, o subagente correspondente deve invocá-la.

Não é aceitável deixar um gate incompleto por falta de chamada explícita da skill apropriada.

## ⛔ 0. Pré-requisito (Invocação Direta)

> [!CAUTION]
> O Ralph Loop **depende** de artefatos criados pelo workflow `.agents/workflows/start-work.md` (branch, `TASK.md`,
`IMPLEMENTATION.md` com frontmatter, documentos do projeto lidos, Pattern Enforcer executado).
>
> **Se `docs/tasks/<KEY>/IMPLEMENTATION.md` NÃO existir**, o Ralph Loop **NÃO pode operar**. Neste caso:
> 1. Informe o usuário: _"O Ralph Loop precisa de um plano de execução para funcionar. Vou iniciar o
     workflow `start-work` primeiro."_
> 2. Execute o workflow `.agents/workflows/start-work.md` com `RALPH_LOOP=true`.
> 3. Após o `start-work` concluir (plano aprovado, frontmatter adicionado), retorne aqui e inicie o ciclo.

## 🛠️ 1. O Ponto de Verdade (State Machine)

Toda a sua inteligência deve residir e ser lida do arquivo `docs/tasks/<KEY>/IMPLEMENTATION.md`.

- **Frontmatter YAML**: Use-o para rastrear a `phase`, `loop_iteration`, `exit_bar`, `metrics` e a `correction_queue`.
- **Persistência**: **Antes** de cada ação, leia o arquivo. **Após** cada ação, atualize-o.
- **Template**: Ative a sub-skill `ralph-loop/execution-plan` com `generate` para adicionar o frontmatter YAML ao
  `IMPLEMENTATION.md` existente.

> [!IMPORTANT]
> O `IMPLEMENTATION.md` é a **única fonte de verdade**. Se não estiver no `.md`, não aconteceu. Este arquivo unifica o
> plano técnico (corpo) e a state machine (frontmatter YAML), eliminando redundâncias.

### Persistência complementar

Para respeitar o conceito formal do Ralph Loop, a memória operacional desta história também deve considerar:

- `docs/tasks/<KEY>/progress.txt`

Função do `progress.txt`:

- registrar tentativas
- registrar falhas relevantes
- registrar hipóteses de correção
- servir como memória curta e objetiva entre janelas

## 🔄 2. O Ciclo do Ralph Loop

Siga este fluxo iterativo até que a Exit Bar esteja 100% `PASS`.

### Regra de Janela Finita

O Ralph Loop deste projeto não deve operar como loop infinito cego dentro da mesma janela de contexto.

Ele deve operar em:

- janelas finitas de iteração
- com rotação de contexto
- com retomada a partir dos artefatos persistidos

Em termos práticos:

- a execução de uma janela tem limite
- ao atingir o limite ou a zona de degradação, o estado deve ser persistido
- a próxima janela recomeça a partir do disco, e não de memória conversacional acumulada

### PERCEBER & ORIENTAR

Leia o status atual dos gates na `exit_bar`. Classifique os gaps por severidade:

- 🔴 `CRITICAL` (items na `correction_queue`) → Resolução imediata.
- 🟠 `FAIL` (gates falhando) → Correção necessária.
- 🟡 `PENDING` (gates não validados) → Precisam de validação.
- 🟢 `PASS` → Nenhuma ação.
- ⚪ `N/A` → Gate não aplicável (ex: `func_tests` em projeto sem testes funcionais).

> [!CAUTION]
> **Status Válidos**: Os ÚNICOS status permitidos são: `PASS`, `FAIL`, `PENDING`, `N/A`.
> **Status PROIBIDOS**: `SKIP`, `ABORTED`, `SKIPPED`, ou qualquer outro inventado pelo agente. Se um gate não pode ser
> executado localmente, o status é `N/A` com justificativa documentada no Log de Iterações, e o Orquestrador DEVE validar
> com o humano se `N/A` é aceitável.
> **Regra: SKIP = FAIL**. Se o agente marcar qualquer gate como SKIP, o Orquestrador DEVE tratá-lo como FAIL e adicionar
> ao `correction_queue`.

#### 🧪 Functional Test Discovery (Obrigatório na primeira iteração)

Na **primeira iteração** (`loop_iteration == 0`), **ANTES** de qualquer outra ação, execute a detecção de testes
funcionais:

1. **Varrer o projeto** buscando evidências de infraestrutura de testes funcionais:
    - **Diretórios**: `src/test/functional`, `src/test-functional`, `test/functional`, `tests/functional`, `features/`,
      `specs/`, `**/functional/**`, `__functional_test__`
    - **Arquivos**: `*FunctionalTest*`, `*IT.java`, `*IntegrationTest*`, `*.feature`, `*_functional_*`, `*FuncTest*`
    - **Configurações de runner**: `failsafe` (maven-failsafe-plugin), `cucumber`, `jest --config functional`,
      `playwright`, `cypress`

2. **Persistir no frontmatter** do `IMPLEMENTATION.md`:
   ```yaml
   func_tests_detected: true   # ou false
   func_tests_path: "<caminho detectado>"
   func_tests_framework: "<framework detectado>"
   ```

3. **Consequência**:
    - Se `func_tests_detected: true` → o gate `func_tests` é **OBRIGATÓRIO**. O Executor DEVE criar testes BDD e o QA
      DEVE validá-los.
    - Se `func_tests_detected: false` → o gate `func_tests` recebe status `N/A` (não bloqueia a Exit Bar).

### DECIDIR

```
ÁRVORE DE DECISÃO (em ordem de prioridade):

1. Se correction_queue tem itens OPEN:
   → Invocar Agente_Executor (ralph-loop/executor-agent)

2. Se gates de teste/qualidade (lint, unit_tests, integration_tests, func_tests, mobile_tests, coverage, sonar) em PENDING ou FAIL:
   → Invocar Agente_QA (ralph-loop/qa-agent)

3. Se gates de teste/qualidade == PASS, mas sre == PENDING ou FAIL:
   → Invocar Agente_SRE (ralph-loop/sre-agent)

4. Se gates de teste/qualidade E sre == PASS/N/A, mas security == PENDING ou FAIL:
   → Invocar Agente_Especialista_Seguranca (ralph-loop/security-specialist-agent)
   → O especialista coordena o Security_Guardian (security-guardian) sobre git diff origin/main..HEAD quando aplicável
   → Se Risk Score > 50 ou findings CRITICAL/HIGH:
     → Adicionar ao correction_queue com origin: security, severity: CRITICAL
     → exit_bar.security = FAIL → Volta para o Executor (passo 1)
   → Se Risk Score ≤ 50 e zero findings CRITICAL/HIGH:
     → exit_bar.security = PASS

5. Se gates de teste/qualidade e sre estão PASS/N/A, security == PASS, mas arch_review == PENDING:
   → Invocar Agente_Arquiteto_Revisor (ralph-loop/architect-reviewer-agent)

6. Se gates de teste/qualidade e sre estão PASS/N/A, security == PASS e arch_review == PASS, mas final_review == PENDING:
   → Invocar Agente_Final_Reviewer (ralph-loop/final-reviewer-agent)

7. Se TODOS os gates obrigatórios == PASS e gates não aplicáveis == N/A:
   → Invoque `ralph-loop/product-manager` para finalizar a documentação cronológica
   → Invoque `git-operator` para executar o fechamento real da história
   → Valide que o commit da entrega e a tag semântica apontam para o mesmo hash
   → Só então encerre o ciclo e apresente o fechamento técnico ao usuário
```

### AGIR (Delegar aos Subagentes)

Leia a skill do subagente escolhido ANTES de executar seu papel:

| Subagente                 | Skill                                 | Papel                                                                                                                                                       | Regra de Ouro                                                            |
|---------------------------|---------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------|
| 🔧 **Executor**           | `ralph-loop/executor-agent`           | Implementa código e resolve a fila de erros. Roda testes unitários locais antes de retornar.                                                                | Usa **TDD**: teste primeiro, implementação depois.                       |
| 🔍 **QA**                 | `ralph-loop/qa-agent`                 | Roda suítes completas, valida coverage, testes unitários, integração, funcionais/mobile e boas práticas de testes/código.                                   | **NUNCA** corrige código.                                                |
| 🧭 **SRE**                | `ralph-loop/sre-agent`                | Valida ambiente reproduzível, configuração, CI/CD, health/readiness, observabilidade, disponibilidade e prontidão operacional.                              | **NUNCA** corrige código ou infraestrutura.                              |
| 🛡️ **Segurança**         | `ralph-loop/security-specialist-agent`| Valida autenticação, autorização, autenticidade, LGPD, proteção de dados e coordena o Security Guardian.                                                     | **NUNCA** corrige código.                                                |
| 🛡️ **Security Guardian** | `security-guardian`                   | Auditoria OWASP local acionada pelo especialista de segurança. Analisa diff acumulado com Diff Risk Scoring e bloqueia vulnerabilidades.                    | **NUNCA** corrige código. Apenas reporta findings com CWE e action plan. |
| 🏛️ **Arquiteto**         | `ralph-loop/architect-reviewer-agent` | Banca final de Monólito Modular, DDD tático, Ports and Adapters, SOLID, Segurança, Manutenibilidade e KISS/YAGNI.                                           | Se `REJECTED` ou `NEEDS_CHANGES` → Volta para o Executor corrigir.       |
| ✅ **Final Reviewer**      | `ralph-loop/final-reviewer-agent`     | Revisão holística pré-saída: cruza critérios × código × testes × documentação.                                                                              | Se `REJECTED` → Volta para o Executor corrigir.                          |
| 🐞 **Bug Investigator**   | `bug-investigator`                    | Análise de causa raiz para tickets do tipo Bug ou regressões detectadas no loop. Invocado **antes** do Executor quando o erro requer investigação profunda. | Diagnostica, **nunca** corrige diretamente.                              |
| 📦 **Product Manager**    | `ralph-loop/product-manager`          | Cria o `IMPLEMENTATION.md` da história a partir da spec e, ao final, documenta a entrega cronológica e prepara o fechamento semântico da versão.            | Não implementa código.                                                   |

### REGISTRAR

Após cada retorno de subagente:

1. Atualize o **log de iterações** no corpo do `IMPLEMENTATION.md`.
2. Incremente `loop_iteration`.
3. Atualize `exit_bar` com os resultados.
4. Limpe/adicione itens na `correction_queue` conforme o retorno dos agentes.
5. Atualize `metrics` (gates_failed_count, first_pass_gates, etc.).
6. Commit parcial a cada 3 ciclos.
7. Atualize a seção **"Aprendizados do Loop"** se houve gotchas ou descobertas relevantes.
8. No fechamento da história, registre explicitamente no `IMPLEMENTATION.md` o hash do commit da entrega e a tag
   semântica criada.

## 📊 3. Critérios de Saída (The Exit Bar)

Você **só** tem permissão para invocar a skill `/finish-work` quando o frontmatter do `IMPLEMENTATION.md` apresentar **rigorosamente**:

```yaml
exit_bar:
  lint:          PASS     # Zero erros ESLint/Checkstyle
  unit_tests:    PASS     # Máxima cobertura, todos passando
  integration_tests: PASS  # Integrações aplicáveis passando (ou N/A se não aplicável/configurado)
  func_tests:    PASS     # Todos cenários BDD passando (ou N/A se func_tests_detected: false)
  mobile_tests:  PASS     # Testes mobile aplicáveis passando (ou N/A se não há app/escopo mobile)
  sonar:         PASS     # Zero violações Critical/Blocker (ou N/A se sem Sonar no projeto)
  coverage:      PASS     # Máxima cobertura de testes (ou N/A se sem ferramenta no projeto)
  sre:           PASS     # Ambiente/operação/CI/observabilidade aprovados (ou N/A se não aplicável)
  security:      PASS     # Especialista de segurança + Security Guardian local aprovados
  arch_review:   PASS     # Banca de revisão aprovada
  final_review:  PASS     # Revisão holística pré-saída aprovada
```

> [!IMPORTANT]
> O gate `func_tests` aceita `N/A` **somente** quando `func_tests_detected: false` no frontmatter. Se o projeto TEM
> testes funcionais, o gate é obrigatório e DEVE ser `PASS`.

> [!CAUTION]
> **Validação Programática de Saída**: Antes de invocar `/finish-work`, o Orquestrador **DEVE reler o frontmatter
completo** e validar que TODOS os gates são `PASS` (ou `N/A` onde permitido). Se qualquer gate não for PASS/N/A, a
> invocação é **BLOQUEADA** e logada como "⚠️ Tentativa de saída prematura bloqueada — gate `<X>` em status `<Y>`". **SKIP
não é status válido** — se encontrado, tratar como FAIL.

> [!CAUTION]
> **Security é LOCAL e INEGOCIÁVEL**: O `security-specialist-agent` deve coordenar o `security-guardian` sobre
> `git diff origin/main..HEAD` no ambiente local quando houver diff aplicável. Ele **NÃO** depende de CI/Jenkins/Pipeline.
> Marcar security como SKIP/N/A é **PROIBIDO** — o gate DEVE ser executado e DEVE ser `PASS` para sair do loop.

> [!CAUTION]
> **Critérios de Aceitação**: TODOS os critérios do ticket devem estar marcados como `[x]` no `IMPLEMENTATION.md`. Se
> faltar um, o ticket NÃO está pronto.

## ⚠️ 4. Regras de Controle e Segurança

| Regra                                 | Descrição                                                                                                                                                                                                                                              |
|---------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Loop com Janela Finita**            | O loop deve continuar até convergir, mas cada janela de execução é finita. Ao atingir o limite de iterações ou a zona de degradação, persista o estado e reinicie com contexto fresco.                                                                 |
| **Aprovação de Plano**                | Antes de iniciar o primeiro loop de código, apresente o Plano Técnico ao humano e aguarde o "OK". (Única parada permitida).                                                                                                                            |
| **Separação de Concerns**             | NUNCA permita que o Executor marque um gate como `PASS`; QA, SRE, Segurança, Arquiteto e Final Reviewer só aprovam os gates de sua própria responsabilidade.                                                                                           |
| **Escalamento do Arquiteto**          | Se o Arquiteto retornar `REJECTED` ou `NEEDS_CHANGES`, adicione os findings na `correction_queue` para o Executor e mantenha `arch_review = FAIL`. O loop CONTINUA.                                                                                    |
| **Consistência**                      | O arquivo `IMPLEMENTATION.md` é a única fonte de verdade. Toda decisão e resultado deve estar registrado.                                                                                                                                              |
| **Persistência em Disco**             | `IMPLEMENTATION.md` e `progress.txt` são a memória do loop. O agente não pode depender de memória implícita da sessão.                                                                                                                                 |
| **TDD Obrigatório**                   | O Executor DEVE escrever testes ANTES da implementação. Código sem teste = FAIL.                                                                                                                                                                       |
| **Código Limpo Universal**            | Toda produção, teste, frontend, backend, mobile, script, fixture, seeder, helper e workflow deve seguir `docs/spec-driven-development/codigo-limpo.md`. Nome ruim, abreviação, classe genérica, método vago ou teste sem `GIVEN/WHEN/THEN` gera FAIL.       |
| **BDD para Funcionais (Obrigatório)** | Quando `func_tests_detected: true`, cada critério de aceitação **DEVE** ter cenário BDD (Given/When/Then). O gate `func_tests` **FALHA** se existem critérios sem teste funcional correspondente. Quando `func_tests_detected: false`, o gate é `N/A`. |
| **Functional Test Discovery**         | Na primeira iteração, o Orquestrador **DEVE** executar a detecção de testes funcionais e persistir o resultado no frontmatter do `IMPLEMENTATION.md`. Sem essa detecção, o loop NÃO pode avançar.                                                      |
| **Anti-Reward Hacking**               | O Executor é **PROIBIDO** de deletar, comentar, desabilitar (`@Ignore`, `skip`, `xdescribe`) ou enfraquecer asserções existentes para fazer testes passarem. O QA DEVE verificar isso comparando asserções antes/depois via `git diff`.                |
| **Fresh Context**                     | A partir da degradação de contexto, o loop deve preferir reinício com leitura limpa dos artefatos.                                                                                                                                                     |

## 📂 5. Sub-skills

| Sub-skill           | Caminho                               | Quando usar                                                                                                    |
|---------------------|---------------------------------------|----------------------------------------------------------------------------------------------------------------|
| Plano de Execução   | `ralph-loop/execution-plan`           | Fase 2 — Adicionar frontmatter YAML ao `IMPLEMENTATION.md`                                                     |
| Guardião de Padrões | `ralph-loop/pattern-enforcer`         | Fase 2 — Poda over-engineering e garante pragmatismo                                                           |
| Product Manager     | `ralph-loop/product-manager`          | Antes do loop — criar `IMPLEMENTATION.md`; após aprovação — documentar entrega e preparar fechamento semântico |
| Orquestrador        | `ralph-loop/orquestrator`             | Detalhes do protocolo de 5 passos                                                                              |
| Executor            | `ralph-loop/executor-agent`           | Quando o loop decide codar/corrigir                                                                            |
| QA                  | `ralph-loop/qa-agent`                 | Quando o loop decide validar                                                                                   |
| SRE                 | `ralph-loop/sre-agent`                | Quando testes/qualidade estão PASS — validação operacional, CI/CD, ambiente e observabilidade                  |
| Segurança           | `ralph-loop/security-specialist-agent`| Quando testes/qualidade e SRE estão PASS/N/A — valida segurança, LGPD, autenticação e coordena security-guardian |
| Security Guardian   | `security-guardian`                   | Acionado pelo especialista de segurança para auditoria OWASP local                                             |
| Arquiteto           | `ralph-loop/architect-reviewer-agent` | Quando testes e SRE estão PASS/N/A, e security está PASS                                                       |
| Final Reviewer      | `ralph-loop/final-reviewer-agent`     | Quando TODOS os gates anteriores estão PASS — revisão holística pré-saída                                      |
