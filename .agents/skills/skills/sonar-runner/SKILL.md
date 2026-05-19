---
name: sonar-runner
description: Executa a análise estática de código e valida o Quality Gate usando SonarQube Scanner via Docker.
required_env: [SONAR_AUTH_TOKEN]
---

# Adaptação para Este Projeto

Neste projeto, esta skill é complementar.

Ela deve operar em coerência com:

- `docs/requisitos/epico-requisitos-nao-funcionais.md`
- `docs/spec-driven-development/padroes-de-testes.md`
- `docs/spec-driven-development/codigo-limpo.md`
- `docs/spec-driven-development/padrões-de-projeto-e-design-de-codigo.md`
- `docs/jira-pessoal/KANBAN-OFICIAL.md`

## Regra de Uso

O Sonar não é a fonte principal de verdade do projeto.

Neste contexto:

- ele complementa QA
- ele complementa revisão técnica
- ele não substitui testes nem validação funcional
- ele deve evidenciar a cobertura unitária mínima de 95% quando o projeto estiver configurado para publicar coverage no Sonar

## Regra de Aplicabilidade

Se o projeto ainda não estiver realmente configurado para Sonar:

- a análise não deve ser forçada artificialmente
- o gate deve ser tratado como `N/A` com justificativa coerente

Se o projeto estiver configurado:

- a skill deve ser usada como evidência adicional de qualidade antes de liberar continuidade entre histórias
- o Quality Gate deve reprovar quando a cobertura unitária configurada ficar abaixo de 95%
- se o Sonar não receber relatório de coverage, reporte a lacuna para o `qa-agent` e para o `sre-agent`

# Capacidade: Configuração Inicial (`configure`)

Script interativo para configurar seu token do SonarQube globalmente na máquina.

## Execução

- **IMPORTANTE:** Para questões de segurança de validade, **sempre rode este script manualmente numa aba de terminal**.
  Não peça à Inteligência Artificial para rodá-lo por você.
- Execute no seu terminal fonteando o estado interativo: `source scripts/configure.sh`
- O script pedirá seu `SONAR_AUTH_TOKEN` de forma oculta e segura, exportando-o com persistência no seu `~/.bashrc`.

---

# Capacidade: Executar Análise (`run-analysis`)

Esta skill executa a análise do Sonar, preferencialmente via Makefile do projeto, ou via Docker direto como fallback.

## Pré-requisitos

1. **Variável `SONAR_AUTH_TOKEN`**: Obrigatória (Token de autenticação).
2. **Variável `SONAR_HOST_URL`**: Opcional. Padrão: `https://dese-metrics.umov.me/`.
3. **Project Key**: Auto-descoberta via `sonar-project.properties`.
4. **Runtime Node.js**: Obrigatório para execução dos scripts de diagnóstico (`node`).
5. **Docker**: Obrigatório para execução do scanner (`sonarsource/sonar-scanner-cli`).

## Instrução para o Agente

1. **Validação de Ambiente (CRÍTICO)**:
    - Verifique se a variável de ambiente `SONAR_AUTH_TOKEN` está acessível no shell (`printenv SONAR_AUTH_TOKEN` ou
      similar).
    - **NÃO** tente ler arquivo `.env`. O Agente deve confiar no ambiente.
    - Se a variável estiver vazia:
        - 🛑 **PARE A EXECUÇÃO** (ou pule se for opcional no workflow).
        - Warn: "Variável `SONAR_AUTH_TOKEN` não encontrada no ambiente."

2. **Validação de Configuração**:
    - Verifique se o arquivo `sonar-project.properties` existe na raiz.
    - **Se NÃO existir**:
        - 🛑 **PARE A EXECUÇÃO**.
        - Notifique o usuário: "O arquivo `sonar-project.properties` é obrigatório para a validação. Por favor, crie-o
          definindo `sonar.projectKey`."

### Regra adicional deste projeto

Quando usada pelo `qa-agent`, a ausência real de configuração de Sonar deve ser comunicada de forma objetiva para que o
gate seja tratado como `N/A`, e não como falha fictícia.

