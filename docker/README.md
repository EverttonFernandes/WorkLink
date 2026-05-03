# Docker

Pasta reservada para containerizacao e ambiente local do WorkLink.

## Diretrizes

- A validacao inicial da WLT-001 ja usa Docker Compose no arquivo raiz `compose.yml`.
- `make backend-test` executa Maven com Java 21 em container.
- `make mobile-test` executa Flutter em container.
- Docker Compose operacional completo com banco e servicos auxiliares sera tratado na historia `WLT-004`.
- Imagem Docker multi-stage da API sera tratada quando a aplicacao tiver runtime empacotavel.
- A imagem final de producao nao deve carregar ferramentas de build, caches, secrets ou dependencias de desenvolvimento.
