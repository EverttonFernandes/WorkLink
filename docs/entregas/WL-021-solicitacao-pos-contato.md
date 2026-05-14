# Entrega WL-021 — Solicitação de feedback pós-contato

## Identificador

- História: `WL-021`
- Data: `2026-05-13`
- Tipo semântico: `MINOR`

## Objetivo de negócio

Solicitar ativamente que o cliente deixe feedback após contactar um profissional, aumentando taxa de avaliações e qualidade dos dados para ranking futuro.

## Personas afetadas

- Cliente: recebe lembretes contextualizados para avaliar.
- Profissional: recebe feedback mais frequente.
- Plataforma: melhora base de dados para ranking (WL-017).

## Requisitos atendidos

- RF35 — solicitar feedback após contato iniciado
- RF36 — permitir informar se conseguiu falar
- RF37 — permitir informar responsividade
- RF38 — permitir informar se o serviço foi realizado
- RF39 — armazenar respostas para indicadores futuros
- RN11 — fluxo continua elegível para avaliação apenas após contato + serviço realizado
- RN18 — sinais de responsividade passam a ser coletados de forma ativa

## O que foi implementado

- Migração `V020__create_post_contact_feedback_requests.sql` criando fila persistida de solicitações pós-contato.
- Retroalimentação de contatos antigos sem feedback para o novo mecanismo de pendências.
- Criação automática da pendência quando o cliente inicia contato com um profissional.
- Marcação automática da pendência como `ANSWERED` quando o pós-contato é respondido.
- Endpoint privado para listar pendências do cliente autenticado.
- Endpoint privado para dispensar pendência sem insistência imediata.
- Prompt in-app no mobile, acima dos filtros da descoberta, reaproveitando a tela existente de pós-contato.
- Testes backend/mobile cobrindo fluxo de criação, listagem, dispensa e conclusão.

## O que não foi implementado

- Push notification real.
- Estratégias de reengajamento.
- Agendamento temporal sofisticado para relembrar o cliente.

## Fluxos, telas, endpoints ou módulos envolvidos

- `POST /api/v1/contact-intentions`
- `POST /api/v1/post-contact-feedbacks`
- `GET /api/v1/customers/me/post-contact-feedback-requests`
- `POST /api/v1/customers/me/post-contact-feedback-requests/{contactIntentIdentifier}/dismiss`
- Mobile:
  - `worklink-mobile/lib/main.dart`
  - `worklink-mobile/lib/features/post_contact_feedback/pending_post_contact_feedback_prompt.dart`
- Integração com auditoria sensível para a ação de dispensa.

## Estratégia de testes

- Backend unitário: use cases de criação/listagem/dispensa e adaptação JDBC.
- Backend integração: Flyway até `v020`.
- Mobile unitário: serviço HTTP, gateway e contrato do prompt.
- Mobile tela: renderização do prompt e composição com descoberta.
- Mobile integração: contrato HTTP real backend/mobile.

## Evidências de validação

- `make backend-unit-test`: PASS
- `make backend-integration-test`: PASS, Flyway até `v020`
- `make mobile-unit-test`: PASS, cobertura `95.44%`
- `make mobile-screen-test`: PASS
- `make mobile-static-analysis`: PASS
- `make mobile-integration-test`: PASS

## Riscos ou limitações remanescentes

- O prompt ainda é somente in-app.
- A fila usa a primeira pendência elegível na home; ordenação mais sofisticada pode entrar depois.
- A dispensa atual evita insistência imediata, mas não implementa reabordagem futura.

## Arquivos ou módulos relevantes

- `worklink-api/src/main/java/br/com/worklink/application/contact/`
- `worklink-api/src/main/java/br/com/worklink/api/customer/`
- `worklink-api/src/main/java/br/com/worklink/infrastructure/contact/`
- `worklink-mobile/lib/features/post_contact_feedback/`
- `worklink-mobile/lib/services/contact_service.dart`
- `worklink-mobile/lib/app/worklink_application_gateway.dart`
- Migração: `worklink-api/src/main/resources/db/migration/V020__create_post_contact_feedback_requests.sql`

## Justificativa do versionamento

Entrega `MINOR` porque adiciona capacidade funcional nova de coleta ativa de pós-contato sem quebrar contratos existentes.
