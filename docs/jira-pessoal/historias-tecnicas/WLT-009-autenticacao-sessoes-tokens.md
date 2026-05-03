# WLT-009 — Autenticação segura, sessões e tokens

## Objetivo

Implementar base técnica segura para autenticação por telefone com OTP, access token, refresh token e revogação.

## Valor técnico

Garante identidade segura e reduz riscos de abuso em fluxos sensíveis.

## RNFs relacionados

- RNF03, RNF16

## Escopo incluído

- OTP com expiração curta.
- OTP armazenado em hash.
- Limite de tentativas e rate limit quando possível.
- Proteção contra enumeração.
- Access token e refresh token.
- Refresh token com rotação e armazenamento seguro.
- Revogação de sessão.

## Fora do escopo

- Login social.
- MFA avançado.
- Provedor OTP definitivo se ainda pendente.

## Critérios de aceite

- OTP nunca deve ser armazenado em texto puro.
- OTP deve expirar.
- Falhas recorrentes devem ser limitadas.
- Autenticação não deve revelar se telefone já existe.
- Refresh token não deve ser salvo em texto puro.
- Tokens não devem aparecer em logs.

## Entrega versionável

- Tipo sugerido: `MINOR`
