# Plano De Entregas Oficial Unificado — WorkLink V1

Este plano acompanha [KANBAN-OFICIAL.md](KANBAN-OFICIAL.md). Ele define a ordem versionável real, misturando histórias técnicas e funcionais.

| Ordem | História | Documento de entrega esperado | Tipo padrão |
|-------|----------|-------------------------------|-------------|
| 01 | WLT-001 | `docs/entregas/<data>-001-monorepo-stack-base.md` | MINOR |
| 02 | WLT-002 | `docs/entregas/<data>-002-arquitetura-modular-hexagonal.md` | MINOR |
| 03 | WLT-003 | `docs/entregas/<data>-003-banco-postgresql-consistencia.md` | MINOR |
| 04 | WLT-004 | `docs/entregas/<data>-004-ambiente-local-docker-makefile.md` | MINOR |
| 05 | WLT-005 | `docs/entregas/<data>-005-configuracao-segura-env-secrets.md` | MINOR |
| 06 | WLT-006 | `docs/entregas/<data>-006-qualidade-estatica-backend-mobile.md` | MINOR |
| 07 | WLT-007 | `docs/entregas/<data>-007-testabilidade-backend.md` | MINOR |
| 08 | WLT-008 | `docs/entregas/<data>-008-testabilidade-mobile.md` | MINOR |
| 09 | WLT-017 | `docs/entregas/<data>-009-cicd-builds-scans.md` | MINOR |
| 10 | WL-001 | `docs/entregas/<data>-010-fundacao-categorias-cidades-profissionais.md` | MINOR |
| 11 | WL-002 | `docs/entregas/<data>-011-selecao-cidades-localizacao.md` | MINOR |
| 12 | WL-003 | `docs/entregas/<data>-012-descoberta-busca-filtros.md` | MINOR |
| 13 | WL-004 | `docs/entregas/<data>-013-listagem-profissionais.md` | MINOR |
| 14 | WL-005 | `docs/entregas/<data>-014-perfil-publico-profissional.md` | MINOR |
| 15 | WLT-014 | `docs/entregas/<data>-015-storage-seguro-arquivos.md` | MINOR |
| 16 | WL-006 | `docs/entregas/<data>-016-cadastro-progressivo-profissional.md` | MINOR |
| 17 | WL-007 | `docs/entregas/<data>-017-badges-confianca-completude.md` | MINOR |
| 18 | WL-008 | `docs/entregas/<data>-018-disponibilidade-profissional.md` | MINOR |
| 19 | WLT-013 | `docs/entregas/<data>-019-criptografia-protecao-dados.md` | MINOR |
| 20 | WLT-009 | `docs/entregas/<data>-020-autenticacao-sessoes-tokens.md` | MINOR |
| 21 | WLT-010 | `docs/entregas/<data>-021-autorizacao-perfis-ownership.md` | MINOR |
| 22 | WLT-011 | `docs/entregas/<data>-022-rastreabilidade-auditoria-acoes-sensiveis.md` | MINOR |
| 23 | WLT-012 | `docs/entregas/<data>-023-lgpd-privacidade-dados-sensiveis.md` | MINOR |
| 24 | WLT-015 | `docs/entregas/<data>-024-observabilidade-logs-metricas.md` | MINOR |
| 25 | WL-009 | `docs/entregas/<data>-025-autenticacao-cliente-telefone.md` | MINOR |
| 26 | WL-010 | `docs/entregas/<data>-026-contato-whatsapp-intencao.md` | MINOR |
| 27 | WL-011 | `docs/entregas/<data>-027-pos-contato-estruturado.md` | MINOR |
| 28 | WL-012 | `docs/entregas/<data>-028-avaliacao-anonima-rastreavel.md` | MINOR |
| 29 | WL-013 | `docs/entregas/<data>-029-exibicao-avaliacoes-perfil.md` | MINOR |
| 30 | WL-014 | `docs/entregas/<data>-030-denuncia-profissional.md` | MINOR |
| 31 | WL-015 | `docs/entregas/<data>-031-perfil-usuario.md` | MINOR |
| 32 | WLT-016 | `docs/entregas/<data>-032-disponibilidade-escalabilidade-stateless.md` | MINOR |
| 33 | WL-016 | `docs/entregas/<data>-033-admin-minimo-moderacao.md` | MINOR |
| 34 | WL-017 | `docs/entregas/<data>-034-metricas-ranking-futuro.md` | MINOR |
| 35 | WLT-018 | `docs/entregas/<data>-035-documentacao-adrs-release-mobile.md` | MINOR |

O tipo semântico final deve ser confirmado no fechamento real da história. Use `PATCH` para correções sem nova capacidade e `MAJOR` apenas quando houver quebra incompatível de contrato.

Observação de qualidade: WLT-007, WLT-008 e WLT-017 devem garantir cobertura unitária mínima de 95%. A pipeline de GitHub Actions deve bloquear merge ou fechamento quando esse limite não for atendido.
