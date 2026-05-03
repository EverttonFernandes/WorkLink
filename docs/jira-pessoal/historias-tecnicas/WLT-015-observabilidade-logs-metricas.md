# WLT-015 — Observabilidade, logs e métricas

## Objetivo

Disponibilizar observabilidade mínima para diagnosticar saúde, erros e fluxos críticos.

## Valor técnico

Permite operar a V1 com visibilidade suficiente sem criar stack complexa cedo demais.

## RNFs relacionados

- RNF09, RNF11

## Escopo incluído

- Health checks.
- Logs estruturados.
- Correlation id.
- Métricas básicas.
- Monitoramento de erros.
- Rastreabilidade de fluxos críticos.
- Eventos importantes da V1.

## Fora do escopo

- ELK obrigatório.
- Prometheus/Grafana obrigatórios se ainda não forem necessários.
- Observabilidade distribuída complexa.

## Critérios de aceite

- API deve expor health check.
- Logs devem ser estruturados.
- Requisições devem ter correlation id.
- Eventos críticos devem ser registráveis.
- Logs não devem conter dados sensíveis proibidos.
- Falhas relevantes devem ser rastreáveis.

## Entrega versionável

- Tipo sugerido: `MINOR`
