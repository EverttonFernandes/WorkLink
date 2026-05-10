# Entrega WL-021 — Solicitação de feedback pós-contato

## Identificador

- História: `WL-021`
- Data: `2026-05-10`
- Tipo semântico sugerido: `MINOR`

## Objetivo de negócio

Solicitar ativamente que o cliente deixe feedback após contactar um profissional, aumentando taxa de avaliações e qualidade dos dados para ranking futuro.

## Personas afetadas

- Cliente: recebe lembretes contextualizados para avaliar.
- Profissional: recebe feedback mais frequente.
- Plataforma: melhora base de dados para ranking (WL-017).

## Requisitos atendidos

- RF46 — Notificação/prompt de feedback após contato.
- RN11/RN12 — Rastreabilidade de avaliação com timestamp de contato.

## O que foi implementado

- Persistência de intenção de contato (timestamp, profissional, cliente).
- Tela de prompt/bottomsheet solicitando feedback após 2 horas de contato.
- Ligação entre intenção de contato e avaliação deixada.
- Testes unitários e de tela para notificação e submissão.
- Rastreabilidade: timestamp de contato linkado com timestamp de avaliação.

## O que não foi implementado

- Push notification (apenas in-app prompt).
- Customização de delay de notificação por cliente.
- Re-notificação se cliente ignorar prompt.

## Fluxos, telas, endpoints ou módulos envolvidos

- Backend em `/api/v1/contacts/{id}/solicit-feedback`.
- Tela mobile com prompt/bottomsheet após retorno do WhatsApp.
- Tela de avaliação existente (WL-012).
- Integração com auditoria (WLT-011).

## Estratégia de testes

- Backend unitário: persistência de intenção, cálculo de delay.
- Mobile unitário: controller de prompt.
- Mobile tela: exibição do prompt, aceitação, rejeição.
- Integração backend: relacionamento entre intenção e avaliação.
- Funcional/E2E: fluxo completo contato→delay→prompt→avaliação.

## Evidências de validação

- `make backend-unit-test`: PASS, lógica de solicitação atendida.
- `make backend-integration-test`: PASS, Flyway até `v021`.
- `make mobile-unit-test`: PASS, cobertura 95%+.
- `make mobile-screen-test`: PASS, 5+ testes.
- `make mobile-integration-test`: PASS com emulador remoto.
- `make functional-test`: PASS, fluxo E2E validado.

## Riscos ou limitações remanescentes

- Delay fixo de 2 horas pode não ser ideal para todos os serviços.
- Cliente pode ignorar prompt e nunca avaliar.
- Sem re-tentativa se cliente rejeitar prompt inicialmente.

## Arquivos ou módulos relevantes

- `worklink-mobile/lib/features/post_contact_feedback/` — prompt.
- `worklink-api/src/main/java/br/com/worklink/contacts/` — persistência.
- Migration: `worklink-api/src/main/resources/db/migration/V021__*.sql`.

## Justificativa do versionamento

Entrega `MINOR` porque adiciona retenção de avaliações sem quebra. Depende de WL-011 e complementa WL-012.
