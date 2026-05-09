# WLT-016 — Disponibilidade e escalabilidade stateless

## História

Como time técnico, quero preparar a API para execução stateless e múltiplas instâncias futuras, garantindo prontidão
operacional sem introduzir infraestrutura desnecessária na V1.

## Fonte oficial

- `docs/jira-pessoal/historias-tecnicas/WLT-016-disponibilidade-escalabilidade-stateless.md`
- `docs/requisitos/epico-requisitos-nao-funcionais.md`
- `docs/arquitetura/observabilidade-logs-metricas.md`

## Critérios de aceite

- [x] Sessão não deve depender de memória local.
- [x] Arquivos não devem ser persistidos no container da API.
- [x] API deve estar pronta para múltiplas instâncias.
- [x] Integrações externas devem ter timeout.
- [x] Retry deve ser controlado, não infinito.
- [x] Cache não deve ser fonte da verdade.
- [x] Bloqueio de profissional e denúncia grave devem invalidar cache aplicável rapidamente.

## Escopo técnico

- Validar e reforçar configuração stateless da API.
- Configurar graceful shutdown e timeouts operacionais.
- Expor readiness baseada em dependências necessárias.
- Definir contrato de timeouts e retry controlado para integrações externas futuras.
- Documentar limites de cache-aside e invalidação rápida para dados sensíveis/moderação.

## Fora do escopo

- Kubernetes obrigatório.
- Load balancer real.
- Alta disponibilidade multi-região.
- Implementação de cache funcional onde ainda não há necessidade de produto.

## Evidências

- `make backend-static-analysis`: PASS.
- `make backend-unit-test`: PASS, 228 testes e cobertura mínima atendida.
- `make backend-integration-test`: PASS, Flyway até `v014`.
- `make backend-image-build`: PASS.
- `make functional-test`: N/A por ausência de cenários reais.
- `docker compose up -d worklink-api`: PASS.
- `GET /actuator/health/readiness`: PASS, `{"status":"UP"}`.
