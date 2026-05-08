# Entrega WLT-013 — Criptografia e proteção de dados

## Identificador

- História: `WLT-013`
- Data: `2026-05-08`
- Tipo semântico sugerido: `MINOR`

## Objetivo de negócio

Reduzir exposição de dados sensíveis antes das histórias de autenticação, avaliação, denúncia e perfil do usuário.

## Personas afetadas

- Usuário cliente: terá fluxos futuros de autenticação e tokens sem persistência em claro.
- Profissional: CPF/CNPJ do cadastro progressivo deixa de ser salvo em claro.
- Administrador: terá base técnica para auditoria e moderação sem expor dados sensíveis em respostas públicas.

## Requisitos atendidos

- RNF03: segurança e autenticação/autenticidade.
- RNF05: LGPD, privacidade e minimização de dados.

## O que foi implementado

- Porta de aplicação `ProtectSensitiveValuePort` para proteção de valores sensíveis.
- Enum `ProtectedSensitiveValuePurpose` para separar documento, OTP e refresh token.
- Adaptador `HmacSha256SensitiveValueProtectorAdapter` com HMAC-SHA-256 e pepper configurável.
- Configuração `WORKLINK_SENSITIVE_VALUE_PEPPER`.
- Persistência do documento profissional apenas como `document_number_hash`.
- Migração Flyway `V007__protect_professional_document_number.sql`.
- Documentação de TLS obrigatório em ambientes reais, proteção em repouso e ausência de dados sensíveis em logs.

## O que não foi implementado

- Fluxo completo de OTP.
- Fluxo completo de refresh token.
- KMS definitivo ou HSM obrigatório.
- Upload binário real para S3/MinIO.

## Fluxos, telas, endpoints ou módulos envolvidos

- Cadastro progressivo do profissional.
- Persistência JDBC de profissionais.
- Configuração de casos de uso.
- Segurança de infraestrutura.
- Migrações de banco.

## Estratégia de testes

- Unitários: hashing determinístico, separação por finalidade, validação de pepper, caso de uso de cadastro progressivo e repositório JDBC.
- Integração: Flyway aplicado até v007 em PostgreSQL via Docker.
- Funcionais/E2E: N/A, ainda sem cenários funcionais reais.
- Mobile: análise, unitários e testes de tela mantidos verdes para garantir regressão zero.

## Evidências de validação

- `make backend-unit-test`: PASS, 94 testes, JaCoCo PASS.
- `make backend-static-analysis`: PASS, 0 violações Checkstyle.
- `make backend-integration-test`: PASS, 94 unitários + 1 integração, Flyway v007, JaCoCo PASS.
- `make mobile-static-analysis`: PASS.
- `make mobile-unit-test`: PASS, 99.51% cobertura.
- `make mobile-screen-test`: PASS, 22 testes.
- `make mobile-integration-test`: N/A por ausência de Android Emulator, iOS Simulator ou Chrome.
- `make functional-test`: N/A por ausência de cenários funcionais reais.

## Riscos ou limitações remanescentes

- OTP e refresh token dependem das histórias de autenticação, mas já devem usar a porta de proteção criada aqui.
- Criptografia em repouso de banco, backups e storage depende da infraestrutura de produção.
- KMS/HSM permanecem evolução futura, sem bloqueio arquitetural.

## Arquivos ou módulos relevantes

- `worklink-api/src/main/java/br/com/worklink/application/security/port/ProtectSensitiveValuePort.java`
- `worklink-api/src/main/java/br/com/worklink/application/security/port/ProtectedSensitiveValuePurpose.java`
- `worklink-api/src/main/java/br/com/worklink/infrastructure/security/HmacSha256SensitiveValueProtectorAdapter.java`
- `worklink-api/src/main/resources/db/migration/V007__protect_professional_document_number.sql`
- `docs/arquitetura/criptografia-protecao-dados.md`

## Justificativa do versionamento

Entrega `MINOR`, porque adiciona capacidade técnica nova de proteção de dados sensíveis e altera a persistência do documento profissional sem quebrar contrato público.
