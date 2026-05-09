# Disponibilidade e Escalabilidade Stateless

## Objetivo

A WLT-016 prepara a API do WorkLink para execução stateless e múltiplas instâncias futuras, mantendo a V1 simples e sem
infraestrutura operacional desnecessária.

## Decisões

- A API não usa sessão HTTP como fonte de autenticação.
- Access tokens são assinados e autocontidos.
- Refresh sessions, OTPs, auditorias, contatos, avaliações e denúncias são persistidos no PostgreSQL.
- Arquivos não são gravados no filesystem do container da API; a aplicação registra metadados e object keys para storage
  externo.
- O container da API deve responder readiness em `/actuator/health/readiness`.
- Encerramento do processo usa graceful shutdown com janela controlada.
- Integrações externas devem usar timeouts e retry finito por configuração.

## Readiness e liveness

- `/actuator/health/liveness` indica se o processo está vivo.
- `/actuator/health/readiness` inclui `readinessState` e `db`, bloqueando tráfego quando a API não consegue acessar a
  dependência transacional principal.

O Docker Compose e o Dockerfile usam readiness como healthcheck da API.

## Timeouts e retry

A configuração operacional mínima é:

- `WORKLINK_SHUTDOWN_PHASE_TIMEOUT`
- `WORKLINK_ASYNC_REQUEST_TIMEOUT`
- `WORKLINK_SERVER_CONNECTION_TIMEOUT`
- `WORKLINK_DATABASE_CONNECTION_TIMEOUT_MS`
- `WORKLINK_DATABASE_VALIDATION_TIMEOUT_MS`
- `WORKLINK_EXTERNAL_HTTP_CONNECTION_TIMEOUT`
- `WORKLINK_EXTERNAL_HTTP_READ_TIMEOUT`
- `WORKLINK_EXTERNAL_HTTP_MAX_RETRY_ATTEMPTS`

Adapters externos futuros devem respeitar esses limites via porta/adaptador, sem acoplar framework ou cliente HTTP às
regras de negócio.

## Cache

A V1 não adiciona cache funcional enquanto não houver gargalo real. Quando cache for introduzido:

- PostgreSQL continua sendo a fonte da verdade.
- O padrão preferencial é cache-aside.
- Dados de bloqueio de profissional, denúncia grave, autorização e privacidade devem ter TTL curto ou invalidação
  explícita.
- Nenhuma decisão sensível pode depender apenas de cache.

## Limites

Esta entrega não adiciona Kubernetes, load balancer real, alta disponibilidade multi-região, service mesh, filas ou
workers. Esses itens só devem entrar quando o produto justificar a complexidade.
