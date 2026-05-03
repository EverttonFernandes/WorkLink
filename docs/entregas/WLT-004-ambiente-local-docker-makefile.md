# Entrega WLT-004 — Ambiente local reproduzivel

## Resultado

Ambiente local consolidado com Docker Compose e Makefile, sem instalacao direta de ferramentas na maquina.

## Entregues

- `docker/worklink-api.Dockerfile` multi-stage para a API.
- `compose.yml` com `worklink-api`, PostgreSQL, Redis, MinIO e migrations.
- `Makefile` com comandos operacionais: `up`, `down`, `restart`, `logs`, `api`, `db`, `redis`, `storage`, `migrate`, `clean`.
- Healthchecks para API e dependencias locais.
- Documentacao operacional em `README.md` e `docker/README.md`.

## Validacoes

- `docker compose config`
- `docker compose build worklink-api`
- `make up`
- `make api`
- `docker compose exec -T worklink-api wget -qO- http://localhost:8080/actuator/health`
- `make backend-test`
- `git diff --check`

## Observacoes

- Credenciais locais continuam hardcoded apenas para ambiente de desenvolvimento e serao tratadas na WLT-005.
- A imagem do MinIO foi fixada por digest para evitar runtime mutavel.
