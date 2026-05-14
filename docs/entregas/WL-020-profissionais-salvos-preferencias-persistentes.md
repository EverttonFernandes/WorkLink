# Entrega WL-020 — Profissionais salvos e preferências persistentes do cliente

## Identificador

- História: `WL-020`
- Data: `2026-05-13`
- Tipo semântico sugerido: `MINOR`

## Objetivo de negócio

Permitir que clientes salvem profissionais relevantes e mantenham preferências básicas do perfil entre sessões autenticadas, reduzindo retrabalho e fortalecendo a utilidade do perfil do cliente.

## Personas afetadas

- Cliente: salva profissionais relevantes, volta rapidamente para revistar, ganha continuidade entre sessões.
- Profissional: aumenta probabilidade de contato repetido (cliente familiarizado).
- Plataforma: melhora retenção e DAU.

## Requisitos atendidos

- RF55 — Salvar profissionais como favoritos.
- RF56 — Listar profissionais salvos no perfil do cliente.
- RF57 — Remover profissionais dos salvos.
- RF53/RF54 — Perfil do cliente consolidando cidade principal e cidades relacionadas ao histórico persistido.
- RN01/RN02 — Autenticação obrigatória para salvos.

## O que foi implementado

- Backend com migration `V019` para `customer_profile_preferences` e `customer_saved_professionals`.
- Endpoints autenticados em `/api/v1/customers/me/profile`, `/profile/preferences` e `/saved-professionals/{professionalIdentifier}`.
- Use cases, ports e adapters JDBC para carregar perfil agregado, salvar/remover profissionais e persistir preferências básicas.
- Mobile com `CustomerService` e `WorkLinkBackendGateway` consumindo o perfil real do backend.
- Perfil do cliente carregado do backend, com profissionais salvos, avaliações enviadas e preferências persistidas.
- Ação de salvar/remover profissional diretamente no perfil público do profissional.
- Testes BDD/TDD no backend e no mobile, mantendo cobertura unitária mobile acima de 95%.

## O que não foi implementado

- Filtros avançados dentro da seção de profissionais salvos.
- Tela dedicada apenas para favoritos, separada do perfil.
- Preferências avançadas de privacidade, recomendações ou sincronização offline.

## Fluxos, telas, endpoints ou módulos envolvidos

- Perfil público do profissional com ação de salvar/remover.
- Perfil do cliente com leitura persistida de salvos, avaliações e preferências.
- Backend em `/api/v1/customers/me/profile`.
- Backend em `/api/v1/customers/me/profile/preferences`.
- Backend em `/api/v1/customers/me/saved-professionals/{professionalIdentifier}`.

## Estratégia de testes

- Backend unitário: aggregation do perfil, API privada e adapters JDBC.
- Backend integração: Flyway/migração real em PostgreSQL Docker até `v019`.
- Mobile unitário: gateway, service, estado/controlador de perfil e cliente.
- Mobile tela: perfil do cliente e perfil do profissional com bookmark.

## Evidências de validação

- `make backend-static-analysis`: PASS
- `make backend-unit-test`: PASS
- `make backend-integration-test`: PASS, Flyway até `v019`
- `make mobile-static-analysis`: PASS
- `make mobile-unit-test`: PASS, cobertura `95.49%`
- `make mobile-screen-test`: PASS

## Riscos ou limitações remanescentes

- O fluxo autenticado depende do token em memória do app; ainda não há persistência local de sessão entre reinícios.
- Não existe paginação de favoritos, o que é aceitável para a V1.
- A integração mobile end-to-end com backend real continua dependente do gate específico de integração mobile.

## Arquivos ou módulos relevantes

- `worklink-api/src/main/java/br/com/worklink/application/customer/`
- `worklink-api/src/main/java/br/com/worklink/api/customer/`
- `worklink-api/src/main/java/br/com/worklink/infrastructure/customer/`
- `worklink-mobile/lib/services/customer_service.dart`
- `worklink-mobile/lib/features/customer_profile/`
- `worklink-mobile/lib/features/professional_profile/professional_profile_screen.dart`
- Migration: `worklink-api/src/main/resources/db/migration/V019__create_customer_profile_preferences_and_saved_professionals.sql`

## Justificativa do versionamento

Entrega `MINOR` porque adiciona capacidade funcional nova e persistente ao perfil do cliente sem quebrar contratos existentes.
