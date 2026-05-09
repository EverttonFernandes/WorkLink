# WL-016 — Administração mínima e moderação

## História

Como administrador, quero acompanhar profissionais, denúncias, bloqueios, avaliações contestadas, categorias e métricas
básicas para operar a moderação mínima da V1.

## Fonte oficial

- `docs/jira-pessoal/historias/WL-016-admin-minimo-moderacao.md`
- `docs/requisitos/epico-requisitos-de-negocio.md`
- `docs/requisitos/epico-requisitos-nao-funcionais.md`

## Critérios de aceite

- [x] Administrador deve visualizar profissionais cadastrados.
- [x] Administrador deve bloquear e desbloquear profissionais.
- [x] Profissional bloqueado não deve aparecer indevidamente na descoberta.
- [x] Administrador deve visualizar denúncias.
- [x] Administrador deve revisar avaliações contestadas ou denunciadas.
- [x] Administrador deve gerenciar categorias.
- [x] Administrador deve acompanhar métricas básicas.

## Escopo técnico

- Criar endpoints administrativos mínimos no backend.
- Exigir perfil `ADMINISTRATOR` nas rotas administrativas.
- Auditar acesso administrativo e bloqueio/desbloqueio.
- Persistir bloqueio de profissional.
- Filtrar profissionais bloqueados da descoberta pública.
- Reaproveitar gestão de categorias já existente.
- Cobrir comportamento com testes BDD/TDD.

## Fora do escopo

- Tela administrativa mobile/web.
- Workflow jurídico.
- Moderação automatizada por IA.
- Resolução completa de denúncias e contestações.

## Evidências

- `GET /api/v1/admin/professionals`
- `POST /api/v1/admin/professionals/{professionalIdentifier}/block`
- `POST /api/v1/admin/professionals/{professionalIdentifier}/unblock`
- `GET /api/v1/admin/reports`
- `GET /api/v1/admin/review-analysis-requests`
- `GET /api/v1/admin/metrics`
- Gestão de categorias mantida em `POST /api/v1/categories` com perfil `ADMINISTRATOR`.
- Migração `V015__add_professional_blocking.sql`.
- `make backend-static-analysis`: PASS.
- `make backend-unit-test`: PASS, 249 testes, cobertura mínima de 95% atendida.
- `make backend-integration-test`: PASS, Flyway até `v015`.
- `make backend-image-build`: PASS.
- `make functional-test`: N/A, ainda sem cenários funcionais reais.
- `git diff --check`: PASS.
- Varredura de segredos no diff adicionado: PASS.
