# Homologacao Android no GitHub Actions

Este runbook prepara a esteira para gerar o APK Android full-stack de homologacao da WLT-029.

## Pre-requisitos

- GitHub CLI autenticado com acesso ao repositorio.
- JDK instalado na maquina usada para gerar a keystore (`keytool` disponivel).
- Backend de homologacao publicado em HTTPS.
- Host do backend definido e aprovado para uso na allowlist.

## 1. Gerar keystore de homologacao

```bash
make generate-android-homologation-keystore
```

O comando cria arquivos locais em:

```text
artifacts/local-secrets/android-homologation/
```

Essa pasta e ignorada pelo git e nao deve ser versionada.

## 2. Configurar variables e secrets no GitHub

Com a URL real de homologacao:

```bash
WORKLINK_HOMOLOGATION_API_BASE_URL=https://homologacao.seu-dominio.com \
make configure-android-homologation-github-env
```

O comando configura:

- `WORKLINK_HOMOLOGATION_API_BASE_URL`
- `WORKLINK_HOMOLOGATION_ALLOWED_HOSTS`
- `WORKLINK_ANDROID_HOMOLOGATION_CERT_SHA256`
- `WORKLINK_ANDROID_HOMOLOGATION_KEYSTORE_BASE64`
- `WORKLINK_ANDROID_HOMOLOGATION_KEYSTORE_PASSWORD`
- `WORKLINK_ANDROID_HOMOLOGATION_KEY_ALIAS`
- `WORKLINK_ANDROID_HOMOLOGATION_KEY_PASSWORD`

## 3. Executar a CI

Depois da configuracao, execute manualmente o workflow `WorkLink CI` ou faca um novo push.

O run deve publicar:

```text
worklink-android-homologation-<commit>
```

## 4. Promover para release semantica

Depois que a tag semantica existir:

```bash
VERSION=vX.Y.Z RUN_ID=<github-actions-run-id> make promote-android-homologation-artifact
```

A promocao valida:

- artifact full-stack;
- URL HTTPS allowlisted;
- build `release`;
- assinatura diferente de debug;
- fingerprint real do APK via `apksigner`;
- checksum do APK.

O APK fica como asset do GitHub Release. O git guarda apenas metadados, checksum e ponteiro para o asset.

## Observacoes

- URL local, HTTP, IPv6, `localhost`, `.local` e IP privado nao geram artifact promovivel.
- APK debug local pode ser usado para teste rapido no aparelho, mas nao fecha homologacao.
- iOS deve passar por fluxo equivalente antes de qualquer submissao para App Store.