Quando o Sonar estiver configurado, cobertura unitária abaixo de 95% deve ser tratada como falha real do gate de qualidade.

3. **Verificação de Método de Execução**:
    - Verifique se existe um arquivo `Makefile` e se ele contém o target `sonar-scanner`:
      `grep -q "^sonar-scanner:" Makefile`
4. **Execução (Prioridade - Makefile)**:
    - Se o target existir, execute:
      ```bash
      SONAR_APP_VERSION=$(git rev-parse --short HEAD)
      if [ -n "$(git status --porcelain)" ]; then
        SONAR_APP_VERSION="${SONAR_APP_VERSION}-wip"
      fi
      export SONAR_APP_VERSION
      make sonar-scanner
      ```
      _Certifique-se que as variáveis de ambiente `SONAR_AUTH_TOKEN` e `SONAR_HOST_URL` estão exportadas._

5. **Execução (Fallback - Docker)**:
    - Se não houver Makefile ou target, use o comando Docker direto (Use a imagem **v11** paritária ao Jenkins):

   ```bash
   # Define Version (Hash + Dirty flag)
   SONAR_VERSION=$(git rev-parse --short HEAD)
   if [ -n "$(git status --porcelain)" ]; then
     SONAR_VERSION="${SONAR_VERSION}-wip"
   fi

   # Primeiro descubra o Project Key no sonar-project.properties (se houver)
   # Depois execute:
   docker run --rm \
       -e SONAR_HOST_URL="${SONAR_HOST_URL:-https://dese-metrics.umov.me/}" \
       -e SONAR_LOGIN="$SONAR_AUTH_TOKEN" \
       -v "$(pwd):/usr/app" \
       -w /usr/app \
       sonarsource/sonar-scanner-cli:11 \
       sonar-scanner \
       -Dproject.settings=sonar-project.properties \
       -Dsonar.projectVersion="$SONAR_VERSION"
   ```

## Tratamento de Erro e Diagnóstico

Se o comando falhar (Exit Code != 0), o Agente **DEVE** investigar o motivo:

1. **Gerar Relatório Completo**:
   Execute o script com o modo `report` para criar um artefato consolidado:

   ```bash
   node scripts/diagnose.js <PROJECT_KEY> report
   ```

   Isso criará o arquivo `reports/quality-report.md` com:
    - Status do Quality Gate.
    - Bloqueadores Críticos (ex: Cobertura em New Code).
    - Top Issues (Tech Debt).

2. **Análise Focada (Opcional)**:
   Se precisar de dados brutos específicos, use os modos individuais:
    - `status`: Apenas veredito.
    - `new-coverage`: Lista de arquivos sem cobertura nova.
    - `coverage`: Baixa cobertura geral.
    - `duplication`: Códigos duplicados.
    - `issues`: Lista de code smells.

---

# Capacidade: Analisar Quality Gate (`analyze-gate`)

Esta capacidade analisa **remotamente** um Quality Gate quebrado no SonarQube, sem necessidade de ter o projeto clonado
localmente. Ela identifica as condições falhadas, busca os dados de arquivo correspondentes e gera um relatório
acionável com plano de ação priorizado.

## Quando Usar

- Quando o usuário informar uma URL do SonarQube (ex: `https://dese-metrics.umov.me/dashboard?id=<PROJECT_KEY>`).
- Quando um build falhou por Quality Gate e é preciso entender o que corrigir.
- Na triagem de dívida técnica de um projeto.
- Na revisão de código para avaliar cobertura de testes.

## Pré-requisitos

1. **Variável `SONAR_AUTH_TOKEN`**: Obrigatória.
2. **Variável `SONAR_HOST_URL`**: Opcional. Padrão: `https://dese-metrics.umov.me/`.
3. **Runtime Node.js**: Obrigatório para execução do script.
4. **Project Key**: Extraído da URL do dashboard (`?id=<PROJECT_KEY>`) ou informado diretamente.

## Instrução para o Agente

