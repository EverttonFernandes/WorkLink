# Criptografia e Proteção de Dados

## Objetivo

Definir a proteção mínima obrigatória da V1 para dados sensíveis em trânsito, repouso e campo, sem acoplar regras de negócio a framework, storage ou provedor externo.

## Dados em Trânsito

Ambientes reais devem exigir TLS na borda de entrada da aplicação. O ambiente local pode operar sem TLS apenas para desenvolvimento, testes automatizados e execução via Docker Compose.

Na V1, a terminação TLS deve ficar fora das regras de negócio, em infraestrutura de borda como proxy, load balancer ou plataforma de deploy. O backend não deve depender de detalhes dessa infraestrutura para executar casos de uso.

## Proteção de Campo

CPF/CNPJ, OTP e refresh tokens não devem ser persistidos em claro.

A aplicação expõe a porta `ProtectSensitiveValuePort` para proteger valores sensíveis. A infraestrutura implementa essa porta com HMAC-SHA-256 e pepper configurável por `WORKLINK_SENSITIVE_VALUE_PEPPER`.

As finalidades de proteção são explícitas em `ProtectedSensitiveValuePurpose`:

- `DOCUMENT_NUMBER`
- `ONE_TIME_PASSWORD`
- `REFRESH_TOKEN`

O propósito faz parte do material hasheado para impedir reutilização indevida do mesmo valor entre contextos diferentes.

## Documento Profissional

O cadastro progressivo continua aceitando CPF/CNPJ como entrada operacional, mas a persistência passa a guardar apenas `document_number_hash`.

A migração `V007__protect_professional_document_number.sql` remove a coluna `document_number`, cria `document_number_hash` e mantém índice único parcial para deduplicação sem plaintext.

## Evidências Confidenciais e Storage

Evidências confidenciais devem usar o modelo de storage seguro definido em WLT-014. A V1 mantém metadados internos, escopo de acesso e chave de storage fora das respostas públicas.

Criptografia em repouso de banco, backups e storage deve ser responsabilidade da infraestrutura escolhida para produção. KMS definitivo e HSM não são obrigatórios na V1, mas a fronteira de portas e adaptadores não pode impedir essa evolução.

## Logs

Dados sensíveis não devem aparecer em logs de aplicação, mensagens de erro ou respostas públicas. Erros de validação devem informar o problema sem ecoar CPF/CNPJ, OTP, refresh token, segredos ou chaves internas.

## Decisão Arquitetural

A criptografia fica atrás de porta de aplicação e adaptador de infraestrutura. O domínio conhece apenas sinais de negócio, como documento fornecido ou perfil completo, e não conhece algoritmo, pepper, Spring, banco ou storage.
