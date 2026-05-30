# WLT-030 — Parecer SRE + Mobile Infra

## RNFs aplicáveis

- `RNF07 — Ambiente reproduzível`
- `RNF14 — CI/CD`
- aspectos operacionais da homologação mobile

## Resultado

`PASS`

## Gates avaliados

| Gate | Resultado | Observação |
| --- | --- | --- |
| `sre` | `PASS` | evidência web-static reproduzível via script e alinhada ao Flutter atual do projeto |
| `android_ci_readiness` | `PASS` | pipeline ajustada para Flutter `3.44.0`, compatível com o código mobile atual |
| `manual_testing_readiness` | `PASS PARCIAL` | WLT-030 fecha evidência visual; APK full-stack e massa regional seguem nas histórias irmãs |
| `artifact_governance` | `PASS` | goldens e screenshots oficiais foram versionados em `docs/tasks/WLT-030/evidence/` |
| `mobile_cost_risk` | `PASS` | estratégia segue barata: preview web + goldens antes de elevar custo com lojas/runners dedicados |

## Evidências observadas

- `scripts/capture_wlt_030_web_evidence.sh`
- `scripts/capture_wlt_030_visual_evidence.sh`
- `docs/tasks/WLT-030/evidence/web-static/*.png`
- `docs/tasks/WLT-030/evidence/generated/*.png`
- `worklink-mobile/test/widget/visual/goldens/*.png`
- `worklink-mobile/test/widget/visual/wlt_030_visual_evidence_web_app.dart`
- `.github/workflows/ci.yml`
- `compose.yml`

## Correções de pipeline aplicadas

1. A versão do Flutter usada no GitHub Actions e nos serviços Docker mobile foi alinhada para `3.44.0`.
2. A imagem `ghcr.io/cirruslabs/flutter:3.44.0` foi verificada no registry com HTTP `200`.
3. O bootstrap do job `Mobile integration on Android emulator` ganhou retry para `docker compose pull` e `docker compose up` das dependências `postgres`, `redis` e `minio`.
4. O build Android foi atualizado para a cadeia exigida pelo Flutter `3.44.0` e pelo AGP atual: Gradle `9.1.0`, Android Gradle Plugin `9.0.1`, Kotlin Gradle Plugin `2.3.20` e bytecode Java/Kotlin `17`.

Essas mudanças atacam as falhas reais observadas no run `26580031333`:

- `Mobile quality gates`: APIs Flutter atuais falhavam porque a CI ainda usava Flutter `3.24.5`.
- `Mobile integration on Android emulator`: o backend não subiu por falha transitória no pull de `redis:7-alpine`.
- Run `26688503774`: o build do APK falhava porque o projeto Android ainda usava Gradle `8.3.0`, abaixo do mínimo aceito pelo Flutter `3.44.0`.
- Run `26689783432`: o AGP `9.0.1` rejeitou Gradle `9.0.0` e exigiu Gradle `9.1.0`.

## Continuidade

`READY_FOR_FINAL_REVIEW`

A WLT-030 pode ser encerrada como história de aderência visual. As pendências de produto e homologação completa seguem
rastreadas em `WLT-032`, `WLT-033`, `WLT-034` e `WLT-035`.
