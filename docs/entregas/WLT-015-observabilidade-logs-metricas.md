# Entrega WLT-015 — Observabilidade, logs e métricas

## Identificador

- História: `WLT-015`
- Data: `2026-05-09`
- Tipo semântico sugerido: `MINOR`

## Objetivo de negócio

Dar ao WorkLink V1 rastreabilidade operacional mínima para diagnosticar saúde, erros e fluxos críticos sem acoplar a
aplicação a uma stack externa de observabilidade.

## Personas afetadas

- Time técnico: passa a ter health checks, correlation id, logs estruturados e eventos operacionais seguros.
- Operação/SRE: passa a ter sinais mínimos para monitorar API e investigar falhas relevantes.
- Usuário final: ganha base técnica para suporte mais rastreável sem exposição indevida de dados sensíveis.

## Requisitos atendidos

- RNF09 — Observabilidade mínima.
- RNF11 — Disponibilidade e resiliência, no recorte de health checks e prontidão operacional.
- Regras de segurança de logs do épico de requisitos não funcionais.

## O que foi implementado

- Configuração de Actuator com health, probes, detalhes operacionais e métricas básicas.
- Correlation id HTTP com geração segura, preservação de header válido e propagação para MDC.
- Logs de console em formato estruturado `key=value`.
- Porta de aplicação para registro de eventos operacionais críticos.
- Adaptador de infraestrutura para registrar eventos com severidade, tipo, mensagem e contexto seguro.
- Sanitização de valores sensíveis antes de registrar logs operacionais.
- Documentação da estratégia mínima de observabilidade.

## O que não foi implementado

- ELK, Prometheus, Grafana ou tracing distribuído.
- Alertas externos reais.
- Instrumentação específica de todos os fluxos de negócio futuros.

## Fluxos, telas, endpoints ou módulos envolvidos

- `/actuator/health`
- `/actuator/health/liveness`
- `/actuator/health/readiness`
- `/actuator/info`
- `/actuator/metrics`
- Módulos backend de `api/observability`, `application/observability` e `infrastructure/observability`.

## Estratégia de testes

- Unitários: correlation id, sanitização de logs, registro de evento operacional e contrato de use case.
- Contexto Spring: propriedades mínimas de Actuator e métricas carregadas.
- Integração: suite backend completa e migrations.
- Mobile: gates existentes executados para garantir ausência de regressão fora do escopo.

## Evidências de validação

- `make backend-unit-test`: PASS, 172 testes e cobertura mínima atendida.
- `make backend-static-analysis`: PASS.
- `make backend-integration-test`: PASS, Flyway até `v009`.
- `make mobile-static-analysis`: PASS.
- `make mobile-unit-test`: PASS, cobertura 99,51%.
- `make mobile-screen-test`: PASS, 22 testes.
- `make mobile-integration-test`: N/A por ausência de Android Emulator, iOS Simulator ou Chrome.
- `make functional-test`: N/A por ausência de cenários reais.
- `make backend-image-build`: PASS.
- `git diff --check`: PASS.
- Varredura de segredos: PASS com apenas o placeholder esperado em `compose.yml`.

## Riscos ou limitações remanescentes

- Os fluxos WL-009 em diante ainda precisam registrar seus eventos críticos concretos usando a porta criada.
- Coleta externa, dashboards e alertas reais ficam para uma demanda operacional futura.

## Arquivos ou módulos relevantes

- `worklink-api/src/main/java/br/com/worklink/api/observability`
- `worklink-api/src/main/java/br/com/worklink/application/observability`
- `worklink-api/src/main/java/br/com/worklink/infrastructure/observability`
- `worklink-api/src/main/resources/application.yml`
- `docs/arquitetura/observabilidade-logs-metricas.md`

## Justificativa do versionamento

`MINOR`, porque a entrega adiciona uma capacidade técnica nova de observabilidade e rastreabilidade operacional, sem
quebrar contratos funcionais existentes.
