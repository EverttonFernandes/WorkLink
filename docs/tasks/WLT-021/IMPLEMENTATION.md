# WLT-021 — Análise estática avançada backend

**Story**: [WLT-021-analise-estatica-avancada-backend.md](../../jira-pessoal/historias-tecnicas/WLT-021-analise-estatica-avancada-backend.md)

**Versão**: MINOR

**Status**: DONE

---

## Objetivo

Completar o gate de qualidade estática do backend com SpotBugs, PMD e integração SonarCloud, mantendo coerência com o pipeline atual e sem criar engenharia desnecessária.

## Escopo

- Configurar SpotBugs no `worklink-api/pom.xml`.
- Configurar PMD no `worklink-api/pom.xml`.
- Ajustar `make backend-static-analysis`.
- Ajustar CI para refletir o novo gate estático.
- Registrar dependências externas de SonarCloud sem acoplar o build local a segredos ausentes.

## Fora do Escopo

- SonarQube self-hosted.
- Reescrita ampla das regras de qualidade já existentes.
- Expansão do gate mobile além do `flutter analyze`.

## Plano

### Fase 1 — Descoberta

- [x] Levantar o estado atual do `pom.xml`, `Makefile` e `.github/workflows/ci.yml`.
- [x] Identificar a forma mais simples de encaixar SpotBugs e PMD no ciclo existente.
- [x] Confirmar como SonarCloud será tratado sem quebrar execução local.

### Fase 2 — Implementação

- [x] Configurar SpotBugs com threshold conservador.
- [x] Configurar PMD com ruleset compatível com o código atual.
- [x] Ajustar Makefile e CI.

### Fase 3 — Gates

- [x] Validar análise estática backend local.
- [x] Validar impacto no pipeline.
- [x] Atualizar documentação da entrega.

## Implementação realizada

- Adicionados os plugins `spotbugs-maven-plugin` e `maven-pmd-plugin` em [worklink-api/pom.xml](/home/umov/Documents/ProjetosPessoais/WorkLink/worklink-api/pom.xml), ambos executando na fase `verify`.
- Criado o filtro [worklink-api/config/spotbugs/include-correctness-security.xml](/home/umov/Documents/ProjetosPessoais/WorkLink/worklink-api/config/spotbugs/include-correctness-security.xml) para bloquear apenas categorias `CORRECTNESS` e `SECURITY`.
- Criado o ruleset [worklink-api/config/pmd/worklink-backend-ruleset.xml](/home/umov/Documents/ProjetosPessoais/WorkLink/worklink-api/config/pmd/worklink-backend-ruleset.xml) com `errorprone` e `bestpractices`.
- Atualizado o alvo [Makefile](/home/umov/Documents/ProjetosPessoais/WorkLink/Makefile) `backend-static-analysis` para executar `compile`, `test-compile`, `checkstyle:check`, `spotbugs:check` e `pmd:check`.
- Atualizado [.github/workflows/ci.yml](/home/umov/Documents/ProjetosPessoais/WorkLink/.github/workflows/ci.yml) para rodar o novo gate e acionar SonarCloud apenas quando os segredos/variáveis estiverem configurados.
- Anotados os ports funcionais de método único com `@FunctionalInterface` para manter coerência com o threshold do PMD sem abrir exceções desnecessárias no ruleset.

## Validações executadas

- `make backend-static-analysis`
- `make backend-unit-test`
- `make backend-integration-test`

## Exit Bar

```yaml
exit_bar:
  lint: PASS
  unit_tests: PASS
  integration_tests: PASS
  mobile_tests: N/A
  coverage: PASS
  security: PASS
  sre: PASS
  arch_review: PASS
  final_review: PASS
```
