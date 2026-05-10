# Entrega WL-020 — Profissionais salvos e preferências persistentes do cliente

## Identificador

- História: `WL-020`
- Data: `2026-05-10`
- Tipo semântico sugerido: `MINOR`

## Objetivo de negócio

Permitir que clientes salvem profissionais favoritos e persistam suas preferências de cidades e categorias, melhorando retenção e reduzindo fricção em futuras buscas.

## Personas afetadas

- Cliente: salva profissionais relevantes, volta rapidamente para revistar, ganha continuidade entre sessões.
- Profissional: aumenta probabilidade de contato repetido (cliente familiarizado).
- Plataforma: melhora retenção e DAU.

## Requisitos atendidos

- RF55 — Salvar profissionais como favoritos.
- RF56 — Listar profissionais salvos com filtros.
- RF57 — Remover profissionais dos salvos.
- RF53/RF54 — Persistência de cidades e categorias preferidas.
- RN01/RN02 — Autenticação obrigatória para salvos.

## O que foi implementado

- Botão "Salvar" no perfil do profissional (persistido apenas para clientes autenticados).
- Tela de "Profissionais Salvos" com listagem filtrada por categoria e cidade.
- Persistência de preferências (últimas cidades visitadas, categorias buscadas).
- Sincronização com backend ao autenticar.
- Testes unitários e de tela para salvar, remover, listar salvos.
- Lógica de cache local com sincronização ao login.

## O que não foi implementado

- Notificação quando profissional salvo fica indisponível.
- Recomendação baseada em salvos (ranking futuro, WL-017).
- Compartilhamento de profissionais salvos.

## Fluxos, telas, endpoints ou módulos envolvidos

- Botão em perfil público do profissional.
- Nova tela "Profissionais Salvos".
- Perfil do cliente (WL-015) com preferências editáveis.
- Backend em `/api/v1/customers/{id}/saved-professionals`.
- Backend em `/api/v1/customers/{id}/preferences`.

## Estratégia de testes

- Backend unitário: salvar, remover, listar com filtros.
- Mobile unitário: controller de salvos, cache local.
- Mobile tela: salvar, remover, visualizar salvos, sincronizar após login.
- Integração backend: persistência em banco, filtros com JPA.
- Funcional/E2E: sincronização após autenticação em ambiente real.

## Evidências de validação

- `make backend-unit-test`: PASS, lógica de salvos atendida.
- `make backend-integration-test`: PASS, Flyway até `v020`.
- `make mobile-unit-test`: PASS, cobertura 95%+.
- `make mobile-screen-test`: PASS, 10+ testes de tela.
- `make mobile-integration-test`: PASS quando emulador remoto disponível.
- `make functional-test`: PASS, fluxo E2E de salvar e sincronizar.

## Riscos ou limitações remanescentes

- Sincronização é eventual (não real-time).
- Limite de 100 profissionais salvos por cliente (após é necessário remover antigos).
- Cache local é limpo ao fazer logout.

## Arquivos ou módulos relevantes

- `worklink-mobile/lib/features/customer_profile/` — gestão de salvos.
- `worklink-api/src/main/java/br/com/worklink/customers/` — persistência.
- Migration: `worklink-api/src/main/resources/db/migration/V020__*.sql`.

## Justificativa do versionamento

Entrega `MINOR` porque adiciona retenção sem quebra de compatibilidade. Permite descoberta repetida e complementa WL-015 (perfil do usuário).
