# Entrega WL-001 — Fundação de categorias, cidades e profissionais mínimos

## Resultado

Base funcional mínima criada para cadastrar e listar categorias, cidades e profissionais no backend.

## Entregues

- Migration relacional para `service_categories`, `service_cities` e `professionals`.
- Domínio com validação de campos obrigatórios e classificação `BASIC_PROFILE`.
- Casos de uso de cadastro e listagem para catálogo e profissionais.
- Portas de aplicação e adapters JDBC para PostgreSQL.
- Endpoints REST versionados para categorias, cidades e profissionais.
- Tratamento HTTP de erros de regra de aplicação.
- Testes unitários de domínio, aplicação, API, infraestrutura e arquitetura.
- Teste de integração aplicando migrations no PostgreSQL real via Docker.

## Validações

- `make backend-static-analysis`
- `make backend-unit-test`
- `make backend-integration-test`

## Observações

- O perfil básico não indica garantia de qualidade: `qualityGuarantee=false`.
- Busca avançada, ranking, autenticação, autorização e telas mobile seguem fora desta entrega.
