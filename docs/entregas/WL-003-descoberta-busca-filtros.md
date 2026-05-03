# Entrega WL-003 — Descoberta por categoria, cidade e palavra-chave

## Resultado

Descoberta inicial criada para listar profissionais por categoria, cidade e palavra-chave, com fluxo sem login, limpeza de filtros e estado vazio no mobile.

## Entregues

- Critério de busca de profissionais com categoria opcional, múltiplas cidades e palavra-chave.
- Endpoint `GET /api/v1/professionals` aceitando filtros por categoria, cidade única, múltiplas cidades e palavra-chave.
- Adapter JDBC aplicando filtros combinados por categoria, cidades e busca textual em nome/descrição curta.
- Tela mobile mínima de descoberta com campo de busca, filtros por categoria/cidade, limpeza e estado vazio.
- Testes BDD/TDD de aplicação, API, infraestrutura, controller mobile, estado mobile e tela.

## Validações

- `make backend-static-analysis`
- `make backend-unit-test`
- `make backend-integration-test`
- `make mobile-static-analysis`
- `make mobile-unit-test`
- `make mobile-screen-test`
- `make mobile-integration-test`
- `make functional-test`

## Observações

- Ranking sofisticado, recomendação por IA e busca nacional permanecem fora do escopo.
- A integração HTTP real do mobile será conectada em história futura; a tela usa dados locais mínimos nesta entrega.
- `make functional-test` ainda retorna `N/A` porque os cenários funcionais reais não foram criados.
- `make mobile-integration-test` retorna `N/A` sem Android Emulator, iOS Simulator ou Chrome disponível no container.
