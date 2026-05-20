# Estratégia de release mobile

## Android

1. Gerar build validado pelos gates mobile.
2. Baixar o artifact `worklink-android-test-candidate-<commit>` de um run verde do GitHub Actions.
3. Instalar manualmente `worklink-android-test-candidate.apk` em aparelho Android de teste.
4. Validar smoke test: abertura do app, seleção de cidade, descoberta, perfil, contato e fluxos autenticados.
5. Publicar primeiro em Internal Testing no Google Play quando a assinatura de loja estiver configurada.
6. Promover gradualmente para closed/open testing antes de produção.

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

## Rollout gradual

- Começar com público interno.
- Expandir por percentual ou grupo controlado.
- Monitorar falhas, feedbacks e métricas de contato.

## Rollback

- Android permite interromper rollout e promover versão anterior quando disponível.
- iOS não garante rollback instantâneo após App Review; mitigação principal é pausar distribuição, acelerar hotfix e
  manter TestFlight validado.

## Checklist pré-release

- Gates de backend e mobile aprovados.
- Versionamento semântico e tag criados.
- `.env.example` atualizado.
- Política de privacidade e permissões revisadas.
- Plano de incidente conhecido.
