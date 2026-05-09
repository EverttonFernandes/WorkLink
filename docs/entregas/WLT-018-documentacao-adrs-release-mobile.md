# WLT-018 — Documentação técnica, ADRs e release mobile

## Resumo

Entrega de fechamento técnico-documental da V1 com README, ADRs, OpenAPI estático, C4 Model, guias operacionais,
documentos de segurança e estratégia de release mobile.

## Valor entregue

- Onboarding técnico mais direto.
- Decisões principais registradas em ADRs.
- Contrato HTTP documentado em OpenAPI.
- Segurança documentada com threat model, checklist OWASP e política básica.
- Operação documentada com ambiente, testes, variáveis e incidentes.
- Release mobile documentado para Android Internal Testing e iOS TestFlight.

## Artefatos

- `README.md`
- `worklink-api/README.md`
- `worklink-mobile/README.md`
- `docs/README.md`
- `docs/api/openapi.yaml`
- `docs/adrs/`
- `docs/arquitetura/c4-model.md`
- `docs/operacao/`
- `docs/seguranca/`
- `docs/release/release-mobile.md`

## Fora do escopo

- Publicação real em lojas.
- Swagger UI runtime dentro da API.
- Automação completa de release mobile.
- Rollback instantâneo iOS.

## Evidências de qualidade

- `git diff --check`: PASS.
- Gates de código: N/A, entrega documental sem alteração de código executável.

## Versionamento

- Versão planejada: `v0.35.0`.
