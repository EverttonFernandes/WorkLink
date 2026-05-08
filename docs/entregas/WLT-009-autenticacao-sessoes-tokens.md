# Entrega WLT-009 — Autenticação segura, sessões e tokens

## Identificador

- História: `WLT-009`
- Data: `2026-05-08`
- Tipo semântico sugerido: `MINOR`

## Objetivo de negócio

Entregar a base segura de autenticação por telefone para sustentar ações sensíveis do WorkLink V1 sem expor OTP, refresh token ou existência de conta.

## Personas afetadas

- Usuário cliente: passa a ter base técnica para autenticação simplificada por telefone.
- Profissional: não é afetado diretamente nesta entrega.
- Administrador: não é afetado diretamente nesta entrega.

## Requisitos atendidos

- RF: base técnica para autenticação do cliente por telefone.
- RN: autenticação segura, proteção de tokens, expiração, revogação, configuração por ambiente e prevenção de vazamento em logs.

## O que foi implementado

- Domínio técnico de conta cliente, desafio OTP e sessão de refresh token.
- Casos de uso para solicitar OTP, verificar OTP, renovar sessão e revogar sessão.
- Portas de aplicação para geração de OTP/token, relógio, emissão de access token, persistência e proteção de valores sensíveis.
- Adaptadores JDBC, geração segura com `SecureRandom` e access token assinado com HMAC-SHA-256.
- Endpoints REST mínimos para `/api/auth/otp/request`, `/api/auth/otp/verify`, `/api/auth/refresh` e `/api/auth/revoke`.
- Migração `V008__create_authentication_sessions.sql`.
- Variáveis de configuração para expiração de access token, refresh token e OTP.

## O que não foi implementado

- Envio real de SMS.
- Login social.
- MFA avançado.
- Tela mobile real de login.
- Autorização por perfil e ownership, que pertence à WLT-010.

## Fluxos, telas, endpoints ou módulos envolvidos

- Backend: `br.com.worklink.application.authentication`, `br.com.worklink.domain.authentication`, `br.com.worklink.infrastructure.authentication`.
- API: `AuthenticationController`.
- Banco: tabelas `customer_accounts`, `authentication_otp_challenges` e `authentication_refresh_sessions`.

## Estratégia de testes

- Unitários: domínio/casos de uso/adaptadores de autenticação com padrão GIVEN/WHEN/THEN.
- Integração: migração Flyway até `v008`.
- Funcionais/E2E: N/A, ainda sem cenários reais.
- Mobile: regressão estática, unitária e testes de tela existentes.

## Evidências de validação

- `make backend-unit-test`: PASS, 111 testes, cobertura JaCoCo validada.
- `make backend-static-analysis`: PASS.
- `make backend-integration-test`: PASS, Flyway aplicou até `v008`.
- `make mobile-static-analysis`: PASS.
- `make mobile-unit-test`: PASS, cobertura 99.51%.
- `make mobile-screen-test`: PASS, 22 testes.
- `make mobile-integration-test`: N/A, sem emulator/simulator/Chrome disponível.
- `make functional-test`: N/A, sem cenários funcionais reais.
- `git diff --check`: PASS.
- Varredura local de segredos: PASS, apenas placeholder esperado em `compose.yml`.

## Riscos ou limitações remanescentes

- O provedor real de SMS ainda precisa ser definido e implementado como adaptador.
- A WLT-010 deve aplicar autorização por perfil e ownership antes de fluxos sensíveis de negócio.

## Arquivos ou módulos relevantes

- `worklink-api/src/main/java/br/com/worklink/application/authentication/`
- `worklink-api/src/main/java/br/com/worklink/domain/authentication/`
- `worklink-api/src/main/java/br/com/worklink/infrastructure/authentication/`
- `worklink-api/src/main/java/br/com/worklink/api/authentication/`
- `worklink-api/src/main/resources/db/migration/V008__create_authentication_sessions.sql`
- `docs/arquitetura/autenticacao-sessoes-tokens.md`

## Justificativa do versionamento

Entrega `MINOR`, pois adiciona capacidade nova de autenticação e sessão sem quebrar contratos anteriores.
