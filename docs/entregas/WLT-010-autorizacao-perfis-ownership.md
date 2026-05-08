# Entrega WLT-010 — Autorização por Perfil e Ownership

## Identificador

- História: `WLT-010`
- Data: `2026-05-08`
- Tipo semântico sugerido: `MINOR`

## Objetivo de negócio

Impedir acesso indevido a ações administrativas e dados privados, garantindo que endpoints sensíveis validem perfil e ownership antes de executar regras de negócio.

## Personas afetadas

- Usuário cliente: só pode acessar dados privados próprios.
- Profissional: só pode alterar o próprio perfil, salvo ação administrativa.
- Administrador: pode executar ações administrativas previstas pela política.

## Requisitos atendidos

- RNF03: autenticação, autorização, autenticidade e controle de acesso.
- RNF17: prevenção de acesso indevido por perfil e ownership.

## O que foi implementado

- Modelo de principal autenticado com perfis `CUSTOMER`, `PROFESSIONAL` e `ADMINISTRATOR`.
- Política de autorização por ação sensível e ownership na camada de aplicação.
- Parser de `access token` HMAC-SHA-256 com validação de assinatura e expiração.
- Resolver HTTP de `Authorization: Bearer`.
- Proteção dos endpoints administrativos de catálogo.
- Proteção da alteração de perfil profissional por ownership.

## O que não foi implementado

- IAM externo.
- RBAC corporativo complexo.
- Auditoria persistida, prevista para WLT-011.
- Novas telas mobile.

## Fluxos, telas, endpoints ou módulos envolvidos

- `POST /api/v1/categories`
- `POST /api/v1/cities`
- `PATCH /api/v1/professionals/{professionalIdentifier}/profile`
- Módulos de aplicação `authorization` e adapter de infraestrutura de token.

## Estratégia de testes

- Unitários: política de autorização, parsing de token, resolver HTTP e configuração de use cases.
- Integração: regressão backend com banco e migrations.
- Funcionais/E2E: N/A, suíte ainda sem cenários reais.
- Mobile: regressão estática, unitária e de tela/widget.

## Evidências de validação

- `make backend-unit-test`: PASS, 132 testes, JaCoCo validado com mínimo de 95%.
- `make backend-static-analysis`: PASS, 0 violações de Checkstyle.
- `make backend-integration-test`: PASS, Flyway validado até `v008`.
- `make mobile-static-analysis`: PASS, Flutter analyze sem issues.
- `make mobile-unit-test`: PASS, cobertura unitária mobile 99.51%.
- `make mobile-screen-test`: PASS, 22 testes de tela/widget.
- `make mobile-integration-test`: N/A, sem emulador Android, iOS Simulator ou Chrome disponível no container.
- `make functional-test`: N/A, suíte funcional ainda sem cenários reais.
- `git diff --check`: PASS.
- Scan local de secrets: PASS, apenas placeholder esperado `WORKLINK_POSTGRES_PASSWORD` em `compose.yml`.

## Riscos ou limitações remanescentes

- Auditoria persistida das decisões sensíveis será adicionada na WLT-011.
- Novos endpoints sensíveis devem mapear ações em `SensitiveAction` para não contornar a política.

## Arquivos ou módulos relevantes

- `worklink-api/src/main/java/br/com/worklink/application/authorization/`
- `worklink-api/src/main/java/br/com/worklink/api/authorization/`
- `worklink-api/src/main/java/br/com/worklink/infrastructure/authentication/HmacSha256JwtAccessTokenPrincipalResolverAdapter.java`
- `docs/arquitetura/autorizacao-perfis-ownership.md`

## Justificativa do versionamento

Entrega `MINOR` porque adiciona uma capacidade técnica nova e versionável de autorização por perfil e ownership, necessária para fluxos sensíveis da V1, sem quebrar endpoints públicos existentes.
