# WorkLink Homologation Artifacts

Esta pasta guarda o contrato das versoes estaveis de homologacao.

## Regra principal

Somente artifacts full-stack devem entrar aqui como versao estavel de homologacao. Um APK de `preview` ou offline pode ajudar em desenvolvimento, mas nao deve ser promovido como evidencia de release homologada.

## Estrutura esperada

```text
artifacts/homologation/releases/
  vX.Y.Z/
    android/
      worklink-android-homologation.apk
      BUILD-METADATA.txt
      SHA256SUMS
      INSTALL-ANDROID.md
    ios/
      TESTFLIGHT-METADATA.md
```

## Requisitos para promover uma versao

- A versao semantica precisa estar fechada por tag.
- O APK Android deve apontar para um backend real de homologacao.
- O backend de homologacao deve ter migrations aplicadas e massa fake carregada.
- O checksum precisa estar registrado e validado.
- O iOS deve ter evidencia equivalente via TestFlight ou mecanismo interno aprovado antes de App Store.

## Estado atual

A pasta ainda nao contem APK estavel de homologacao. O primeiro APK full-stack deve ser promovido somente depois que a pipeline gerar `worklink-android-homologation-<commit>` com `WORKLINK_HOMOLOGATION_API_BASE_URL` configurada.
