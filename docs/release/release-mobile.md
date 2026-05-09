# Estratégia de release mobile

## Android

1. Gerar build validado pelos gates mobile.
2. Publicar primeiro em Internal Testing no Google Play.
3. Validar smoke test: abertura do app, seleção de cidade, descoberta, perfil, contato e fluxos autenticados.
4. Promover gradualmente para closed/open testing antes de produção.

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
