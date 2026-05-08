# WLT-013 — Criptografia e proteção de dados

## História

Como time técnico, quero proteger dados sensíveis em trânsito, repouso e campo, para reduzir exposição de CPF/CNPJ, OTP, tokens, evidências e segredos operacionais.

## Fonte oficial

- `docs/jira-pessoal/historias-tecnicas/WLT-013-criptografia-protecao-dados.md`
- `docs/requisitos/epico-requisitos-nao-funcionais.md`
- `docs/spec-driven-development/padroes-de-testes.md`
- `docs/spec-driven-development/codigo-limpo.md`
- `docs/spec-driven-development/padrões-de-projeto-e-design-de-codigo.md`

## Critérios de aceite

- [x] Comunicações devem exigir TLS em ambientes reais.
- [x] OTP deve ser hasheado.
- [x] Refresh token deve ser hasheado.
- [x] CPF/CNPJ não deve ser persistido sem proteção definida.
- [x] Evidências confidenciais devem ter proteção em repouso.
- [x] Dados sensíveis não devem aparecer em logs.

## Escopo técnico

- Criar porta de aplicação para hashing de valores sensíveis.
- Implementar adaptador HMAC-SHA-256 com pepper configurável por variável de ambiente.
- Persistir documento profissional apenas como hash protegido.
- Preparar finalidades de hash para CPF/CNPJ, OTP e refresh token.
- Documentar exigência de TLS, proteção em repouso de storage/banco/backups e ausência de dados sensíveis em logs.
- Cobrir regras com testes BDD/TDD.

## Fora do escopo

- HSM obrigatório.
- KMS definitivo obrigatório na V1.
- Fluxo completo de OTP e refresh token.
- Upload binário real para S3/MinIO.

## Evidências de aceite

- TLS é requisito documentado para ambientes reais em `docs/arquitetura/criptografia-protecao-dados.md`.
- A porta `ProtectSensitiveValuePort` e o enum `ProtectedSensitiveValuePurpose` preparam hashing obrigatório para CPF/CNPJ, OTP e refresh token.
- O adaptador `HmacSha256SensitiveValueProtectorAdapter` protege valores com HMAC-SHA-256 e pepper configurável.
- A migração `V007__protect_professional_document_number.sql` remove `document_number` em claro e cria `document_number_hash`.
- Evidências confidenciais seguem o modelo de storage seguro entregue em WLT-014 e documentado como proteção em repouso.
- Revisão por busca textual não encontrou logs de dados sensíveis adicionados nesta história.
