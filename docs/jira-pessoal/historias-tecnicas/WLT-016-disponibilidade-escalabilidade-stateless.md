# WLT-016 — Disponibilidade e escalabilidade stateless

## Objetivo

Preparar a API para rodar stateless e suportar múltiplas instâncias futuramente.

## Valor técnico

Evita dependência de estado local e permite evolução para load balancer sem reescrita.

## RNFs relacionados

- RNF10, RNF11, RNF15

## Escopo incluído

- API stateless.
- Sem sessão em memória local.
- Banco externo.
- Cache externo.
- Storage externo.
- Readiness check.
- Graceful shutdown.
- Timeouts e retry controlado.
- Cache-aside quando houver cache.

## Fora do escopo

- Alta disponibilidade multi-região.
- Kubernetes obrigatório.
- Filas/workers obrigatórios.

## Critérios de aceite

- Sessão não deve depender de memória local.
- Arquivos não devem ser persistidos no container da API.
- API deve estar pronta para múltiplas instâncias.
- Integrações externas devem ter timeout.
- Retry deve ser controlado, não infinito.
- Cache não deve ser fonte da verdade.
- Bloqueio de profissional e denúncia grave devem invalidar cache aplicável rapidamente.

## Entrega versionável

- Tipo sugerido: `MINOR`
