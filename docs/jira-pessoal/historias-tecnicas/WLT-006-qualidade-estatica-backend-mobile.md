# WLT-006 — Qualidade estática e clean code

## Objetivo

Estabelecer ferramentas e regras de qualidade estática para backend e mobile.

## Valor técnico

Mantém legibilidade, padronização e reduz regressões estruturais.

## RNFs relacionados

- RNF13

## Escopo incluído

- Backend com Checkstyle, SpotBugs, PMD ou equivalentes.
- SonarQube/SonarCloud quando configurado.
- Mobile com `flutter analyze` e lint rules.
- Aderência aos padrões de clean code e nomes didáticos.

## Fora do escopo

- Refatoração ampla sem necessidade.
- Quality gate externo obrigatório antes de existir configuração real.

## Critérios de aceite

- Backend deve ter comando de análise estática.
- Mobile deve ter comando de análise estática quando app existir.
- Nomes abreviados e genéricos devem ser bloqueados conforme padrão do projeto.
- O projeto deve documentar comandos de qualidade.
- Violações críticas devem bloquear continuidade.

## Entrega versionável

- Tipo sugerido: `MINOR`
