# WLT-004 — Ambiente local reproduzível com Docker Compose e Makefile

## Fonte

- História: `docs/jira-pessoal/historias-tecnicas/WLT-004-ambiente-local-docker-makefile.md`
- Ordem oficial: 04 em `docs/jira-pessoal/KANBAN-OFICIAL.md`
- Tipo: Técnica
- Versão sugerida: `MINOR`

## Objetivo

Permitir subir e operar dependências locais com comandos simples e previsíveis.

## Escopo incluído

- Docker Compose com `worklink-api`, `postgres`, `redis` e `minio`.
- Dockerfile multi-stage da API.
- Makefile com comandos principais.
- Comandos para subir, derrubar, reiniciar, ver logs, testar e migrar.

## Fora do escopo

- Kubernetes.
- Observability stack obrigatória.
- Cloud production setup.

## Critérios de aceite

- `make up` deve subir dependências principais.
- `make down` deve parar ambiente local.
- `make test`, `make test-unit`, `make test-integration` e `make test-functional` devem existir ou estar documentados.
- Ambiente local não deve depender de passos manuais frágeis.
- Imagem da API deve separar build e runtime quando existir Dockerfile da aplicação.
- Imagem final da API não deve conter caches, ferramentas de build, dependências de desenvolvimento ou arquivos desnecessários.
- Dockerfile deve favorecer cache de dependências e build reproduzível.
- Dockerfile ou aplicação deve disponibilizar health check compatível com operação local e futura produção.
- API não deve depender de estado persistente no filesystem local.
