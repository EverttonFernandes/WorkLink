# WLT-021 — Análise estática avançada backend

## Objetivo

Adicionar SpotBugs, PMD e SonarCloud ao pipeline de qualidade do backend, completando o gate de análise estática previsto no épico técnico.

## Valor técnico

O backend possui apenas Checkstyle e JaCoCo configurados. SpotBugs e PMD detectam classes de bugs e problemas de design que o Checkstyle não cobre. SonarCloud agrega cobertura, duplicação, vulnerabilidades e dívida técnica em visão unificada. Sem eles, o gate de qualidade estática da V1 está incompleto.

## RNFs relacionados

- RNF13, RNF14, RNF03

## Escopo incluído

- Configuração do plugin SpotBugs no `pom.xml` com execução na fase `verify`.
- Configuração do plugin PMD no `pom.xml` com ruleset mínimo e execução na fase `verify`.
- Integração com SonarCloud via GitHub Actions (job `sonar` ou integrado ao job `backend`).
- Atualização do `make backend-static-analysis` para incluir SpotBugs e PMD.
- Definição de threshold mínimo aceitável para cada ferramenta (zero bugs críticos SpotBugs, zero violações PMD de alta prioridade).
- Exclusão de classes geradas e da classe `WorkLinkApplication` das análises quando aplicável.

## Fora do escopo

- SonarQube self-hosted.
- Análise estática mobile além do `flutter analyze` já existente.
- Ferramentas de SAST externas além do SonarCloud.

## Critérios de aceite

- `mvn verify` deve executar SpotBugs e PMD além do Checkstyle e JaCoCo já existentes.
- SpotBugs deve bloquear o build em caso de bug de categoria `CORRECTNESS` ou `SECURITY`.
- PMD deve bloquear o build em violações de prioridade 1 e 2.
- `make backend-static-analysis` deve executar todas as ferramentas configuradas.
- CI deve falhar quando SpotBugs ou PMD encontrarem violações acima do threshold.
- SonarCloud deve receber o relatório de cobertura e análise a cada push na branch principal.

## Entrega versionável

- Tipo sugerido: `MINOR`
- Motivo: fecha o gap de qualidade estática avançada previsto no RNF13 e no épico técnico.
