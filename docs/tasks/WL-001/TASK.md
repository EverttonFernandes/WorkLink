# WL-001 — Fundação de categorias, cidades e profissionais mínimos

## Fonte

- História: `docs/jira-pessoal/historias/WL-001-fundacao-categorias-cidades-profissionais.md`
- Ordem oficial: 10 em `docs/jira-pessoal/KANBAN-OFICIAL.md`
- Tipo: Negócio
- Versão sugerida: `MINOR`

## Objetivo

Criar a base funcional mínima para categorias, cidades e profissionais, permitindo que o produto comece a registrar e listar dados essenciais.

## Escopo incluído

- Cadastro de categorias de serviço.
- Cadastro de cidades de atendimento.
- Cadastro de profissional com nome, WhatsApp, cidade, categoria e descrição curta.
- Classificação automática do profissional mínimo como `BASIC_PROFILE`.
- Garantia explícita de que perfil básico não representa garantia de qualidade.
- Persistência relacional inicial para catálogo e profissionais.
- Endpoints REST versionados para cadastro e listagem.

## Fora do escopo

- Busca avançada, ranking, pagamento, garantia, verificação documental e perfil público completo.
- Autenticação, autorização e moderação administrativa.
- Telas mobile.

## Critérios de aceite

- Deve existir cadastro de categorias.
- Deve existir cadastro de cidades.
- Deve existir cadastro de profissional com campos mínimos.
- Profissional sem campos obrigatórios deve ser rejeitado.
- Profissional válido deve ser classificado como perfil básico.
- Perfil básico não deve ser apresentado como garantia de qualidade.
