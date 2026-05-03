# WLT-014 — Storage seguro de arquivos

## Objetivo

Implementar estratégia segura para fotos, portfólio, anexos de denúncia e evidências.

## Valor técnico

Evita exposição indevida de arquivos, principalmente evidências confidenciais.

## RNFs relacionados

- RNF12, RNF03, RNF04

## Escopo incluído

- Storage S3-compatible em produção.
- MinIO local.
- Metadados no banco.
- Classificação de arquivos públicos/semi-públicos e confidenciais.
- Bucket privado por padrão.
- URLs assinadas com expiração quando necessário.
- Validação de tipo, tamanho e extensão.
- Nomes internos aleatórios.

## Fora do escopo

- CDN avançada.
- Processamento complexo de mídia.
- Antivírus obrigatório se não houver infraestrutura definida.

## Critérios de aceite

- Arquivos não devem ser armazenados diretamente no banco.
- Evidências confidenciais não devem ser públicas.
- Caminho interno do storage não deve ser exposto ao usuário.
- Upload deve validar tipo e tamanho.
- Extensões perigosas devem ser bloqueadas.
- Acesso a anexos de denúncia deve ser restrito e auditável.

## Entrega versionável

- Tipo sugerido: `MINOR`
