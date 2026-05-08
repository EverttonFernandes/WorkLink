# WLT-014 — Storage seguro de arquivos

## Versão

- Tipo: `MINOR`
- Tag planejada: `v0.15.0`

## Entrega

Foi criada a fundação segura de storage para fotos, portfólio, anexos e evidências, com metadados persistidos no banco e chave interna aleatória. O backend prepara uploads validando propósito, tipo, extensão e tamanho, sem armazenar bytes no PostgreSQL e sem expor o caminho interno ao consumidor da API.

## Escopo entregue

- Domínio `StoredFile` com propósito, classificação, validação por allow-list e geração de chave interna aleatória.
- Caso de uso `PrepareFileUploadUseCase` para preparar upload seguro.
- Porta `SaveStoredFileMetadataPort` e adapter JDBC para persistir apenas metadados.
- Migração `V004__create_stored_file_metadata.sql` para `worklink.stored_files`.
- Endpoint `POST /api/v1/storage/uploads/prepare` sem exposição de `storageObjectKey`.
- Testes BDD/TDD de domínio, aplicação, API e infraestrutura.

## Decisões

- O upload binário real para S3/MinIO ficou fora desta entrega para manter a fatia pequena e evitar acoplamento prematuro a SDK externo.
- Evidências e anexos de denúncia já nascem classificados como `CONFIDENTIAL`.
- A chave interna nunca usa o nome original do arquivo.
- O contrato HTTP recebe o propósito como texto e a aplicação converte para o domínio, preservando a fronteira entre API e regra de negócio.

## Gates

- `make backend-static-analysis`: PASS
- `make backend-unit-test`: PASS, 81 testes, JaCoCo >= 95%
- `make backend-integration-test`: PASS
- `make mobile-static-analysis`: PASS
- `make mobile-unit-test`: PASS, cobertura 100.00%
- `make mobile-screen-test`: PASS
- `make mobile-integration-test`: N/A, sem emulador/simulador/Chrome no container
- `make functional-test`: N/A, sem cenários reais
- `git diff --check`: PASS
- Scan de segredos: PASS, apenas referência parametrizada `${WORKLINK_POSTGRES_PASSWORD}` em `compose.yml`

## Fora do escopo rastreado

- Upload binário real para S3/MinIO.
- URLs assinadas com expiração.
- Auditoria operacional completa de acesso aos anexos de denúncia.
- Antivírus ou processamento avançado de mídia.
