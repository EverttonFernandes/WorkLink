# Entrega WL-022 — Métricas funcionais detalhadas da V1

## Identificador

- História: `WL-022`
- Data: `2026-05-10`
- Tipo semântico sugerido: `MINOR`

## Objetivo de negócio

Coletar métricas funcionais detalhadas sobre descoberta, contato e avaliações, fornecendo base de dados confiável para ranking futuro (WL-017+).

## Personas afetadas

- Operação/Analytics: monitora saúde da plataforma.
- Produto: toma decisões baseadas em dados.
- Plataforma: prepara base para otimizações futuras.

## Requisitos atendidos

- RF60 — Métricas de descoberta (buscas, filtros usados).
- RF61 — Métricas de contato (sucesso, cancelamento).
- RF62 — Métricas de avaliação (taxa, notas médias).
- RN17 — Observabilidade e rastreabilidade (WLT-015).

## O que foi implementado

- Eventos de descoberta: search query, filtros aplicados, resultados retornados, clique em profissional.
- Eventos de contato: intenção iniciada, WhatsApp aberto, sucesso presumido.
- Eventos de avaliação: formulário exibido, avaliação submetida, nota deixada.
- Dashboard read-only em backend: `/api/v1/admin/metrics/` com agregações.
- Armazenamento em tabela separada (`metrics`) com TTL (dados antigos deletados).
- Documentação de observabilidade (WLT-015).

## O que não foi implementado

- Dashboard visual em UI (apenas JSON).
- Alertas automáticos baseado em métricas.
- Exportação de dados para BI externo.
- Relativização por cidade/categoria.

## Fluxos, telas, endpoints ou módulos envolvidos

- Backend em `/api/v1/admin/metrics/discovery`, `/api/v1/admin/metrics/contact`, `/api/v1/admin/metrics/review`.
- Tabela `metrics` em banco de dados.
- Eventos disparados em controllers de discovery, contact, review.

## Estratégia de testes

- Backend unitário: cálculo de agregações, filtros.
- Integração backend: inserção de eventos, consulta de métricas.
- Funcional/E2E: coleta real de eventos durante fluxos de teste.

## Evidências de validação

- `make backend-unit-test`: PASS, agregações testadas.
- `make backend-integration-test`: PASS, Flyway até `v022`.
- `make functional-test`: PASS, eventos coletados durante E2E.

## Riscos ou limitações remanescentes

- Armazenamento indefinido de eventos pode crescer base de dados (mitigado com TTL).
- Sem isolamento geográfico de métricas inicialmente.

## Arquivos ou módulos relevantes

- `worklink-api/src/main/java/br/com/worklink/metrics/` — lógica.
- Migration: `worklink-api/src/main/resources/db/migration/V022__*.sql`.

## Justificativa do versionamento

Entrega `MINOR` porque adiciona observabilidade sem quebra funcional. Prepara terreno para WL-017 (ranking futuro).
