# Preparacao iOS para CI e TestFlight

## Objetivo

Definir como o WorkLink habilitara build iOS em runner macOS e distribuicao futura via TestFlight sem versionar
credenciais Apple.

## O que pode ser validado agora

Sem conta Apple e sem secrets reais, o projeto pode validar:

- estrutura `worklink-mobile/ios/`;
- presenca de `Runner.xcworkspace`;
- presenca de `Runner.xcodeproj`;
- `Info.plist`;
- `AppDelegate.swift`;
- ausencia de certificados, profiles e chaves privadas versionados;
- build iOS sem assinatura com `flutter build ios --no-codesign` em runner macOS.

## O que depende da Apple Developer Account

- Bundle identifier definitivo.
- Team ID.
- certificado de distribuicao.
- provisioning profile.
- App Store Connect API key.
- cadastro do app no App Store Connect.
- upload para TestFlight.
- teste manual em iPhone real via TestFlight.

## Secrets esperados

Os nomes abaixo sao contrato futuro. Valores reais nunca devem ser commitados.

| Secret | Uso |
| ------ | --- |
| `WORKLINK_APPLE_TEAM_ID` | Team ID da Apple Developer Account |
| `WORKLINK_IOS_BUNDLE_IDENTIFIER` | Bundle identifier do app iOS |
| `WORKLINK_APP_STORE_CONNECT_API_KEY_ID` | Key ID da API App Store Connect |
| `WORKLINK_APP_STORE_CONNECT_ISSUER_ID` | Issuer ID da API App Store Connect |
| `WORKLINK_APP_STORE_CONNECT_API_PRIVATE_KEY` | Chave privada `.p8` como secret |
| `WORKLINK_IOS_DISTRIBUTION_CERTIFICATE_BASE64` | Certificado `.p12` codificado em base64 |
| `WORKLINK_IOS_DISTRIBUTION_CERTIFICATE_PASSWORD` | Senha do certificado |
| `WORKLINK_IOS_PROVISIONING_PROFILE_BASE64` | Provisioning profile codificado em base64 |

## Workflow iOS

O workflow `.github/workflows/ios-build.yml` e manual por padrao.

Modos previstos:

- `no-codesign`: valida projeto iOS em macOS sem assinar nem enviar para TestFlight.
- `testflight`: futuro, exige todos os secrets Apple e deve falhar se qualquer secret faltar.

## Regras de seguranca

- Nunca versionar `.p12`, `.p8`, `.mobileprovision`, `.provisionprofile`, `.cer`, `.key` ou `GoogleService-Info.plist`.
- Nunca imprimir valores de secrets em logs.
- Preferir App Store Connect API key a credenciais pessoais.
- Runner macOS deve ser usado com parcimonia por custo.

## Proximo incremento

A WLT-027 deve governar secrets/assinatura mobile de forma ampla.
A WLT-028 deve cobrir promocao, rollback e fluxo de release.
