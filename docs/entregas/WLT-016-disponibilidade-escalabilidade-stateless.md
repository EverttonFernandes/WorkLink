# Entrega WLT-016 — Disponibilidade e escalabilidade stateless

## Identificador

- História: `WLT-016`
- Data: `2026-05-09`
- Tipo semântico sugerido: `MINOR`

## Objetivo técnico

Preparar a API para execução stateless e múltiplas instâncias futuras, com readiness real, graceful shutdown e limites
operacionais explícitos para chamadas externas.

## Requisitos atendidos

- Sessão não depende de memória local.
- Arquivos não são persistidos no container da API.
- API fica preparada para múltiplas instâncias.
- Integrações externas possuem contrato de timeout.
- Retry externo é finito e configurável.
- Cache não é fonte da verdade.
- Bloqueios, denúncias graves, autorização e privacidade exigem TTL curto ou invalidação explícita quando cache existir.

## O que foi implementado

- `server.shutdown=graceful`.
- Timeout controlado por fase de shutdown.
- Timeout de requisição assíncrona e conexão Tomcat.
- Timeouts Hikari para conexão e validação do banco.
- Readiness health group incluindo `readinessState` e `db`.
- Liveness health group separado.
- Healthcheck do Dockerfile e Compose apontando para `/actuator/health/readiness`.
- `stop_grace_period` no serviço da API.
- Contrato de configuração para timeouts e retry finito de integrações externas futuras.
- Testes de contexto validando graceful shutdown, probes, sessão não persistente, timeouts e retry finito.
- Documento de arquitetura `docs/arquitetura/disponibilidade-escalabilidade-stateless.md`.

## O que não foi implementado

- Kubernetes.
- Load balancer real.
- Alta disponibilidade multi-região.
- Cache funcional distribuído.
- Filas, workers ou service mesh.

## Estratégia de testes

- Teste de contexto Spring para configurações stateless e operacionais.
- Teste de contexto Spring para contrato de timeouts e retry finito.
- Integração Flyway e cobertura backend completa.
- Build da imagem Docker.
- Execução real da stack Docker com validação de readiness.

## Evidências de validação

- `make backend-static-analysis`: PASS.
- `make backend-unit-test`: PASS, 228 testes e cobertura mínima atendida.
- `make backend-integration-test`: PASS, Flyway até `v014`.
- `make backend-image-build`: PASS.
- `make functional-test`: N/A por ausência de cenários reais.
- `docker compose up -d worklink-api`: PASS.
- `GET /actuator/health/readiness`: PASS, `{"status":"UP"}`.

## Riscos ou limitações remanescentes

- Readiness real depende apenas do banco na V1; Redis e storage ainda não são dependências críticas de runtime da API.
- Cache funcional deve ser introduzido apenas quando houver gargalo real ou necessidade clara de produto.
- Adapters HTTP externos futuros ainda precisam consumir o contrato de timeout/retry quando forem criados.

## Arquivos ou módulos relevantes

- `worklink-api/src/main/resources/application.yml`
- `worklink-api/src/test/java/br/com/worklink/WorkLinkApplicationTest.java`
- `docker/worklink-api.Dockerfile`
- `compose.yml`
- `.env.example`
- `docs/arquitetura/disponibilidade-escalabilidade-stateless.md`

## Justificativa do versionamento

`MINOR`, porque a entrega adiciona uma capacidade operacional relevante e versionável sem quebrar contratos existentes.
