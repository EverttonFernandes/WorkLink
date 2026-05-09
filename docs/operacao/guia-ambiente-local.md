# Guia de ambiente local

## Pré-requisito único

- Docker com suporte a Compose.

Não instale Java, Maven, Flutter ou Node diretamente para validar o projeto.

## Comandos principais

```bash
make up
make api
make logs
make down
make clean
```

## Banco e migrations

```bash
make db-up
make db-migrate
make db-down
```

## Variáveis locais

Na primeira execução, o Makefile cria `.env` a partir de `.env.example` quando necessário. O `.env` real não deve ser
commitado.
