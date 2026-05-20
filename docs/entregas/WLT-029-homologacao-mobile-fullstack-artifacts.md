# Entrega WLT-029 — Homologação mobile full-stack e artifacts estáveis

## Identificador

- História: `WLT-029`
- Tipo semântico sugerido: `MINOR`
- Estado: `Em andamento`

## Objetivo técnico

Construir a base para validar manualmente o WorkLink em Android e iOS contra um ambiente real de homologação, com backend, banco e massa fake controlada.

## Implementação inicial

- Criado build Android de homologação com `API_BASE_URL` configurável via `MOBILE_HOMOLOGATION_API_BASE_URL`.
- O `ApiClient` mobile passa a respeitar `--dart-define=API_BASE_URL=...` em builds instaláveis.
- Criado `make homologation-local-up` para subir dependências, aplicar migrations, iniciar API e popular massa local.
- Criado seed funcional `functional-tests/src/scripts/seedHomologationScenario.js` com cidades, categorias e profissionais fictícios da região carbonífera.
- Atualizada a pipeline para publicar `worklink-android-homologation-<commit>` quando a variável `WORKLINK_HOMOLOGATION_API_BASE_URL` existir no GitHub Actions.
- Criado contrato inicial da pasta `artifacts/homologation`.

## Estado atual da homologação

- Android preview/offline: disponível pela WLT-025.
- Android full-stack: preparado tecnicamente, dependente de URL estável de backend de homologação.
- iOS full-stack: pendente da WLT-026 para preparação CI/TestFlight e deve apontar para o mesmo backend de homologação.

## Evidências esperadas para fechamento

- CI verde com artifact `worklink-android-homologation-<commit>` publicado.
- APK Android instalado em aparelho físico e validado contra backend de homologação.
- Massa fake carregada e visível no app.
- Registro de checksum e metadados em `artifacts/homologation/releases/<versao>/`.
- Plano equivalente iOS validado antes de submissão para Apple Store.
