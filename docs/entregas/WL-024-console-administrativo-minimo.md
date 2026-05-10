# Entrega WL-024 — Console administrativo mínimo

## Identificador

- História: `WL-024`
- Data: `2026-05-10`
- Tipo semântico sugerido: `MINOR`

## Objetivo de negócio

Fornecer um console mínimo onde administradores possam visualizar saúde geral da plataforma, denúncias pendentes, métricas e tomar ações urgentes de moderação.

## Personas afetadas

- Administrador: ponto central de monitoramento e ação.
- Plataforma: maior capacidade de reação a problemas.

## Requisitos atendidos

- RF62 — Dashboard de métricas funcionais.
- RF63 — Fila de moderação centralizada.
- RF64 — Ações rápidas de bloqueio/limpeza.
- RN20 — Auditoria de todas as ações administrativas.

## O que foi implementado

- Dashboard admin (tela/web) com:
  - Métricas em tempo real (buscas, contatos, avaliações hoje/semana).
  - Denúncias pendentes (últimas 10).
  - Avaliações suspeitas (possível fake/spam).
  - Profissionais inativos (sem contatos em 30 dias).
- Links rápidos para moderação de denúncia, revisão de profissional.
- Filtros por data range, categoria, cidade.
- Auditoria completa de acessos e ações.
- Testes funcionais do dashboard.

## O que não foi implementado

- Alertas automáticos por email/SMS.
- Ações em lote (bloqueio de múltiplos profissionais).
- Customização de campos do dashboard.
- Integração com externos sistemas de BI.

## Fluxos, telas, endpoints ou módulos envolvidos

- Tela admin principal (dashboard).
- Backend em `/api/v1/admin/dashboard` com dados agregados.
- Redirecionamentos para telas de moderação, profissionais, métricas.

## Estratégia de testes

- Integração backend: agregação correta de métricas, filtros.
- Funcional/E2E: acesso ao dashboard, filtros, clicks em links.

## Evidências de validação

- `make backend-integration-test`: PASS, endpoints de dashboard.
- `make functional-test`: PASS, navegação e filtros.

## Riscos ou limitações remanescentes

- Performance pode degradar com base de dados muito grande (índices necessários em WLT-021).
- Dashboard é read-only (sem export direto).

## Arquivos ou módulos relevantes

- `worklink-mobile/lib/features/admin/dashboard/` — interface admin.
- `worklink-api/src/main/java/br/com/worklink/admin/dashboard/` — lógica.
- Backend endpoint: `/api/v1/admin/dashboard`.

## Justificativa do versionamento

Entrega `MINOR` porque completa funcionalidade administrativa sem quebra. Depende de WL-022, WL-023, WLT-015.
