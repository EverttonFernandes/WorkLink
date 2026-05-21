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
- Atualizada a pipeline para publicar `worklink-android-homologation-<commit>` quando `WORKLINK_HOMOLOGATION_API_BASE_URL` existir como variable, secret ou input manual do GitHub Actions e os secrets de assinatura Android estiverem configurados.
- Criado contrato inicial da pasta `artifacts/homologation`.
- Criado script de promoção `scripts/promote_android_homologation_artifact.sh` para publicar o APK full-stack como asset do GitHub Release e registrar metadados/checksum em `artifacts/homologation/releases/<versao>/android`.
- Criado target local separado `mobile-android-local-fullstack-candidate` para teste rápido em Android físico com backend local, sem promoção.
- A promoção Android exige allowlist de host, release assinado e fingerprint SHA-256 validado por `apksigner`.

## Estado atual da homologação

- Android preview/offline: disponível pela WLT-025.
- Android local full-stack: disponível como APK debug não promovível quando backend local estiver acessível pelo celular.
- Android homologação estável: preparado tecnicamente, dependente de URL HTTPS estável de backend de homologação, allowlist, secrets de assinatura Android e fingerprint SHA-256 esperado.
- iOS full-stack: pendente da WLT-026 para preparação CI/TestFlight e deve apontar para o mesmo backend de homologação.

## Evidências esperadas para fechamento

- CI verde com artifact `worklink-android-homologation-<commit>` publicado.
- APK Android instalado em aparelho físico e validado contra backend de homologação.
- Massa fake carregada e visível no app.
- Registro de checksum e metadados em `artifacts/homologation/releases/<versao>/`.
- APK publicado como asset do GitHub Release da tag semântica.
- Certificado real do APK conferido contra a chave de homologação esperada.
- Plano equivalente iOS validado antes de submissão para Apple Store.

## Evidências já coletadas

- GitHub Actions run `26196995023` executado com sucesso em `main`.
- Jobs verdes:
  - `Mobile quality gates`
  - `Mobile integration on Android emulator`
  - `Backend quality gates`
  - `Dependency scan`
  - `API Docker image`
