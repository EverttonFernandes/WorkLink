# WLT-004 — Ambiente local reproduzível com Docker Compose e Makefile

## Objetivo

Permitir subir e operar dependências locais com comandos simples e previsíveis.

Quando houver container da API, garantir que o Dockerfile já nasça com multi-stage build, separando build e runtime para não levar dependências de desenvolvimento para a imagem final.

## Valor técnico

Reduz fricção de onboarding, execução local, testes e uso por agentes.

## RNFs relacionados

- RNF07, RNF10, RNF11

## Escopo incluído

- Docker Compose com `worklink-api`, `postgres`, `redis` e `minio`.
- Dockerfile da API com multi-stage build quando a API for containerizada.
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

## Entrega versionável

- Tipo sugerido: `MINOR`
