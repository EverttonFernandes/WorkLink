# Entrega WLT-020 — Projeto nativo mobile Android/iOS

## Identificador

- História: `WLT-020`
- Data: `2026-05-10`
- Tipo semântico sugerido: `MINOR`

## Objetivo técnico

Gerar estrutura nativa completa de Android e iOS para que o app Flutter possa ser compilado e publicado nas respectivas lojas (Google Play, Apple App Store).

## Contexto

Atualmente o projeto Flutter existe mas a pasta `android/` nunca foi gerada formalmente. Esta história padroniza a geração e configuração.

## Requisitos técnicos atendidos

- Capacidade de compilar APK para Android.
- Capacidade de compilar app bundle para iOS.
- Permissões necessárias documentadas.
- Assinatura de app configurada para testes internos.

## O que foi implementado

- Inicialização formal: `flutter create . --platforms=android,ios`.
- Configuração Android:
  - `android/app/build.gradle.kts` — versão compilage, dependências, signatures.
  - `android/app/src/main/AndroidManifest.xml` — permissões (acesso à câmera para portfólio, localização para discovery).
  - `android/local.properties` — SDK path.
  - Signatores de debug e release criados.

- Configuração iOS:
  - `ios/Runner.xcodeproj` — target setup.
  - `ios/Runner/Info.plist` — permissões NSCameraUsageDescription, NSLocationWhenInUseUsageDescription.
  - Provisioning profiles para development e distribution.
  - Build settings: minimum deployment target iOS 12.0+.

- Documentação:
  - `worklink-mobile/BUILD-GUIDE-ANDROID.md` — passos para gerar APK.
  - `worklink-mobile/BUILD-GUIDE-IOS.md` — passos para gerar archive.
  - Makefile targets: `mobile-android-build`, `mobile-ios-build`.

- Testes: Build local de APK debug, validação de assinatura.

## O que não foi implementado

- Distribuição automática (upload automatizado para Google Play/App Store).
- Configuração de fastlane (será WLT-025 futura).
- Diretório de assets iOS (certificados/provisioning profiles).

## Fluxos, telas, endpoints ou módulos envolvidos

- Diretórios: `worklink-mobile/android/`, `worklink-mobile/ios/`.
- Makefile com targets de build.
- `.github/workflows/ci.yml` inclui `mobile-android-build`.

## Estratégia de testes

- Build local: `flutter build apk --debug` sucesso.
- Build iOS (se possível): `flutter build ios --no-codesign` sucesso.
- Makefile: `make mobile-android-build` PASS.
- CI/CD: build executado em cada push.

## Evidências de validação

- `make mobile-android-build`: APK gerado em `build/app/outputs/flutter-apk/app-debug.apk`.
- APK pode ser instalado via `adb install`.
- Makefile `mobile-ios-build` documentado e testável.
- CI/CD job completa sem erro.

## Riscos ou limitações remanescentes

- Certificados e provisioning profiles iOS requerem conta Apple válida.
- Assinatura de release ainda é manual (não automatizada).
- Build iOS não é testado em CI/CD (requer runner macOS).

## Arquivos ou módulos relevantes

- `worklink-mobile/android/` — configuração Android nativa.
- `worklink-mobile/ios/` — configuração iOS nativa.
- `worklink-mobile/BUILD-GUIDE-*.md` — documentação de build.
- `Makefile` targets: `mobile-android-build`, `mobile-ios-build`.

## Justificativa do versionamento

Entrega `MINOR` porque habilita builds sem mudança de lógica. Pré-requisito para publicação.
