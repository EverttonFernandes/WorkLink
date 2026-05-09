# WorkLink Mobile

Aplicativo mobile do WorkLink.

## Stack

- Flutter
- Dart

## Comandos esperados

```bash
make mobile-static-analysis
make mobile-unit-test
make mobile-screen-test
make mobile-integration-test
make mobile-test
```

## Observacao

As validacoes mobile devem rodar em Docker pelo `compose.yml`, sem exigir Flutter SDK instalado diretamente na maquina.
`make mobile-unit-test` valida cobertura minima de 95%. `make mobile-integration-test` roda quando houver Android Emulator,
iOS Simulator ou Chrome disponivel no ambiente de execucao.

## Release

A estrategia de publicacao esta documentada em `../docs/release/release-mobile.md`.

- Android: Internal Testing antes de qualquer rollout amplo.
- iOS: TestFlight antes de App Review.
- Rollback iOS nao e instantaneo; a mitigacao primaria e pausar distribuicao e acelerar hotfix validado.
