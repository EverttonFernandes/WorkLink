# WLT-030 — Parecer SRE + Mobile Infra

## RNFs aplicáveis

- `RNF07 — Ambiente reproduzível`
- `RNF14 — CI/CD`
- aspectos operacionais da homologação mobile

## Resultado

`PENDING`

## Gates avaliados

| Gate | Resultado | Observação |
| --- | --- | --- |
| `sre` | `PENDING` | preview web preparado, mas sem validação ponta a ponta nesta janela |
| `android_ci_readiness` | `PASS PARCIAL` | suíte local e evidência automatizada existem, mas não substituem APK/emulador oficial |
| `manual_testing_readiness` | `PENDING` | falta captura oficial com renderização fiel |
| `artifact_governance` | `PASS PARCIAL` | artefatos/versionamento visual adicionados no repositório, mas ainda não fecham homologação operacional |
| `mobile_cost_risk` | `PASS` | estratégia atual continua barata e adequada para validação inicial |

## Evidências observadas

- `scripts/run_mobile_web_preview.sh`
- `scripts/capture_wlt_030_visual_evidence.sh`
- `compose.yml`
- `Makefile`
- `docs/tasks/WLT-030/evidence/`
- `worklink-mobile/test/widget/visual/goldens/`

## Falhas operacionais

### 1. Docker Desktop indisponível no host atual

Comando observado:

```text
docker.exe version
```

Resultado:

```text
failed to connect to the docker API at npipe:////./pipe/dockerDesktopLinuxEngine
```

Isso bloqueia a revalidação do preview web dockerizado, que era a principal trilha operacional para capturar evidência
visual oficial sem depender do Windows hospedeiro.

### 2. Evidência visual oficial ainda não coletada

Mesmo com os goldens versionados e passando, a homologação operacional de produto continua pendente porque ainda falta
uma trilha visual real em:

- emulador Android;
- APK em aparelho real;
- ou Flutter Web funcional com renderização fiel.

## Recomendação principal

Continuar com a estratégia econômica da Fase 1:

- manter goldens e widget tests como base de regressão;
- restaurar o Docker Desktop apenas para recuperar o preview web;
- usar APK real para a prova final de homologação visual.

## Infra mínima necessária agora

- Docker Desktop operacional no host;
- preview web acessível;
- APK recente instalado em aparelho real;
- backend/massa mínima coerente com a história irmã de homologação regional.

## Infra que deve ser adiada

- macOS runner para iOS;
- TestFlight;
- Play Console internal testing automático;
- runners dedicados mais caros.

## Continuidade

`BLOCKED_FOR_NEXT_STORY`

Motivo: a `WLT-030` ainda não tem evidência oficial suficiente para ser considerada concluída com segurança de produto.
