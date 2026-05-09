# Guia de variáveis de ambiente

## Fonte versionada

- `.env.example`

## Fonte local

- `.env`

O `.env` local é ignorado pelo Git. Secrets reais não devem ser documentados nem versionados.

## Regras

- Toda variável nova deve ter valor fictício seguro em `.env.example`.
- Variável sensível deve ser lida por configuração, nunca hardcoded.
- Mudanças operacionais devem ser refletidas no README e nos guias de execução.
