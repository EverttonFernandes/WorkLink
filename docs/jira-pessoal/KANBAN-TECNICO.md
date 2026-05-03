# Kanban Técnico — WorkLink V1

> Visão filtrada apenas das histórias técnicas.
>
> A fila oficial de execução cronológica dos agentes é [KANBAN-OFICIAL.md](KANBAN-OFICIAL.md), que intercala histórias funcionais e técnicas.

Fonte principal: `docs/requisitos/epico-requisitos-nao-funcionais.md`

Regra de execução desta visão: use este arquivo para consultar somente o recorte técnico. Não use este arquivo para decidir a próxima história oficial quando houver histórias funcionais intercaladas no [KANBAN-OFICIAL.md](KANBAN-OFICIAL.md).

## To Do

| Ordem | História | Título | Valor técnico entregue | RNFs | Versão sugerida |
|-------|----------|--------|------------------------|------|-----------------|
| 01 | [WLT-001](historias-tecnicas/WLT-001-monorepo-stack-base.md) | Monorepo e stack base | Estrutura inicial para backend, mobile, docs e testes | RNF01, RNF02, RNF15 | MINOR |
| 02 | [WLT-002](historias-tecnicas/WLT-002-arquitetura-modular-hexagonal.md) | Arquitetura modular hexagonal | Separação por domínio, camadas, portas e adaptadores | RNF02, RNF15 | MINOR |
| 03 | [WLT-003](historias-tecnicas/WLT-003-banco-postgresql-consistencia.md) | PostgreSQL e consistência transacional | Fonte da verdade e regras de consistência | RNF02, RNF15 | MINOR |
| 04 | [WLT-004](historias-tecnicas/WLT-004-ambiente-local-docker-makefile.md) | Ambiente local reproduzível | Docker Compose, Makefile e dependências locais | RNF07, RNF10, RNF11 | MINOR |
| 05 | [WLT-005](historias-tecnicas/WLT-005-configuracao-segura-env-secrets.md) | Configuração segura e secrets | `.env.example`, env vars e proibição de secrets | RNF08, RNF03 | MINOR |
| 06 | [WLT-006](historias-tecnicas/WLT-006-qualidade-estatica-backend-mobile.md) | Qualidade estática e clean code | Lint, análise estática e padrões de código | RNF13 | MINOR |
| 07 | [WLT-007](historias-tecnicas/WLT-007-testabilidade-backend.md) | Testabilidade backend | Unitários, integração, funcionais de API e cobertura mínima de 95% | RNF06, RNF13 | MINOR |
| 08 | [WLT-008](historias-tecnicas/WLT-008-testabilidade-mobile.md) | Testabilidade mobile | Testes unitários, widget, integração Flutter e cobertura mínima de 95% | RNF01, RNF06, RNF13 | MINOR |
| 09 | [WLT-009](historias-tecnicas/WLT-009-autenticacao-sessoes-tokens.md) | Autenticação segura, sessões e tokens | OTP, tokens, refresh, revogação e proteção contra enumeração | RNF03, RNF16 | MINOR |
| 10 | [WLT-010](historias-tecnicas/WLT-010-autorizacao-perfis-ownership.md) | Autorização por perfil e ownership | Controle de acesso para cliente, profissional e administrador | RNF03, RNF17 | MINOR |
| 11 | [WLT-011](historias-tecnicas/WLT-011-rastreabilidade-auditoria-acoes-sensiveis.md) | Autenticidade, rastreabilidade e auditoria | Autoria rastreável para ações sensíveis | RNF18, RNF03, RNF04 | MINOR |
| 12 | [WLT-012](historias-tecnicas/WLT-012-lgpd-privacidade-dados-sensiveis.md) | LGPD, privacidade e minimização | Proteção de dados pessoais e anonimização pública | RNF04, RNF05 | MINOR |
| 13 | [WLT-013](historias-tecnicas/WLT-013-criptografia-protecao-dados.md) | Criptografia e proteção de dados | TLS, repouso, campo e hashing de dados sensíveis | RNF05, RNF03 | MINOR |
| 14 | [WLT-014](historias-tecnicas/WLT-014-storage-seguro-arquivos.md) | Storage seguro de arquivos | S3/MinIO, metadados, URLs assinadas e controle de upload | RNF12, RNF03, RNF04 | MINOR |
| 15 | [WLT-015](historias-tecnicas/WLT-015-observabilidade-logs-metricas.md) | Observabilidade, logs e métricas | Health checks, logs estruturados, correlation id e eventos críticos | RNF09, RNF11 | MINOR |
| 16 | [WLT-016](historias-tecnicas/WLT-016-disponibilidade-escalabilidade-stateless.md) | Disponibilidade e escalabilidade stateless | API stateless, readiness, graceful shutdown, timeouts e cache seguro | RNF10, RNF11, RNF15 | MINOR |
| 17 | [WLT-017](historias-tecnicas/WLT-017-cicd-builds-scans.md) | CI/CD, builds e scans | Pipelines backend/mobile, testes, coverage gate de 95%, scans e artefatos | RNF14, RNF06, RNF13 | MINOR |
| 18 | [WLT-018](historias-tecnicas/WLT-018-documentacao-adrs-release-mobile.md) | Documentação técnica, ADRs e release mobile | README, guias, ADRs, publicação e rollback mobile | RNF01, RNF14, RNF15 | MINOR |

## Doing

_Vazio._

## Review

_Vazio._

## Done

_Vazio._

## Bloqueios conhecidos

- Cloud provider, serviço de OTP/SMS, observabilidade definitiva, build iOS, secrets manager, provedor S3 e feature flags continuam como decisões pendentes sem bloquear a V1.
- Microserviços, Kubernetes obrigatório, Kafka, CQRS completo, Event Sourcing, OpenSearch obrigatório e arquitetura distribuída complexa ficam fora do escopo técnico da V1.
