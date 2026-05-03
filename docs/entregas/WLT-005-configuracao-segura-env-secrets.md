# Entrega WLT-005 — Configuração segura e gestão de secrets

## Resultado

Configuração sensível padronizada por variáveis de ambiente, com `.env` local fora do Git e `.env.example` versionado apenas com valores fictícios.

## Entregues

- `.env.example` com variáveis para banco, Redis, MinIO, storage, JWT, criptografia, OTP/SMS, CORS e feature flags.
- `compose.yml` sem credenciais hardcoded de desenvolvimento.
- `Makefile` executando Docker Compose com `--env-file`.
- `worklink-api/src/main/resources/application.yml` lendo configurações por env vars.
- Teste backend validando resolução das configurações sensíveis.
- Documentação operacional atualizada.

## Validacoes

- `WORKLINK_ENV_FILE=.env.example docker compose --env-file .env.example config`
- `make backend-test`
- `git diff --check`

## Observacoes

- `.env` é gerado localmente pelo Makefile quando ausente e segue ignorado pelo Git.
- Secrets reais não devem ser versionados.
- O mecanismo seguro de secrets em CI será aplicado quando a pipeline for criada.
