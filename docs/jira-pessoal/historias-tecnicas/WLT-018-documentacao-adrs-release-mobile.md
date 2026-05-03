# WLT-018 — Documentação técnica, ADRs e release mobile

## Objetivo

Criar documentação técnica mínima, ADRs iniciais e estratégia de publicação/rollback mobile.

## Valor técnico

Facilita manutenção, onboarding, auditoria técnica e preparação para publicação controlada.

## RNFs relacionados

- RNF01, RNF14, RNF15

## Escopo incluído

- README principal.
- README da API.
- README do mobile.
- Guia de ambiente local.
- Guia de testes.
- Guia de variáveis de ambiente.
- OpenAPI/Swagger.
- ADRs iniciais recomendados.
- C4 Model.
- Threat model.
- Checklist OWASP.
- Política básica de segurança.
- Guia de incidentes.
- Estratégia Android internal testing e iOS TestFlight.
- Rollout gradual e checklist de release.

## Fora do escopo

- Publicação nacional imediata.
- Operação complexa de release.
- Rollback instantâneo iOS.

## Critérios de aceite

- Documentos obrigatórios devem existir ou ter plano explícito.
- ADRs iniciais devem registrar decisões principais.
- API deve ter documentação OpenAPI/Swagger quando endpoints existirem.
- Threat model e checklist OWASP devem existir para fluxos sensíveis.
- Estratégia de release mobile deve considerar Android e iOS.
- Limitações de rollback iOS devem estar documentadas.

## Entrega versionável

- Tipo sugerido: `MINOR`
