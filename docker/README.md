# Docker

Pasta reservada para containerizacao e ambiente local do WorkLink.

## Diretrizes

- A validacao inicial da WLT-001 ja usa Docker Compose no arquivo raiz `compose.yml`.
- `make backend-unit-test` executa testes unitarios backend em container.
- `make backend-integration-test` executa o ciclo Maven `verify`, reservado para testes de integracao quando existirem.
- `make mobile-unit-test` executa testes mobile em container.
- `make mobile-screen-test` executa testes de tela mobile quando a suite existir.
- `make functional-test` executa o runner de testes funcionais quando `functional-tests/run.sh` existir.
- `make db-up` sobe o PostgreSQL local.
- `make db-migrate` aplica migrations no PostgreSQL usando Flyway em container.
- `make db-down` derruba os servicos Docker do projeto.
- `make test` agrega a matriz oficial de testes.
- Docker Compose operacional completo com banco e servicos auxiliares sera tratado na historia `WLT-004`.
- Imagem Docker multi-stage da API sera tratada quando a aplicacao tiver runtime empacotavel.
- A imagem final de producao nao deve carregar ferramentas de build, caches, secrets ou dependencias de desenvolvimento.
