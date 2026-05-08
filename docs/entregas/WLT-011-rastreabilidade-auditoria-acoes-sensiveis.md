# Entrega WLT-011 — Autenticidade, rastreabilidade e auditoria de ações sensíveis

## Identificador

- História: `WLT-011`
- Data: `2026-05-08`
- Tipo semântico sugerido: `MINOR`

## Objetivo de negócio

Criar a base técnica para responsabilização, moderação e investigação de ações sensíveis sem expor dados pessoais ou
conteúdo confidencial desnecessário.

## Personas afetadas

- Usuário cliente: terá fluxos futuros com autoria interna rastreável quando necessário.
- Profissional: terá ações sensíveis associadas a ownership e trilha de auditoria.
- Administrador: terá base para auditar acessos e ações administrativas sensíveis.

## Requisitos atendidos

- RNF03 — Segurança.
- RNF04 — Privacidade e LGPD.
- RNF18 — Autenticidade e rastreabilidade.

## O que foi implementado

- Modelo de evento de auditoria de ação sensível.
- Porta e caso de uso para registro de auditoria.
- Adapter JDBC e migration PostgreSQL `V009__create_sensitive_audit_events.sql`.
- Auditoria dos endpoints sensíveis existentes de categoria, cidade e perfil profissional.
- Catálogo de ações futuras para contato, feedback, avaliação anônima, denúncia, evidência confidencial, contestação e admin.

## O que não foi implementado

- SIEM completo.
- Workflow avançado de investigação.
- Tela administrativa de consulta de auditoria.
- Disparos de auditoria para fluxos funcionais que ainda não existem.

## Fluxos, telas, endpoints ou módulos envolvidos

- `POST /api/v1/categories`
- `POST /api/v1/cities`
- `PATCH /api/v1/professionals/{professionalIdentifier}/profile`
- Módulo backend de auditoria de ações sensíveis.

## Estratégia de testes

- Unitários: caso de uso de auditoria, validações obrigatórias, controllers e configuração.
- Integração: adapter JDBC, migrations e suite integrada do backend.
- Funcionais/E2E: N/A nesta entrega, pois não há cenário funcional real novo.
- Mobile: gates existentes executados para garantir ausência de regressão.

## Evidências de validação

- `rm -rf worklink-api/target && make backend-unit-test`: PASS, 143 testes e cobertura mínima atendida.
- `make backend-static-analysis`: PASS.
- `make backend-integration-test`: PASS, Flyway até `v009`.
- `make mobile-static-analysis`: PASS.
- `make mobile-unit-test`: PASS, 33 testes e cobertura 99,51%.
- `make mobile-screen-test`: PASS, 22 testes.
- `make mobile-integration-test`: N/A por ausência de Android Emulator, iOS Simulator ou Chrome.
- `make functional-test`: N/A por ausência de cenários reais.
- `git diff --check`: PASS.
- Varredura de segredos: PASS com apenas o placeholder esperado em `compose.yml`.

## Riscos ou limitações remanescentes

- Fluxos de contato, avaliação, denúncia, contestação e admin ainda conectarão seus próprios disparos de auditoria quando forem implementados.
- Retenção, consulta administrativa avançada, outbox e integração com SIEM continuam fora desta entrega.

## Arquivos ou módulos relevantes

- `worklink-api/src/main/java/br/com/worklink/application/audit`
- `worklink-api/src/main/java/br/com/worklink/infrastructure/audit`
- `worklink-api/src/main/resources/db/migration/V009__create_sensitive_audit_events.sql`
- `docs/arquitetura/auditoria-acoes-sensiveis.md`

## Justificativa do versionamento

`MINOR`, porque a entrega adiciona uma capacidade técnica nova e versionável de auditoria persistida para ações
sensíveis, sem quebrar contratos existentes.
