# Governanca de secrets e assinatura mobile

## Objetivo

Esta politica define o contrato minimo para Android e iOS evoluirem para distribuicao segura sem versionar keystores,
certificados, provisioning profiles, chaves privadas ou credenciais de loja.

## Inventario por ambiente

| Nome | Ambiente | Plataforma | Obrigatoriedade | Uso |
| ---- | -------- | ---------- | --------------- | --- |
| `SONAR_TOKEN` | CI | Qualidade | Opcional | Executa SonarCloud em `main` quando `SONAR_ORGANIZATION` e `SONAR_PROJECT_KEY` existem. |
| `WORKLINK_HOMOLOGATION_API_BASE_URL` | Homologacao | Android | Opcional para CI, obrigatorio para APK homologavel | Define o backend full-stack usado no APK Android de homologacao. |
| `WORKLINK_HOMOLOGATION_ALLOWED_HOSTS` | Homologacao | Android | Obrigatorio quando URL publica e validada | Limita dominios aceitos para backend de homologacao. |
| `WORKLINK_ANDROID_HOMOLOGATION_KEYSTORE_BASE64` | Homologacao | Android | Obrigatorio para CD | Keystore JKS de homologacao codificado em base64. |
| `WORKLINK_ANDROID_HOMOLOGATION_KEYSTORE_PASSWORD` | Homologacao | Android | Obrigatorio para CD | Senha do keystore Android de homologacao. |
| `WORKLINK_ANDROID_HOMOLOGATION_KEY_ALIAS` | Homologacao | Android | Obrigatorio para CD | Alias da chave usada no APK de homologacao. |
| `WORKLINK_ANDROID_HOMOLOGATION_KEY_PASSWORD` | Homologacao | Android | Obrigatorio para CD | Senha da chave usada no APK de homologacao. |
| `WORKLINK_ANDROID_HOMOLOGATION_CERT_SHA256` | Homologacao | Android | Obrigatorio para promocao estavel | Fingerprint SHA-256 esperado para validar APK promovido. |
| `WORKLINK_PLAY_STORE_API_BASE_URL` | Loja | Android | Obrigatorio para AAB de loja | Backend HTTPS estavel usado na build Android distribuida pela Play Store. |
| `WORKLINK_ANDROID_STORE_KEYSTORE_BASE64` | Loja | Android | Obrigatorio para CD | Upload keystore JKS do Android para Play App Signing, codificado em base64. |
| `WORKLINK_ANDROID_STORE_KEYSTORE_PASSWORD` | Loja | Android | Obrigatorio para CD | Senha do upload keystore Android da loja. |
| `WORKLINK_ANDROID_STORE_KEY_ALIAS` | Loja | Android | Obrigatorio para CD | Alias da upload key usada na build AAB da loja. |
| `WORKLINK_ANDROID_STORE_KEY_PASSWORD` | Loja | Android | Obrigatorio para CD | Senha da upload key Android da loja. |
| `WORKLINK_APPLE_TEAM_ID` | TestFlight/Producao | iOS | Obrigatorio para CD | Team ID da Apple Developer Account. |
| `WORKLINK_IOS_BUNDLE_IDENTIFIER` | TestFlight/Producao | iOS | Obrigatorio para CD | Bundle identifier definitivo do app iOS. |
| `WORKLINK_APP_STORE_CONNECT_API_KEY_ID` | TestFlight/Producao | iOS | Obrigatorio para CD | Key ID da App Store Connect API. |
| `WORKLINK_APP_STORE_CONNECT_ISSUER_ID` | TestFlight/Producao | iOS | Obrigatorio para CD | Issuer ID da App Store Connect API. |
| `WORKLINK_APP_STORE_CONNECT_API_PRIVATE_KEY` | TestFlight/Producao | iOS | Obrigatorio para CD | Chave privada `.p8` armazenada como secret. |
| `WORKLINK_IOS_DISTRIBUTION_CERTIFICATE_BASE64` | TestFlight/Producao | iOS | Obrigatorio para CD | Certificado `.p12` codificado em base64. |
| `WORKLINK_IOS_DISTRIBUTION_CERTIFICATE_PASSWORD` | TestFlight/Producao | iOS | Obrigatorio para CD | Senha do certificado `.p12`. |
| `WORKLINK_IOS_PROVISIONING_PROFILE_BASE64` | TestFlight/Producao | iOS | Obrigatorio para CD | Provisioning profile codificado em base64. |

## Obrigatorios para CD

Android homologacao full-stack:

