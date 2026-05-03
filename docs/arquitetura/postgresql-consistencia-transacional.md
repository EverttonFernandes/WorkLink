# PostgreSQL e consistência transacional

## Objetivo

Definir PostgreSQL como fonte da verdade para dados transacionais críticos do WorkLink V1.

## Fonte da verdade

PostgreSQL é a fonte primária de dados transacionais.

Cache, métricas, ranking e índices derivados não podem substituir PostgreSQL para decisões críticas de negócio.

## Dados com consistência forte

Devem ser modelados no PostgreSQL com transações e constraints adequadas quando surgirem nas histórias funcionais:

- usuários;
- profissionais;
- categorias;
- cidades;
- cidades atendidas;
- contatos iniciados;
- feedback pós-contato;
- avaliações;
- denúncias;
- moderação;
- disponibilidade;
- auditoria;
- administração;
- autenticação e autorização;
- vínculos entre usuário, contato, avaliação e denúncia.

## Dados que podem aceitar consistência eventual

Somente dados derivados podem aceitar consistência eventual:

- métricas agregadas;
- ranking calculado;
- profissionais em destaque;
- contadores de visualização;
- estatísticas públicas;
- taxa de resposta;
- indicadores derivados;
- cache da home;
- cache de perfis públicos.

## Regra para cache

Cache nunca é fonte da verdade.

Qualquer cache deve:

- ser reconstruível a partir do PostgreSQL;
- ter invalidação explícita quando impactar segurança, moderação ou disponibilidade;
- não armazenar dado sensível sem necessidade;
- não esconder bloqueio, denúncia grave ou alteração crítica.

## Migrations

As migrations devem ficar em:

```text
worklink-api/src/main/resources/db/migration
```

Padrão de nome:

```text
V<numero>__<descricao_em_ingles_ou_portugues_sem_acentos>.sql
```

Exemplo:

```text
V001__create_worklink_schema.sql
```

## Execução local

As migrations devem ser executadas em Docker:

```bash
make db-migrate
```

O comando deve subir PostgreSQL e aplicar as migrations via container Flyway.

## Limite pragmático

Não criar tabelas funcionais antes da história funcional correspondente.

Esta história estabelece a fundação de banco e consistência; a modelagem de domínio deve surgir incrementalmente em `WL-*`.
