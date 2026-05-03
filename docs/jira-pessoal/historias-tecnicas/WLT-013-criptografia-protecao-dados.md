# WLT-013 — Criptografia e proteção de dados

## Objetivo

Definir e aplicar proteção criptográfica para dados em trânsito, repouso e campo.

## Valor técnico

Protege dados sensíveis como CPF/CNPJ, telefones, denúncias, evidências, tokens e OTP.

## RNFs relacionados

- RNF05, RNF03

## Escopo incluído

- HTTPS/TLS como requisito.
- Criptografia em repouso para banco, backups e storage.
- Criptografia ou proteção equivalente em campo para dados sensíveis.
- Hash de OTP, refresh tokens e identificadores sensíveis.
- Hash com segredo/pepper para CPF/CNPJ normalizado quando usado para deduplicação.

## Fora do escopo

- HSM obrigatório.
- KMS definitivo obrigatório na V1.

## Critérios de aceite

- Comunicações devem exigir TLS em ambientes reais.
- OTP deve ser hasheado.
- Refresh token deve ser hasheado.
- CPF/CNPJ não deve ser persistido sem proteção definida.
- Evidências confidenciais devem ter proteção em repouso.
- Dados sensíveis não devem aparecer em logs.

## Entrega versionável

- Tipo sugerido: `MINOR`
