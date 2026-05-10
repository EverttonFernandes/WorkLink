# Entrega WLT-021 — Análise estática avançada backend

## Identificador

- História: `WLT-021`
- Data: `2026-05-10`
- Tipo semântico sugerido: `MINOR`

## Objetivo técnico

Adicionar tools de análise estática avançada (SpotBugs, PMD, SonarQube) ao pipeline backend para detectar bugs potenciais, vulnerabilidades de segurança e violações de padrão antes de build.

## Contexto

Atualmente o backend usa apenas Checkstyle e JaCoCo. Este gatilho adiciona camadas de análise para segurança, performance e qualidade.

## Requisitos técnicos atendidos

- Detecção de bugs potenciais (SpotBugs).
- Violações de código quality (PMD).
- Vulnerabilidades conhecidas (SonarQube via scan cloud).
- Gate de qualidade com thresholds.

## O que foi implementado

- **SpotBugs**:
  - Adicionar plugin ao `worklink-api/pom.xml`.
  - Configurar excludes para false positives conhecidos.
  - Executar durante build: `mvn clean verify`.

- **PMD**:
  - Adicionar plugin ao pom.xml.
  - Configurar rulesets: security, performance, codestyle.
  - Gate com threshold: max 50 violations.

- **SonarQube**:
  - Configuração em CI/CD: adicionar scanner GitHub action.
  - Conectar com SonarCloud (conta pública).
  - Gate de qualidade: Ap mínimo, sem bloqueadores de segurança.

- **Makefile target**: `make backend-static-analysis-advanced`.
- **CI/CD job**: Executado em cada push (falha se thresholds não atendidos).

## O que não foi implementado

- SonarQube self-hosted (apenas cloud).
- Integração com GitHub Reviews automáticas.
- Dashboard visual de tendências de qualidade.

## Fluxos, telas, endpoints ou módulos envolvidos

- `worklink-api/pom.xml` — dependências de plugins.
- `.github/workflows/ci.yml` — job de análise avançada.
- Makefile target: `backend-static-analysis-advanced`.

## Estratégia de testes

- Local: `mvn clean verify` com SpotBugs e PMD ativo.
- CI/CD: job executa em cada push e valida thresholds.
- SonarCloud: resultado visível em dashboard online.

## Evidências de validação

- `mvn spotbugs:check`: PASS (sem bugs críticos).
- `mvn pmd:check`: PASS (viola sob 50).
- SonarCloud report: Grade A ou superior.
- CI/CD job completa sem bloqueio.

## Riscos ou limitações remanescentes

- SpotBugs e PMD podem gerar false positives (requer tuning de excludes).
- SonarCloud requer account setup e credenciais em CI/CD.
- Análise pode aumentar tempo de build em ~2-3min.

## Arquivos ou módulos relevantes

- `worklink-api/pom.xml` — configuração plugins.
- `.github/workflows/ci.yml` — SonarCloud scan action.
- Makefile: `backend-static-analysis-advanced`.

## Justificativa do versionamento

Entrega `MINOR` porque adiciona validação sem mudança de código. Melhora qualidade geral.
