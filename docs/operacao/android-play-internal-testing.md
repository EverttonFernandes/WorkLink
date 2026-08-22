# Android AAB e Play Internal Testing - Profissional Perto

## Objetivo

Este guia formaliza o caminho Android de loja para gerar um `AAB` rastreavel e validar o app pela trilha `Internal
testing` da Google Play antes de qualquer solicitacao de producao.

## Secrets e variables obrigatorios

- `WORKLINK_PLAY_STORE_API_BASE_URL`
- `WORKLINK_HOMOLOGATION_ALLOWED_HOSTS`
- `WORKLINK_ANDROID_STORE_KEYSTORE_BASE64`
- `WORKLINK_ANDROID_STORE_KEYSTORE_PASSWORD`
- `WORKLINK_ANDROID_STORE_KEY_ALIAS`
- `WORKLINK_ANDROID_STORE_KEY_PASSWORD`

## Comandos locais

Build do bundle apenas:

```sh
MOBILE_PLAY_STORE_API_BASE_URL=https://api.exemplo.com make mobile-android-appbundle-build
```

Build + pacote rastreavel para a Play:

```sh
MOBILE_PLAY_STORE_API_BASE_URL=https://api.exemplo.com make mobile-android-play-store-candidate
```

O pacote final fica em:

- `artifacts/android-play-internal-candidate/`

Arquivos esperados:

- `profissional-perto-play-internal.aab`
- `BUILD-METADATA.txt`
- `SHA256SUMS`
- `PUBLISH-PLAY-STORE.md`

## Workflow GitHub Actions

O workflow `WorkLink CI` passa a aceitar:

- input manual `play_store_api_base_url`
- variable `WORKLINK_PLAY_STORE_API_BASE_URL`
- secret `WORKLINK_PLAY_STORE_API_BASE_URL`

Quando a URL e os secrets de assinatura existem, a job `mobile` publica o artifact:

- `worklink-android-play-internal-<commit>`

## Regras de seguranca

- Nunca versionar `upload keystore`, JSON de service account ou credenciais do Play Console.
- A upload key da loja deve ser diferente da chave de homologacao.
- O backend usado no bundle precisa ser `HTTPS`, persistente e acessivel fora da rede local.
- Nao gerar AAB de loja apontando para preview/local/tunnel temporario.

## Checklist operacional

1. Confirmar `applicationId` definitivo.
2. Confirmar `versionCode`/`versionName`.
3. Gerar o artifact verde na CI.
4. Baixar o zip do artifact.
5. Conferir `BUILD-METADATA.txt` e `SHA256SUMS`.
6. Subir o `.aab` em `Testing > Internal testing`.
7. Instalar pela Play Store em aparelho real.
8. Executar smoke test manual.
9. Registrar evidencias antes de considerar `Closed testing` ou producao.

## Bloqueios explicitos

Nao avancar para producao publica enquanto algum item abaixo estiver aberto:

- backend cloud nao estavel;
- autenticacao ainda incompleta para uso real;
- Data Safety/politica de privacidade divergentes;
- telas fora dos prototipos homologados;
- smoke test manual reprovado;
- conta pessoal nova ainda sem cumprir `Closed testing` quando exigido pela Google.
