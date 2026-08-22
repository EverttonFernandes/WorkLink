# Entrega WLT-039 - Android AAB e Play Store Internal Testing

## Resultado entregue

- Build Android em formato `AAB` preparado via `flutter build appbundle --release`.
- Assinatura Android de loja separada da assinatura de homologacao.
- Target `make mobile-android-appbundle-build` criado para compilar o bundle com backend HTTPS controlado.
- Target `make mobile-android-play-store-candidate` criado para gerar pacote rastreavel de Play Internal Testing.
- Artifact padrao `worklink-android-play-internal-<commit>` documentado e publicado pela CI quando a URL/store secrets
  existem.
- Governanca de assinatura atualizada para incluir upload key da Play App Signing.
- Runbook operacional criado em `docs/operacao/android-play-internal-testing.md`.

## Arquivos principais

- `.github/workflows/ci.yml`
- `Makefile`
- `worklink-mobile/android/app/build.gradle`
- `scripts/prepare_android_store_signing.sh`
- `scripts/prepare_android_store_bundle_candidate.sh`
- `scripts/check_mobile_signing_governance.sh`
- `docs/operacao/mobile-secrets-assinatura.md`
- `docs/operacao/android-play-internal-testing.md`

## Validacoes esperadas

- `make mobile-signing-governance`
- `make mobile-android-play-store-candidate MOBILE_PLAY_STORE_API_BASE_URL=https://...`
- `git diff --check`

## Validacoes executadas no fechamento

- `git diff --check`
- `sh -n scripts/prepare_android_store_signing.sh scripts/prepare_android_store_bundle_candidate.sh scripts/check_mobile_signing_governance.sh`
- `make mobile-signing-governance`
- `make -n mobile-android-appbundle-build MOBILE_PLAY_STORE_API_BASE_URL=https://api.profissionalperto.app`
- `make -n mobile-android-play-store-candidate MOBILE_PLAY_STORE_API_BASE_URL=https://api.profissionalperto.app`
- GitHub Actions `WorkLink CI` run `29962987675`: `success`

## Versionamento

- Tipo: `MINOR`
- Tag de fechamento: `v0.56.0`

## Bloqueios remanescentes

Os itens abaixo deixaram de bloquear tecnicamente a WLT-039 e passam a ser acompanhados pela WLT-042:

- URL HTTPS real e persistente do backend de loja.
- Secrets reais da upload key da Play App Signing.
- Acao manual no Google Play Console para upload e liberacao da trilha interna.
- Smoke test manual do dono do produto apos instalacao pela Play Store.
