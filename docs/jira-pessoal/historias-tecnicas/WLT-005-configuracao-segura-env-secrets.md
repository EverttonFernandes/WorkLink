# WLT-005 — Configuração segura e gestão de secrets

## Objetivo

Padronizar configuração por variáveis de ambiente e impedir versionamento de secrets.

## Valor técnico

Reduz risco de vazamento de credenciais e prepara o projeto para ambientes locais, CI e produção.

## RNFs relacionados

- RNF08, RNF03

## Escopo incluído

- `.env.example` com valores fictícios.
- `.env` real ignorado pelo Git.
- Configurações por env vars para banco, cache, storage, JWT, criptografia, OTP/SMS, CORS e flags.
- Documentação mínima de variáveis.

## Fora do escopo

- Escolha definitiva de secrets manager.
- Vault/Kubernetes Secrets obrigatório.

## Critérios de aceite

- Nenhum segredo real deve estar versionado.
- `.env.example` deve conter apenas valores fictícios.
- Aplicação deve ler configuração por env vars.
- JWT secret, chaves de criptografia e credenciais externas não devem ter default inseguro.
- CI deve usar mecanismo seguro para secrets quando configurado.

## Entrega versionável

- Tipo sugerido: `MINOR`
