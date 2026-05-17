# WLT-020 — Projeto nativo mobile Android/iOS

Como time técnico do WorkLink, queremos gerar os projetos nativos Android e iOS do app Flutter para habilitar builds reais, execução em emulador/simulador e preparação de publicação futura nas lojas.

## Valor técnico

Fecha o gap entre o código Flutter já funcional e a ausência das camadas nativas necessárias para build, testes em emulador e distribuição mobile real.

## Critérios de aceite

- `worklink-mobile/android/` deve existir com configuração mínima válida.
- `worklink-mobile/ios/` deve existir com configuração mínima válida.
- `flutter build apk --debug` deve concluir sem erro.
- `make mobile-android-build` deve executar build real e não retornar `N/A`.
- CI deve executar o build Android no job mobile.
- Estratégia de build iOS deve estar documentada.
