# WLT-014 — Storage seguro de arquivos

## História

Como equipe técnica, precisamos de uma fundação segura para fotos, portfólio, anexos de denúncia e evidências, para que arquivos não sejam armazenados no banco nem expostos indevidamente.

## Fonte oficial

- `docs/jira-pessoal/historias-tecnicas/WLT-014-storage-seguro-arquivos.md`
- `docs/requisitos/epico-requisitos-nao-funcionais.md`

## Critérios de aceite

- [x] Arquivos não devem ser armazenados diretamente no banco.
- [x] Evidências confidenciais não devem ser públicas.
- [x] Caminho interno do storage não deve ser exposto ao usuário.
- [x] Upload deve validar tipo e tamanho.
- [x] Extensões perigosas devem ser bloqueadas.
- [x] Acesso a anexos de denúncia deve ser restrito e auditável.

## Escopo técnico

- Criar domínio de arquivo armazenado com propósito, classificação e metadados.
- Criar caso de uso para preparar upload seguro.
- Criar porta e adapter JDBC para persistir somente metadados.
- Criar migração de banco para metadados de arquivos.
- Expor endpoint backend mínimo para preparação de upload.
- Cobrir domínio, caso de uso, API, adapter e migration com BDD/TDD.

## Fora do escopo

- Upload binário real para S3/MinIO.
- CDN.
- Antivírus obrigatório.
- Processamento complexo de mídia.
- Autorização real de anexos de denúncia antes das histórias de auth/auditoria.
