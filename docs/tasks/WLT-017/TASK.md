# WLT-017 — CI/CD, builds e scans

## Fonte

- História: `docs/jira-pessoal/historias-tecnicas/WLT-017-cicd-builds-scans.md`
- Ordem oficial: 09 em `docs/jira-pessoal/KANBAN-OFICIAL.md`
- Tipo: Técnica
- Versão sugerida: `MINOR`

## Objetivo

Criar pipeline automatizada para build, testes, análise, scans e artefatos.

## Escopo incluído

- GitHub Actions.
- Pipeline backend.
- Pipeline mobile.
- Build Java e imagem Docker multi-stage da API.
- Testes unitários, integração e funcionais disponíveis.
- Validação obrigatória de cobertura unitária mínima de 95%.
- Scan básico de dependências quando configurado.
- Estratégia para build Android e iOS.

## Fora do escopo

- Publicação pública automática em produção.
- Infra cloud definitiva.

## Critérios de aceite

- Pipeline backend deve executar build, análise e testes disponíveis.
- Pipeline backend deve falhar quando a cobertura unitária ficar abaixo de 95%.
- Pipeline backend deve gerar imagem Docker multi-stage quando aplicável.
- Pipeline mobile deve executar `flutter analyze` e `flutter test`.
- Pipeline mobile deve falhar quando a cobertura unitária Flutter ficar abaixo de 95%.
- Build Android deve ser automatizável.
- Build iOS deve ter estratégia documentada.
- Falhas críticas devem bloquear merge/fechamento.
