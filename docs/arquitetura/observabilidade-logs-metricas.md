# Observabilidade, Logs e Metricas

## Objetivo

A WLT-015 estabelece a observabilidade minima da V1 do WorkLink para diagnosticar saude, falhas e fluxos criticos sem
introduzir uma stack operacional complexa cedo demais.

## Health checks e metricas

A API expõe endpoints mínimos do Spring Actuator:

- `/actuator/health`
- `/actuator/health/liveness`
- `/actuator/health/readiness`
- `/actuator/info`
- `/actuator/metrics`

As metricas recebem a tag `application=worklink-api`, permitindo separar a origem dos sinais quando houver coleta
externa no futuro.

## Correlation id

Toda requisição HTTP recebe o header `X-Correlation-Id` na resposta. Quando o cliente envia um identificador valido,
ele é preservado; quando o header está ausente ou inseguro, a API gera um UUID.

O identificador fica no MDC com a chave `correlationId`, sendo removido ao final da requisição para evitar vazamento
entre threads.

## Logs estruturados

O console da API usa formato `key=value` com campos estáveis:

- `timestamp`
- `level`
- `service`
- `correlation_id`
- `logger`
- `message`

Esse formato mantém a imagem e a execução local simples, mas já prepara ingestão futura por ferramentas de logs.

## Eventos operacionais

Fluxos críticos podem registrar eventos por meio de uma porta de aplicação:

- tipo do evento
- severidade
- mensagem
- contexto seguro

A aplicação não conhece SLF4J, Actuator ou detalhes de infraestrutura. O adaptador de infraestrutura escreve o evento
em log estruturado e sanitizado.

## Sanitização

Antes de registrar eventos operacionais, valores sensíveis são mascarados. A estratégia cobre, no mínimo:

- credenciais, tokens e segredos
- OTP
- documentos pessoais ou empresariais
- telefone completo
- contexto operacional com dados proibidos

Payload bruto, evidências, localização precisa e dados sensíveis de moderação não devem ser registrados em logs
operacionais.

## Limites

Esta entrega não adiciona Prometheus, Grafana, ELK, tracing distribuído ou alertas externos reais. Esses recursos
devem entrar apenas quando houver necessidade operacional comprovada.
