# Estratégia de release mobile

Decisao operacional base:

- `docs/adrs/ADR-0005-estrategia-infra-mobile-homologacao-release.md`
- `docs/operacao/guia-infra-mobile-homologacao-release.md`

Toda mudanca que envolva Android, iOS, emuladores, assinatura, TestFlight, Play Console ou custo de CI/CD mobile deve
ser revisada pelo `sre-agent` com apoio do `mobile-infra-specialist-agent`.

O procedimento oficial de promocao, bloqueio de rollout e rollback esta em
`docs/operacao/mobile-release-promocao-rollback.md`.

## Android

1. Gerar build validado pelos gates mobile.
2. Baixar o artifact `worklink-android-test-candidate-<commit>` de um run verde do GitHub Actions.
3. Instalar manualmente `worklink-android-test-candidate.apk` em aparelho Android de teste.
4. Validar smoke test: abertura do app, seleção de cidade, descoberta, perfil, contato e fluxos autenticados.
5. Publicar primeiro em Internal Testing no Google Play quando a assinatura de loja estiver configurada.
6. Promover gradualmente para closed/open testing antes de produção.

### Estrategia progressiva Android

- Validacao economica: artifact APK do GitHub Actions e teste manual.
- Homologacao controlada: APK release assinado, backend HTTPS allowlisted e GitHub Release.
- Loja: AAB, Play App Signing e Play Console Internal/Closed/Open testing.

### Artifact Android de teste interno

O artifact de teste manual contem:

- `worklink-android-test-candidate.apk`
- `BUILD-METADATA.txt`
- `SHA256SUMS`
- `INSTALL-ANDROID.md`

Esse pacote usa assinatura debug e serve apenas para validacao interna antes de configurar signing de producao.

## iOS

1. Gerar build validado pelos gates mobile.
2. Publicar via TestFlight.
3. Validar smoke test equivalente ao Android.
4. Submeter para App Review apenas após estabilidade mínima.

### Estrategia progressiva iOS

- Antes de loja: documentar requisitos e evitar macOS runner continuo sem necessidade real.
- Homologacao iOS: Apple Developer Program, signing/provisioning e TestFlight interno.
- Loja: App Store Connect, App Review e plano de hotfix.

### Preparacao CI/TestFlight

- Guia operacional: `docs/operacao/ios-ci-testflight.md`.
- Check local: `make ios-readiness-check`.
- Workflow manual: `.github/workflows/ios-build.yml`.
- Modo atual seguro: `no-codesign`.
- Upload TestFlight real depende de Apple Developer Account, certificados, provisioning profile e App Store Connect API key.

## Rollout gradual

- Começar com público interno.
- Expandir por percentual ou grupo controlado.
- Monitorar falhas, feedbacks e métricas de contato.

## Rollback

- Android permite interromper rollout e promover versão anterior quando disponível.
- iOS não garante rollback instantâneo após App Review; mitigação principal é pausar distribuição, acelerar hotfix e
  manter TestFlight validado.
- Checklist detalhado: `docs/operacao/mobile-release-promocao-rollback.md`.

## Checklist pré-release

- Gates de backend e mobile aprovados.
- Versionamento semântico e tag criados.
- Commit, tag, artifact, run id e checksum rastreados.
- `.env.example` atualizado.
- Política de privacidade e permissões revisadas.
- Plano de incidente conhecido.
