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
make mobile-android-build
make mobile-android-test-candidate
make mobile-emulator-up
make mobile-emulator-wait
make mobile-emulator-install
make mobile-manual-test
make mobile-test
```

## Observacao

As validacoes mobile devem rodar em Docker pelo `compose.yml`, sem exigir Flutter SDK instalado diretamente na maquina.
`make mobile-unit-test` valida cobertura minima de 95%. `make mobile-integration-test` roda quando houver Android Emulator,
iOS Simulator ou Chrome disponivel no ambiente de execucao.

Na CI, a historia `WLT-023` adiciona um job dedicado com Android Emulator para executar `integration_test/` sem depender de setup local.

## Projeto nativo

O modulo Flutter possui `android/` e `ios/` gerados no repositorio.
Build Android real:

```bash
make mobile-android-build
```

Na CI, o job mobile publica o pacote `worklink-android-test-candidate-<commit>`. Esse artifact e o primeiro caminho
para teste manual em aparelho Android antes de qualquer distribuicao em loja.

## Teste manual em Android real

Depois de um run verde do GitHub Actions em `main`, baixe o artifact:

```text
worklink-android-test-candidate-<commit>
```

Dentro dele ficam:

- `worklink-android-test-candidate.apk`
- `BUILD-METADATA.txt`
- `SHA256SUMS`
- `INSTALL-ANDROID.md`

Para testar no aparelho:

1. Baixe e extraia o artifact.
2. Envie `worklink-android-test-candidate.apk` para o Android.
3. Permita instalacao de apps desconhecidos para o app usado para abrir o APK.
4. Instale o APK e abra o WorkLink.
5. Valide abertura, descoberta de profissionais, perfil e fluxos principais.

Esse APK usa assinatura debug e e somente para teste interno. A assinatura de loja entra nas historias de governanca de
secrets e release mobile.

A estrategia de build iOS continua documentada em `../docs/ci-cd/ESTRATEGIA-IOS.md`.

## Emulador Android em Docker

Para teste manual antes das lojas, o projeto agora possui um emulador Android em container com noVNC:

```bash
make mobile-manual-test
```

Esse fluxo:

- sobe backend e dependencias
- gera o APK debug
- sobe o emulador Android em Docker
- instala o APK no emulador
- abre o app automaticamente

Depois disso, abra `http://localhost:6080` no navegador para interagir com o emulador.

Observacoes:

- requer `/dev/kvm` disponivel no host Linux
- requer pelo menos `16 GB` livres no filesystem do projeto para a AVD local em Docker
- o backend fica acessivel ao app no emulador pelo fluxo ja configurado da stack local
- quando o host nao atender esses prerequisitos, o fluxo falha cedo via `make mobile-emulator-prereqs`

## Release

A estrategia de publicacao esta documentada em `../docs/release/release-mobile.md`.

- Android: Internal Testing antes de qualquer rollout amplo.
- iOS: TestFlight antes de App Review.
- Rollback iOS nao e instantaneo; a mitigacao primaria e pausar distribuicao e acelerar hotfix validado.
