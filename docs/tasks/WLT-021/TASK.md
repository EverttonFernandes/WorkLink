# WLT-021 — Análise estática avançada backend

**Story**: [WLT-021-analise-estatica-avancada-backend.md](../../jira-pessoal/historias-tecnicas/WLT-021-analise-estatica-avancada-backend.md)

**Versão**: MINOR

**Status**: DONE

---

## Objetivo

Adicionar SpotBugs, PMD e integração com SonarCloud ao pipeline de qualidade do backend, completando o gate de análise estática previsto para a V1.

## Critérios de aceite resumidos

- `mvn verify` executa Checkstyle, JaCoCo, SpotBugs e PMD.
- `make backend-static-analysis` passa a refletir o gate estático completo.
- CI falha quando SpotBugs ou PMD encontrarem violações acima do threshold.
- SonarCloud recebe análise e cobertura a cada push na branch principal.

## Escopo implementado

- SpotBugs com filtro restrito a `CORRECTNESS` e `SECURITY`.
- PMD com ruleset pragmático para `errorprone` e `bestpractices`.
- Gate local containerizado via `make backend-static-analysis`.
- Passo opcional de SonarCloud na CI, sem acoplamento a segredos ausentes.