1. **Extrair o Project Key**:
    - Se o usuário informou uma URL, extraia o `PROJECT_KEY` do parâmetro `id` da query string.
    - Se informou diretamente (ex: `umovme-write-actions-api`), use como está.

2. **Validar Ambiente**:
    - Verifique se `SONAR_AUTH_TOKEN` está acessível (`printenv SONAR_AUTH_TOKEN`).
    - Se não estiver: 🛑 **PARE** e notifique.

3. **Executar Análise**:

   ```bash
   node scripts/analyze_gate.js <PROJECT_KEY>
   ```

4. **Interpretar Resultado**:
    - O script gera o relatório em `reports/gate-analysis.md`.
    - **Leia o relatório** e apresente ao usuário com:
        - Resumo do status do Quality Gate.
        - Condições falhadas e seus thresholds.
        - Top arquivos ofensores com impacto calculado.
        - Plano de ação priorizado (o que corrigir primeiro para maior impacto).

5. **Ações Recomendadas (se aplicável)**:
    - Se o projeto estiver clonado localmente, ofereça **corrigir** os problemas.
    - Para bugs/vulnerabilidades: localize o código e proponha fix.
    - Para cobertura: sugira quais testes criar/melhorar.
    - Para duplicações: sugira refatorações.

---

# Capacidade: Gerenciar Quality Gate (`manage-gate`)

Esta capacidade permite **identificar, criar, modificar e associar** Quality Gates no SonarQube via API. Operações de
escrita são dry-run por padrão — o agente deve confirmar com o usuário antes de executar.

## Quando Usar

- Quando o usuário quiser saber qual Quality Gate está configurado no projeto.
- Quando for necessário criar um Quality Gate dedicado para o projeto.
- Para ajustar thresholds de condições existentes.
- Para adicionar novas métricas ao Quality Gate.

## Pré-requisitos

1. **Variável `SONAR_AUTH_TOKEN`**: Obrigatória (com permissão de admin).
2. **Project Key**: Identificador do projeto no SonarQube.

## Instrução para o Agente

1. **Inspecionar o gate atual**:

   ```bash
   node scripts/manage_gate.js <PROJECT_KEY> inspect
   ```

    - Saída JSON: adicione `--json`.
    - **ATENÇÃO**: se o projeto usar o gate **padrão do sistema**, alerte o usuário que alterá-lo afetará TODOS os
      projetos. Recomende criar um dedicado.

2. **Criar gate dedicado (se necessário)**:
    - Criar vazio:
      ```bash
      node scripts/manage_gate.js <PROJECT_KEY> create --name "QG NomeProjeto" --execute
      ```
    - Copiar gate existente (preserva condições):
      ```bash
      node scripts/manage_gate.js <PROJECT_KEY> copy --source "QG Origem" --name "QG Novo" --execute
      ```
      _Ambos os comandos também associam automaticamente o gate ao projeto._

3. **Gerenciar condições**:
    - **Adicionar**:
      ```bash
      node scripts/manage_gate.js <PROJECT_KEY> add-condition --metric coverage --op LT --error 80 --execute
      ```
      Operadores: `LT` (mínimo), `GT` (máximo).
    - **Editar** (use o ID da condição via `inspect`):
      ```bash
      node scripts/manage_gate.js <PROJECT_KEY> update-condition --id <CONDITION_ID> --error 75 --execute
      ```
    - **Remover**:
      ```bash
      node scripts/manage_gate.js <PROJECT_KEY> remove-condition --id <CONDITION_ID> --execute
      ```

4. **Associar gate existente ao projeto**:

   ```bash
   node scripts/manage_gate.js <PROJECT_KEY> assign --gate "QG Nome" --execute
   ```

5. **Regras de Segurança**:
    - **SEMPRE** execute primeiro sem `--execute` (dry-run) e mostre ao usuário o que vai acontecer.
    - **NUNCA** modifique o gate padrão sem criar um dedicado antes.
    - **NUNCA** execute operações de escrita sem confirmação explícita do usuário.
