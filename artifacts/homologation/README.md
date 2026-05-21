# WorkLink Homologation Artifacts

Esta pasta guarda o contrato das versoes estaveis de homologacao.

## Regra principal

Somente artifacts full-stack devem entrar aqui como versao estavel de homologacao. Um APK de `preview` ou offline pode ajudar em desenvolvimento, mas nao deve ser promovido como evidencia de release homologada.

## Estrutura esperada

```text
artifacts/homologation/releases/
  vX.Y.Z/
    android/
      BUILD-METADATA.txt
      SHA256SUMS
      INSTALL-ANDROID.md
      APK-ASSET.md
      PROMOTION-METADATA.txt
    ios/
      TESTFLIGHT-METADATA.md
```

O APK Android homologado deve ficar versionado como asset do GitHub Release da tag semantica, nao como binario dentro do git.
A pasta `artifacts/homologation/releases/` guarda o contrato auditavel: metadados, checksum, origem do run e ponteiro para o asset.

## Requisitos para promover uma versao

- A versao semantica precisa estar fechada por tag.
- O APK Android deve ser `release`, assinado com chave de homologacao e apontar para um backend HTTPS real de homologacao.
- O backend de homologacao deve ter migrations aplicadas e massa fake carregada.
- O checksum precisa estar registrado e validado.
- O host do backend precisa estar na allowlist obrigatoria `WORKLINK_HOMOLOGATION_ALLOWED_HOSTS`.
- A promocao precisa validar o certificado real do APK com `apksigner` e comparar com `WORKLINK_ANDROID_HOMOLOGATION_CERT_SHA256`.
- O iOS deve ter evidencia equivalente via TestFlight ou mecanismo interno aprovado antes de App Store.

## Promocao Android

Depois que o GitHub Actions gerar `worklink-android-homologation-<commit>` com backend real configurado:

```bash
VERSION=vX.Y.Z RUN_ID=<github-actions-run-id> make promote-android-homologation-artifact
```

O script rejeita artifacts `preview`, artifacts sem `api_base_url` e artifacts com checksum invalido.
Tambem rejeita APK debug ou assinado com a chave debug do Android.

Por padrao, o script publica `worklink-android-homologation.apk` como asset do GitHub Release da versao informada. A tag
semantica precisa existir antes da promocao.

O artifact full-stack pode ser gerado pela CI quando existir `WORKLINK_HOMOLOGATION_API_BASE_URL` como repository variable,
como repository secret, ou quando o workflow `WorkLink CI` for executado manualmente com o input `homologation_api_base_url`.
Para gerar um APK promovivel, tambem configure os secrets:

- `WORKLINK_ANDROID_HOMOLOGATION_KEYSTORE_BASE64`
- `WORKLINK_ANDROID_HOMOLOGATION_KEYSTORE_PASSWORD`
- `WORKLINK_ANDROID_HOMOLOGATION_KEY_ALIAS`
- `WORKLINK_ANDROID_HOMOLOGATION_KEY_PASSWORD`

E configure a repository variable:

- `WORKLINK_ANDROID_HOMOLOGATION_CERT_SHA256`

O comando de promocao precisa ter `apksigner` disponivel no `PATH`, no Android SDK (`ANDROID_HOME`/`ANDROID_SDK_ROOT`) ou
via `APKSIGNER=/caminho/para/apksigner`.

## Estado atual

A pasta ainda nao contem APK estavel de homologacao. O primeiro APK full-stack deve ser promovido somente depois que a pipeline gerar `worklink-android-homologation-<commit>` com `WORKLINK_HOMOLOGATION_API_BASE_URL` configurada.