- `WORKLINK_HOMOLOGATION_API_BASE_URL`
- `WORKLINK_HOMOLOGATION_ALLOWED_HOSTS`
- `WORKLINK_ANDROID_HOMOLOGATION_KEYSTORE_BASE64`
- `WORKLINK_ANDROID_HOMOLOGATION_KEYSTORE_PASSWORD`
- `WORKLINK_ANDROID_HOMOLOGATION_KEY_ALIAS`
- `WORKLINK_ANDROID_HOMOLOGATION_KEY_PASSWORD`
- `WORKLINK_ANDROID_HOMOLOGATION_CERT_SHA256`

Android loja/internal testing:

- `WORKLINK_PLAY_STORE_API_BASE_URL`
- `WORKLINK_HOMOLOGATION_ALLOWED_HOSTS`
- `WORKLINK_ANDROID_STORE_KEYSTORE_BASE64`
- `WORKLINK_ANDROID_STORE_KEYSTORE_PASSWORD`
- `WORKLINK_ANDROID_STORE_KEY_ALIAS`
- `WORKLINK_ANDROID_STORE_KEY_PASSWORD`

iOS TestFlight/producao:

- `WORKLINK_APPLE_TEAM_ID`
- `WORKLINK_IOS_BUNDLE_IDENTIFIER`
- `WORKLINK_APP_STORE_CONNECT_API_KEY_ID`
- `WORKLINK_APP_STORE_CONNECT_ISSUER_ID`
- `WORKLINK_APP_STORE_CONNECT_API_PRIVATE_KEY`
- `WORKLINK_IOS_DISTRIBUTION_CERTIFICATE_BASE64`
- `WORKLINK_IOS_DISTRIBUTION_CERTIFICATE_PASSWORD`
- `WORKLINK_IOS_PROVISIONING_PROFILE_BASE64`

## Opcionais para CI

- `SONAR_TOKEN`, `SONAR_ORGANIZATION` e `SONAR_PROJECT_KEY`: sem eles o SonarCloud e pulado.
- `WORKLINK_HOMOLOGATION_API_BASE_URL`: sem ele a CI ainda valida qualidade e gera APK tecnico, mas nao gera APK Android
  full-stack homologavel.
- `WORKLINK_PLAY_STORE_API_BASE_URL`: sem ele a CI ainda valida qualidade e gera APK tecnico, mas nao gera o AAB da Play
  Store para trilha interna.

## Politica de assinatura

| Tipo | Android | iOS |
| ---- | ------- | --- |
| Debug local | Assinatura debug gerada pelo toolchain Flutter/Android. | `flutter build ios --no-codesign` quando a validacao for apenas estrutural. |
| Homologacao | Keystore dedicada de homologacao, diferente da futura chave de producao. | Certificado e profile de distribuicao TestFlight. |
| Loja/internal testing | Upload key dedicada da Play App Signing, separada da chave de homologacao. | Certificado e profile de distribuicao TestFlight. |
| Producao | Chave de producao sob conta de loja, com fingerprint registrado e backup controlado. | Certificado/profile de distribuicao associados ao bundle definitivo. |

## Rotacao e revogacao

- Rotacionar imediatamente qualquer secret com suspeita de exposicao, colaborador removido ou log acidental.
- Rotacionar keys de homologacao antes de transformar homologacao em canal publico ou semi-publico.
- Revogar certificados iOS no Apple Developer quando houver suspeita de vazamento ou perda de controle.
- Gerar novo APK/IPA apos rotacao e registrar o novo fingerprint nos metadados de release.
- Manter o backup offline do material de producao sob posse do dono do produto e de no maximo uma pessoa tecnica designada.

## Ownership

- Dono do produto: aprova criacao, rotacao e uso de credenciais de loja.
- SRE/mobile infra: opera GitHub Actions, environments, variables e secrets.
- Segurança: revisa exposicao acidental, escopo de permissao e trilha de auditoria.
- Front-end mobile: valida que builds assinados seguem o mesmo produto aprovado em QA visual.

## Regras de repositorio

- Nunca versionar `.jks`, `.keystore`, `.p12`, `.p8`, `.cer`, `.key`, `.mobileprovision`, `.provisionprofile`,
  `GoogleService-Info.plist` ou `google-services.json`.
- Gerar material local apenas em `artifacts/local-secrets/`, que permanece ignorado.
- Nao imprimir valores de secrets em logs.
- Documentar apenas nomes de secrets, nunca valores.
- Executar `make mobile-signing-governance` antes de fechar qualquer historia que altere assinatura, secrets, workflows
  mobile ou promocao de release.

## Recuperacao

Se uma credencial for perdida, o projeto deve bloquear promocao, gerar novo material, substituir secrets no GitHub,
validar o fingerprint e publicar nova versao de homologacao antes de qualquer distribuicao ampliada.
