# WLT-018 — Documentação técnica, ADRs e release mobile

## História técnica

Como mantenedor do WorkLink, quero documentação técnica mínima, ADRs, guias operacionais e estratégia de release mobile
para facilitar manutenção, onboarding, auditoria e publicação controlada.

## Fonte oficial

- `docs/jira-pessoal/historias-tecnicas/WLT-018-documentacao-adrs-release-mobile.md`
- `docs/requisitos/epico-requisitos-nao-funcionais.md`

## Critérios de aceite

- [x] Documentos obrigatórios devem existir ou ter plano explícito.
- [x] ADRs iniciais devem registrar decisões principais.
- [x] API deve ter documentação OpenAPI/Swagger quando endpoints existirem.
- [x] Threat model e checklist OWASP devem existir para fluxos sensíveis.
- [x] Estratégia de release mobile deve considerar Android e iOS.
- [x] Limitações de rollback iOS devem estar documentadas.

## Escopo técnico

- Completar README principal, API e mobile.
- Criar guias de ambiente, testes e variáveis.
- Criar ADRs iniciais.
- Criar C4 Model.
- Criar OpenAPI estático da V1.
- Criar threat model, checklist OWASP, política de segurança e guia de incidentes.
- Criar estratégia de release mobile.

## Fora do escopo

- Publicação real nas lojas.
- Automação completa de release mobile.
- Rollback instantâneo iOS.

## Evidências

- `README.md`, `worklink-api/README.md`, `worklink-mobile/README.md` e `docs/README.md` atualizados.
- `docs/api/openapi.yaml` criado.
- `docs/adrs/ADR-0001-arquitetura-modular-hexagonal.md` criado.
- `docs/adrs/ADR-0002-ambiente-docker-e-makefile.md` criado.
- `docs/adrs/ADR-0003-cobertura-unitaria-minima.md` criado.
- `docs/adrs/ADR-0004-ranking-futuro-sem-algoritmo-v1.md` criado.
- `docs/arquitetura/c4-model.md` criado.
- `docs/seguranca/threat-model.md` criado.
- `docs/seguranca/checklist-owasp.md` criado.
- `docs/seguranca/politica-seguranca.md` criado.
- `docs/operacao/guia-ambiente-local.md`, `guia-testes.md`, `guia-variaveis-ambiente.md` e
  `guia-incidentes.md` criados.
- `docs/release/release-mobile.md` criado com Android, iOS, rollout e rollback.
- `git diff --check`: PASS.
