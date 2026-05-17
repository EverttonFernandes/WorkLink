# Entrega WLT-021 — Análise estática avançada backend

## Identificador

- História: `WLT-021`
- Tipo semântico: `MINOR`

## Objetivo técnico

Completar o gate estático do backend com SpotBugs, PMD e integração opcional com SonarCloud, mantendo o build local reproduzível em container e sem acoplar a pipeline a segredos inexistentes.

## O que foi implementado

- `SpotBugs` no [worklink-api/pom.xml](/home/umov/Documents/ProjetosPessoais/WorkLink/worklink-api/pom.xml) executando em `verify`.
- filtro de análise em [worklink-api/config/spotbugs/include-correctness-security.xml](/home/umov/Documents/ProjetosPessoais/WorkLink/worklink-api/config/spotbugs/include-correctness-security.xml) restrito a `CORRECTNESS` e `SECURITY`.
- `PMD` no [worklink-api/pom.xml](/home/umov/Documents/ProjetosPessoais/WorkLink/worklink-api/pom.xml) executando em `verify`.
- ruleset pragmático em [worklink-api/config/pmd/worklink-backend-ruleset.xml](/home/umov/Documents/ProjetosPessoais/WorkLink/worklink-api/config/pmd/worklink-backend-ruleset.xml) com `errorprone` e `bestpractices`.
- atualização do alvo [Makefile](/home/umov/Documents/ProjetosPessoais/WorkLink/Makefile) `backend-static-analysis` para executar `checkstyle`, `spotbugs` e `pmd` em container.
- atualização da pipeline em [.github/workflows/ci.yml](/home/umov/Documents/ProjetosPessoais/WorkLink/.github/workflows/ci.yml) para:
  - usar `fetch-depth: 0`
  - executar o gate estático novo no job backend
  - disparar análise SonarCloud em `push` para `main` apenas quando `SONAR_TOKEN`, `SONAR_ORGANIZATION` e `SONAR_PROJECT_KEY` estiverem configurados.
- anotação explícita `@FunctionalInterface` nos ports de um único método exigidos pelo gate do PMD.

## Regras de qualidade aplicadas

- `SpotBugs`: zero achados nas categorias selecionadas.
- `PMD`: falha somente para prioridades `1` e `2`, com `maxAllowedViolations=0`.
- `JaCoCo`: cobertura mínima do bundle backend mantida em `95%`.

## O que não entrou

- SonarQube self-hosted.
- endurecimento das advertências de prioridade `3` e `4` do PMD nesta história.
- expansão do gate estático do mobile além do fluxo já existente.

## Evidências de validação

- `make backend-static-analysis`: PASS
- `make backend-unit-test`: PASS, `313` testes, cobertura mínima atendida
- `make backend-integration-test`: PASS

## Observações

- A análise SonarCloud não quebra o fluxo local nem a CI quando os segredos ainda não existem; nesse caso o passo é ignorado de forma explícita.
- As advertências remanescentes do PMD ficaram visíveis no relatório, mas fora do threshold de bloqueio definido para esta fase.

## Justificativa do versionamento

Entrega `MINOR` porque amplia o baseline de qualidade do produto e fecha um requisito técnico transversal sem alterar contrato funcional do sistema.
