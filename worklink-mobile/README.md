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
make mobile-android-local-fullstack-candidate
make mobile-web-preview
make mobile-web-preview-stop
make mobile-web-preview-logs
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

Esse APK usa assinatura debug, carrega dados preview para teste manual sem backend publicado e e somente para teste
interno. Ele nao deve ser tratado como homologacao full-stack.

Massa regional disponivel no preview/APK debug:

- Charqueadas - RS
- Sao Jeronimo - RS
- Triunfo - RS
- Arroio dos Ratos - RS
- Eldorado do Sul - RS
- General Camara - RS
- Butia - RS

Cada cidade possui ao menos um profissional ficticio em categoria de servicos gerais. Isso permite validar descoberta,
listagem, perfil profissional e tambem busca sem resultado usando termos fora da massa, como `marceneiro`.

## Teste manual full-stack de homologacao

Para validar rapidamente no seu Android fisico contra backend local, banco e massa fake do notebook, use o candidato local
full-stack:

```bash
make homologation-local-up
MOBILE_LOCAL_API_BASE_URL=http://<ip-do-notebook>:8080 make mobile-android-local-fullstack-candidate
```

No Android fisico, `localhost` aponta para o proprio celular. Por isso use o IP do notebook na rede local, por exemplo
`http://192.168.0.10:8080`, quando for instalar o APK manualmente.

O artifact gerado fica em:

```text
artifacts/android-local-fullstack-candidate/
```

Esse pacote e debug, usa a chave debug do Android e serve somente para validacao manual local. Ele nao pode ser promovido
como homologacao estavel.

Para gerar uma versao estavel de homologacao, a CI precisa criar `worklink-android-homologation-<commit>` com:

- backend HTTPS real em `WORKLINK_HOMOLOGATION_API_BASE_URL` ou no input manual `homologation_api_base_url`
- allowlist obrigatoria `WORKLINK_HOMOLOGATION_ALLOWED_HOSTS`
- secrets de assinatura Android de homologacao configurados
- fingerprint publico da chave em `WORKLINK_ANDROID_HOMOLOGATION_CERT_SHA256`

O passo a passo operacional fica em `../docs/operacao/homologacao-android-github-actions.md`.

No GitHub Actions, o mesmo build pode ser gerado de tres formas:

- configurando a repository variable `WORKLINK_HOMOLOGATION_API_BASE_URL`
- configurando o repository secret `WORKLINK_HOMOLOGATION_API_BASE_URL`
- executando manualmente o workflow `WorkLink CI` com o input `homologation_api_base_url`

O APK estavel nao fica salvo como binario no git. Ele fica versionado como asset do GitHub Release da tag semantica, e a
pasta `artifacts/homologation/releases/<versao>/android/` guarda metadados, checksum e o ponteiro para esse asset.
A promocao valida o certificado real do APK com `apksigner` antes de anexar o asset ao Release.

A estrategia de build iOS continua documentada em `../docs/ci-cd/ESTRATEGIA-IOS.md`.

## Preview web no navegador

Para acompanhar a evolucao visual das telas sem depender do Android, o projeto agora pode expor uma preview web em Docker:

```bash
make mobile-web-preview
```

Depois disso, abra:

```text
http://localhost:18080
```

Observacoes:

- o comando agora espera a preview responder antes de anunciar a URL; no primeiro boot pode levar alguns segundos enquanto o Flutter prepara o runtime web
- a preview web usa `WORKLINK_USE_PREVIEW_DATA=true` por padrao, entao ela e voltada para revisao visual e navegacao
  rapida da `WLT-030`
- esse preview nao substitui a homologacao principal em APK Android ou emulador
- para acompanhar o bootstrap em tempo real, use `make mobile-web-preview-logs`
- para derrubar o preview, use `make mobile-web-preview-stop`

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
