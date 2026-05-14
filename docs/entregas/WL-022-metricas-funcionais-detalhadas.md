# Entrega WL-022 — Métricas funcionais detalhadas da V1

## Identificador

- História: `WL-022`
- Data: `2026-05-14`
- Tipo semântico sugerido: `MINOR`

## Objetivo de negócio

Completar a visão analítica mínima da V1 para que produto e administração acompanhem descoberta, responsividade, reputação e saúde do catálogo sem ativar ranking algorítmico.

## Personas afetadas

- Usuário cliente: indiretamente, porque o produto passa a medir qualidade de resposta e descoberta.
- Profissional: indiretamente, porque contatos, avaliações, denúncias e disponibilidade passam a compor sinais consolidados.
- Administrador: diretamente, porque o endpoint administrativo recebe os agregados detalhados.

## Requisitos atendidos

- RF: `RF58`, `RF59`, `RF60`, `RF61`, `RF67`
- RN: `RN17`, `RN18`

## O que foi implementado

- Ampliação do agregado funcional para incluir buscas por categoria e cidade.
- Inclusão da contagem de buscas sem resultado.
- Inclusão de resumo de profissionais ativos, completos, disponíveis, indisponíveis e com contato recebido.
- Inclusão de percentuais de responsividade derivados do pós-contato.
- Inclusão de resumo de reputação com média geral, avaliações anônimas, denúncias e contestações.
- Manutenção explícita de `rankingAlgorithmEnabled=false`.
- Atualização do contrato HTTP administrativo e dos testes correlatos.
- Estabilização do gate backend para limpar `jacoco.exec` residual antes das execuções de cobertura.

## O que não foi implementado

- Ranking algorítmico.
- Dashboards externos.
- Recomendação baseada em IA.

## Fluxos, telas, endpoints ou módulos envolvidos

- Endpoint `GET /api/v1/admin/functional-metrics`
- Casos de uso de métricas funcionais
- Adaptador JDBC de métricas funcionais

## Estratégia de testes

- Unitários: cobertura de caso de uso e contrato do agregado funcional.
- Integração: validação do adaptador JDBC contra banco real e endpoint administrativo.
- Funcionais/E2E: `N/A`
- Mobile: `N/A`

## Evidências de validação

- `make backend-unit-test`
- `make backend-integration-test`
- `git diff --check`
- Cobertura backend validada pelo `jacoco:check@check`.

## Riscos ou limitações remanescentes

- Os dados analíticos continuam expostos apenas via endpoint administrativo; ainda não existe dashboard dedicado.
- O percentual depende da qualidade dos dados de pós-contato já coletados.

## Arquivos ou módulos relevantes

- `worklink-api/src/main/java/br/com/worklink/application/metrics/usecase/`
- `worklink-api/src/main/java/br/com/worklink/api/admin/`
- `worklink-api/src/main/java/br/com/worklink/infrastructure/metrics/JdbcFunctionalMetricsRepositoryAdapter.java`
- `worklink-api/src/test/java/br/com/worklink/application/metrics/usecase/FunctionalMetricsUseCaseTest.java`
- `worklink-api/src/test/java/br/com/worklink/infrastructure/metrics/JdbcFunctionalMetricsRepositoryAdapterTest.java`
- `worklink-api/src/test/java/br/com/worklink/api/admin/AdminControllerTest.java`
- `Makefile`

## Justificativa do versionamento

Entrega uma ampliação funcional do produto administrativo, adicionando nova capacidade analítica sem quebrar contratos anteriores nem alterar comportamento de produção para usuários finais. Por isso, a classificação é `MINOR`.
