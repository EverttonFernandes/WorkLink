# WLT-006 — Qualidade estática e clean code

## Fonte

- História: `docs/jira-pessoal/historias-tecnicas/WLT-006-qualidade-estatica-backend-mobile.md`
- Ordem oficial: 06 em `docs/jira-pessoal/KANBAN-OFICIAL.md`
- Tipo: Técnica
- Versão sugerida: `MINOR`

## Objetivo

Estabelecer ferramentas e comandos de qualidade estática para backend e mobile.

## Escopo incluído

- Backend com análise estática integrada ao Maven.
- Mobile com `flutter analyze` e regras explícitas de lint.
- Comandos no `Makefile` para executar os gates em container.
- Documentação dos comandos de qualidade.
- Bloqueio de violações críticas antes da continuidade da entrega.

## Fora do escopo

- Refatoração ampla sem necessidade.
- Quality Gate externo obrigatório antes da configuração real de SonarQube/SonarCloud.
- Criação de testes funcionais ou testes de tela reais.

## Critérios de aceite

- Backend deve ter comando de análise estática.
- Mobile deve ter comando de análise estática quando app existir.
- Nomes abreviados e genéricos devem ser bloqueados conforme padrão do projeto.
- O projeto deve documentar comandos de qualidade.
- Violações críticas devem bloquear continuidade.
