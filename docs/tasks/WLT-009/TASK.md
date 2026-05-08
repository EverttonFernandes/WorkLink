# WLT-009 — Autenticação segura, sessões e tokens

## História

Como time técnico, quero implementar autenticação segura por telefone com OTP, access token, refresh token e revogação, para sustentar os fluxos sensíveis do WorkLink V1.

## Fonte oficial

- `docs/jira-pessoal/historias-tecnicas/WLT-009-autenticacao-sessoes-tokens.md`
- `docs/requisitos/epico-requisitos-de-negocio.md`
- `docs/requisitos/epico-requisitos-nao-funcionais.md`
- `docs/spec-driven-development/padroes-de-testes.md`
- `docs/spec-driven-development/codigo-limpo.md`
- `docs/spec-driven-development/padrões-de-projeto-e-design-de-codigo.md`

## Critérios de aceite

- [x] OTP nunca deve ser armazenado em texto puro.
- [x] OTP deve expirar.
- [x] Falhas recorrentes devem ser limitadas.
- [x] Autenticação não deve revelar se telefone já existe.
- [x] Refresh token não deve ser salvo em texto puro.
- [x] Tokens não devem aparecer em logs.

## Escopo técnico

- Criar modelo técnico de conta cliente identificada por telefone verificado.
- Criar solicitação e verificação de OTP com expiração curta.
- Hashear OTP e refresh token usando `ProtectSensitiveValuePort`.
- Criar access token assinado e refresh token opaco.
- Persistir refresh token apenas como hash.
- Rotacionar refresh token ao usar `/refresh`.
- Permitir revogação de sessão.
- Criar endpoints REST mínimos para request, verify, refresh e revoke.
- Cobrir regras com testes BDD/TDD.

## Fora do escopo

- Login social.
- MFA avançado.
- Provedor OTP definitivo.
- Tela mobile real de login.
- Autorização por perfil/ownership, que pertence à WLT-010.

## Evidências

- `make backend-unit-test`: PASS, 111 testes, JaCoCo 95%+ validado.
- `make backend-static-analysis`: PASS, Checkstyle sem violações.
- `make backend-integration-test`: PASS, Flyway aplicou até `v008`.
- `make mobile-static-analysis`: PASS, Flutter analyze sem issues.
- `make mobile-unit-test`: PASS, cobertura unitária mobile 99.51%.
- `make mobile-screen-test`: PASS, 22 testes de widget/tela.
- `make mobile-integration-test`: N/A, sem emulator/simulator/Chrome disponível.
- `make functional-test`: N/A, sem cenários funcionais reais nesta fase.
- `git diff --check`: PASS.
- Varredura local de segredos: PASS, apenas placeholder esperado `WORKLINK_POSTGRES_PASSWORD` em `compose.yml`.
