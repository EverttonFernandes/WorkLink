# Plano De Entregas Técnicas Versionadas — WorkLink V1

> Visão filtrada das entregas técnicas.
>
> O plano oficial versionável, com histórias técnicas e funcionais intercaladas, é [PLANO-DE-ENTREGAS-OFICIAL.md](PLANO-DE-ENTREGAS-OFICIAL.md).

| História | Documento de entrega esperado | Tipo semântico padrão | Motivo |
|----------|-------------------------------|-----------------------|--------|
| WLT-001 | `docs/entregas/<data>-t001-monorepo-stack-base.md` | MINOR | adiciona estrutura técnica inicial |
| WLT-002 | `docs/entregas/<data>-t002-arquitetura-modular-hexagonal.md` | MINOR | adiciona fundação arquitetural |
| WLT-003 | `docs/entregas/<data>-t003-banco-postgresql-consistencia.md` | MINOR | adiciona persistência transacional |
| WLT-004 | `docs/entregas/<data>-t004-ambiente-local-docker-makefile.md` | MINOR | adiciona ambiente reproduzível |
| WLT-005 | `docs/entregas/<data>-t005-configuracao-segura-env-secrets.md` | MINOR | adiciona configuração segura |
| WLT-006 | `docs/entregas/<data>-t006-qualidade-estatica-backend-mobile.md` | MINOR | adiciona gates de qualidade |
| WLT-007 | `docs/entregas/<data>-t007-testabilidade-backend.md` | MINOR | adiciona base de testes backend e coverage gate de 95% |
| WLT-008 | `docs/entregas/<data>-t008-testabilidade-mobile.md` | MINOR | adiciona base de testes mobile e coverage gate de 95% |
| WLT-009 | `docs/entregas/<data>-t009-autenticacao-sessoes-tokens.md` | MINOR | adiciona segurança de autenticação |
| WLT-010 | `docs/entregas/<data>-t010-autorizacao-perfis-ownership.md` | MINOR | adiciona controle de acesso |
| WLT-011 | `docs/entregas/<data>-t011-rastreabilidade-auditoria-acoes-sensiveis.md` | MINOR | adiciona auditoria e autoria |
| WLT-012 | `docs/entregas/<data>-t012-lgpd-privacidade-dados-sensiveis.md` | MINOR | adiciona proteção de privacidade |
| WLT-013 | `docs/entregas/<data>-t013-criptografia-protecao-dados.md` | MINOR | adiciona proteção criptográfica |
| WLT-014 | `docs/entregas/<data>-t014-storage-seguro-arquivos.md` | MINOR | adiciona storage seguro |
| WLT-015 | `docs/entregas/<data>-t015-observabilidade-logs-metricas.md` | MINOR | adiciona observabilidade |
| WLT-016 | `docs/entregas/<data>-t016-disponibilidade-escalabilidade-stateless.md` | MINOR | adiciona prontidão operacional |
| WLT-017 | `docs/entregas/<data>-t017-cicd-builds-scans.md` | MINOR | adiciona pipeline automatizada com bloqueio de cobertura unitária abaixo de 95% |
| WLT-018 | `docs/entregas/<data>-t018-documentacao-adrs-release-mobile.md` | MINOR | adiciona documentação e release readiness |
| WLT-019 | `docs/entregas/<data>-t019-specs-funcionais-e2e-reais.md` | MINOR | adiciona specs funcionais E2E reais |
| WLT-020 | `docs/entregas/<data>-t020-projeto-nativo-mobile-android-ios.md` | MINOR | adiciona projetos nativos mobile Android/iOS |
| WLT-021 | `docs/entregas/<data>-t021-analise-estatica-avancada-backend.md` | MINOR | adiciona análise estática avançada backend |
| WLT-022 | `docs/entregas/<data>-t022-integracao-http-mobile-backend.md` | MINOR | adiciona integração HTTP mobile com backend real |
| WLT-023 | `docs/entregas/<data>-t023-emulador-remoto-ambiente-teste-online.md` | MINOR | adiciona validação mobile com Android Emulator na pipeline |
| WLT-024 | `docs/entregas/<data>-t024-confiabilidade-ci-mobile-android.md` | MINOR | endurece o gate mobile Android na CI |
| WLT-025 | `docs/entregas/<data>-t025-build-android-release-candidato.md` | MINOR | adiciona artifact Android instalável para teste pré-loja |
| WLT-026 | `docs/entregas/<data>-t026-preparacao-ios-ci-testflight.md` | MINOR | prepara CI iOS e distribuição futura via TestFlight |
| WLT-027 | `docs/entregas/<data>-t027-governanca-secrets-assinatura-mobile.md` | MINOR | adiciona governança de secrets e assinatura mobile |
| WLT-028 | `docs/entregas/<data>-t028-promocao-release-rollback-mobile.md` | MINOR | formaliza promoção e rollback de releases mobile |

O tipo semântico final deve refletir o que foi realmente entregue. Correções em infraestrutura existente podem virar `PATCH`; mudanças incompatíveis em contrato técnico podem exigir `MAJOR`.
