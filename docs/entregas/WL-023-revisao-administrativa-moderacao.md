# Entrega WL-023 — Revisão administrativa efetiva de denúncias e avaliações

## Identificador

- História: `WL-023`
- Data: `2026-05-14`
- Tipo semântico sugerido: `MINOR`

## Objetivo de negócio

Transformar a moderação administrativa em um fluxo operacional mínimo, com decisão persistida, auditoria e capacidade de retirar avaliações abusivas da exibição pública.

## Personas afetadas

- Administrador: diretamente, porque passa a decidir e rastrear moderação.
- Profissional: diretamente, porque pode ter contestação tratada de forma efetiva.
- Usuário cliente: indiretamente, porque a vitrine pública deixa de exibir avaliações ocultadas por abuso ou suspeita.

## Requisitos atendidos

- RF: `RF64`, `RF65`
- RN: `RN13`, `RN14`, `RN19`, `RN20`

## O que foi implementado

- Migração `V021` adicionando status, decisão, notas e data de decisão para denúncias e contestações.
- Flag `hidden_from_public` nas avaliações profissionais.
- Endpoints administrativos para moderar denúncias e contestações.
- Auditoria sensível específica para decisão sobre denúncia e contestação.
- Respostas administrativas enriquecidas com estado atual de moderação.
- Filtro na vitrine pública para não exibir avaliações ocultadas por moderação.
- Testes unitários, web e de infraestrutura cobrindo fluxos felizes e ramos de erro.

## O que não foi implementado

- Interface administrativa dedicada.
- Mediação humana completa.
- Automação por IA.

## Fluxos, telas, endpoints ou módulos envolvidos

- Endpoints administrativos de denúncias e contestações
- Módulo de avaliações profissionais
- Módulo de denúncias profissionais

## Estratégia de testes

- Unitários: casos de uso, controller web, domínio e adaptadores JDBC.
- Integração: validação da migração `V021` com Flyway e banco real.
- Funcionais/E2E: `N/A`
- Mobile: `N/A`

## Evidências de validação

- `make backend-unit-test`
- `make backend-integration-test`
- `git diff --check`

## Riscos ou limitações remanescentes

- Ainda não existe console administrativo dedicado; a capacidade foi entregue via contrato backend.

## Justificativa do versionamento

Entrega capacidade funcional nova no módulo administrativo sem quebra retrocompatível, portanto a classificação prevista é `MINOR`.
