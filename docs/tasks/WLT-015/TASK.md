# WLT-015 — Observabilidade, logs e métricas

## História

Como time técnico, quero observabilidade mínima para saúde, erros e fluxos críticos da V1, para diagnosticar falhas sem
introduzir uma stack operacional complexa cedo demais.

## Fonte oficial

- `docs/jira-pessoal/historias-tecnicas/WLT-015-observabilidade-logs-metricas.md`
- `docs/requisitos/epico-requisitos-nao-funcionais.md`
- `docs/spec-driven-development/padroes-de-testes.md`
- `docs/spec-driven-development/codigo-limpo.md`
- `docs/spec-driven-development/padrões-de-projeto-e-design-de-codigo.md`

## Critérios de aceite

- [x] API deve expor health check.
- [x] Logs devem ser estruturados.
- [x] Requisições devem ter correlation id.
- [x] Eventos críticos devem ser registráveis.
- [x] Logs não devem conter dados sensíveis proibidos.
- [x] Falhas relevantes devem ser rastreáveis.

## Escopo técnico

- Configurar health, readiness/liveness e métricas básicas pelo Spring Actuator.
- Adicionar correlation id por requisição HTTP.
- Criar modelo mínimo de evento operacional registrável.
- Sanitizar valores sensíveis antes de escrever logs operacionais.
- Documentar estratégia mínima de observabilidade da V1.

## Fora do escopo

- ELK obrigatório.
- Prometheus/Grafana obrigatórios.
- Tracing distribuído.
- Alertas reais em provedor externo.

## Evidências

- `make backend-unit-test`: PASS, 172 testes e cobertura mínima atendida.
- `make backend-static-analysis`: PASS.
- `make backend-integration-test`: PASS.
- `make mobile-static-analysis`: PASS.
- `make mobile-unit-test`: PASS, cobertura 99,51%.
- `make mobile-screen-test`: PASS.
- `make mobile-integration-test`: N/A por ausência de ambiente de dispositivo/navegador.
- `make functional-test`: N/A por ausência de cenários reais.
- `make backend-image-build`: PASS.
- `git diff --check`: PASS.
- Varredura de segredos: PASS com apenas o placeholder esperado em `compose.yml`.
