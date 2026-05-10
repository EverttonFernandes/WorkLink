# Entrega WL-023 — Revisão administrativa efetiva de denúncias e avaliações

## Identificador

- História: `WL-023`
- Data: `2026-05-10`
- Tipo semântico sugerido: `MINOR`

## Objetivo de negócio

Permitir que administradores revisem, valide e tomem ações sobre denúncias de profissionais e avaliações suspeitas, mantendo qualidade e confiança na plataforma.

## Personas afetadas

- Administrador: gerencia denúncias, toma decisões de bloqueio/limpeza.
- Profissional: recebe feedback se denúncia for invalidada.
- Cliente: confiança em qualidade da plataforma.

## Requisitos atendidos

- RF48 — Revisão de denúncias por admin.
- RF49 — Ações: validar, rejeitar, requerer prova adicional.
- RN13/RN14/RN20 — Segurança, auditoria de moderação.

## O que foi implementado

- Tela admin de fila de denúncias com filtros (status, data, profissional).
- Detalhes completos da denúncia (motivo, descrição, evidência).
- Ações: validar denúncia, rejeitar, requerer mais informações.
- Notificação ao profissional quando denúncia é validada.
- Auditoria completa de cada ação administrativa (WLT-011).
- Testes unitários e de tela para revisão, validação, rejeição.

## O que não foi implementado

- Bloqueio automático do profissional (apenas marcação para revisão).
- Comunicação bidirecional com denunciante.
- Apelação de denúncia pelo profissional.

## Fluxos, telas, endpoints ou módulos envolvidos

- Tela admin em novo módulo `admin/reports`.
- Backend em `/api/v1/admin/reports/{id}/validate`, `/api/v1/admin/reports/{id}/reject`.
- Tabela de histórico de moderação (`moderation_log`).
- Integração com auditoria (WLT-011).

## Estratégia de testes

- Backend unitário: validação, rejeição, auditoria.
- Mobile tela: listagem de denúncias, ações, notificação.
- Integração backend: relacionamento entre denúncia, ação e auditoria.
- Funcional/E2E: fluxo completo denúncia→revisão→ação.

## Evidências de validação

- `make backend-unit-test`: PASS, lógica de moderação atendida.
- `make backend-integration-test`: PASS, Flyway até `v023`.
- `make mobile-unit-test`: PASS, cobertura 95%+.
- `make mobile-screen-test`: PASS, 8+ testes admin.
- `make functional-test`: PASS, fluxo E2E de moderação.

## Riscos ou limitações remanescentes

- Admin pode ser alvo de stress por revisão de muitas denúncias (relatório não tem paginação inicial).
- Decisão de bloqueio automático não está implementada (manual apenas).

## Arquivos ou módulos relevantes

- `worklink-mobile/lib/features/admin/` — Interface admin.
- `worklink-api/src/main/java/br/com/worklink/admin/moderation/` — lógica.
- Migration: `worklink-api/src/main/resources/db/migration/V023__*.sql`.

## Justificativa do versionamento

Entrega `MINOR` porque adiciona funcionalidade administrativa sem quebra de compatibilidade. Depende de WL-014 (denúncia).
