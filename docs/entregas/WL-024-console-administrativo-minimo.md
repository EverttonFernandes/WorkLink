# Entrega WL-024 — Console administrativo mínimo

## Identificador

- História: `WL-024`
- Data: `2026-05-17`
- Tipo semântico sugerido: `MINOR`

## Objetivo de negócio

Disponibilizar uma interface interna mínima, no cliente atual, para que a administração consiga operar profissionais, denúncias, contestações de avaliações, categorias e métricas sem depender de chamadas manuais de API.

## Personas afetadas

- Administrador
- Operação da plataforma

## Requisitos atendidos

- RF62 — Administrador acessa métricas administrativas e funcionais.
- RF63 — Administrador opera fila mínima de moderação.
- RF64 — Administrador consegue bloquear e desbloquear profissionais.
- RF65 — Administrador visualiza e decide denúncias.
- RF66 — Administrador visualiza e decide contestações de avaliações.
- RF67 — Administrador gerencia categorias mínimas da operação.

## O que foi implementado

- Console administrativo interno no app atual, sem criar backoffice paralelo.
- Atalho condicional no fluxo principal quando o console estiver habilitado por configuração.
- Carregamento agregado de:
  - profissionais administrativos
  - denúncias administrativas
  - contestações administrativas
  - métricas administrativas
  - métricas funcionais
  - catálogo de categorias e cidades para exibição legível
- Ações administrativas mínimas:
  - bloquear profissional
  - desbloquear profissional
  - manter denúncia sem ação adicional
  - escalar denúncia para ação adicional
  - manter avaliação pública
  - ocultar avaliação do público
  - cadastrar categoria
- Injeção explícita do cliente administrativo no gateway para reduzir acoplamento e permitir teste unitário real.

## O que não foi implementado

- Login administrativo completo com tela dedicada.
- Gestão avançada de usuários administrativos.
- Ações em lote.
- BI, exportações, alertas ou dashboard executivo.

## Fluxos, telas, endpoints ou módulos envolvidos

- `worklink-mobile/lib/features/administrative_console/`
- `worklink-mobile/lib/services/admin_service.dart`
- `worklink-mobile/lib/services/models/admin_model.dart`
- `worklink-mobile/lib/app/worklink_application_gateway.dart`
- `worklink-mobile/lib/main.dart`
- Endpoints:
  - `/api/v1/admin/professionals`
  - `/api/v1/admin/reports`
  - `/api/v1/admin/review-analysis-requests`
  - `/api/v1/admin/metrics`
  - `/api/v1/admin/functional-metrics`
  - `/api/v1/categories`

## Estratégia de testes

- Unitários para gateway administrativo, service, models, state e controller.
- Widget tests para navegação ao console, renderização do console e bloqueio por acesso negado.
- Integração mobile-backend para manter contrato HTTP real do app com a API em container.

## Evidências de validação

- `make mobile-static-analysis`: PASS
- `make mobile-unit-test`: PASS, cobertura `95.81%`
- `make mobile-screen-test`: PASS
- `make mobile-integration-test`: PASS para contrato HTTP; emulador/simulador/browser `N/A`
- `git diff --check`: PASS

## Riscos ou limitações remanescentes

- O acesso administrativo da V1 continua intencionalmente interno, controlado por configuração e token técnico.
- A experiência administrativa é utilitária; não há paginação, filtros avançados nem ações em lote.

## Arquivos ou módulos relevantes

- `worklink-mobile/lib/features/administrative_console/administrative_console_screen.dart`
- `worklink-mobile/lib/features/administrative_console/administrative_console_controller.dart`
- `worklink-mobile/lib/features/administrative_console/administrative_console_state.dart`
- `worklink-mobile/lib/services/admin_service.dart`
- `worklink-mobile/lib/services/models/admin_model.dart`
- `worklink-mobile/test/unit/app/worklink_application_gateway_test.dart`
- `worklink-mobile/test/unit/features/administrative_console/`
- `worklink-mobile/test/widget/features/administrative_console/`

## Justificativa do versionamento

Entrega `MINOR` porque transforma capacidades administrativas já existentes em operação utilizável sem quebrar contratos anteriores.
