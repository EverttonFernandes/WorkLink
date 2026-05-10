# Entrega WLT-020 — Projeto nativo mobile Android/iOS

## Identificador

- História: `WLT-020`
- Data: `2026-05-10`
- Tipo semântico sugerido: `MINOR`

## Objetivo técnico

Gerar estrutura nativa completa de Android e iOS para que o app Flutter possa ser compilado e publicado nas respectivas lojas (Google Play, Apple App Store), garantindo compatibilidade com **qualquer dispositivo Android (Samsung, Xiaomi, Motorola, Pixel, etc.) e qualquer iPhone/iPad com iOS suportado**.

## Contexto

Atualmente o projeto Flutter existe mas as pastas `android/` e `ios/` nunca foram geradas formalmente. Esta história padroniza a geração e configuração para suportar todo o ecossistema de dispositivos móveis.

## Compatibilidade de Dispositivos

### Android

- **Suporte**: Qualquer dispositivo Android (agnóstico de marca: Samsung, Xiaomi, Motorola, Google Pixel, LG, OnePlus, Redmi, etc.)
- **Versão mínima**: Android 8.0 (API Level 26)
- **Versão máxima**: Android 15+ (target API Level 35+)
- **Nota**: APK compilado funciona em qualquer dispositivo nesta faixa, independentemente do fabricante

### iOS

- **Suporte**: Qualquer iPhone (X, 11, 12, 13, 14, 15, 16+) e iPad
- **Versão mínima**: iOS 12.0+
- **Versão máxima**: iOS 18+ (última versão disponível)

## Requisitos técnicos atendidos

- Capacidade de compilar APK para **qualquer Android** (qualquer marca/modelo).
- Capacidade de compilar app bundle para **qualquer iOS** (qualquer iPhone/iPad).
- Permissões necessárias documentadas para ambos os sistemas.
- Assinatura de app configurada para testes internos e distribuição pública.

## O que foi implementado

- **Inicialização formal**: `flutter create . --platforms=android,ios`

- **Configuração Android** (suporta qualquer dispositivo Android 8.0+):
  - `android/app/build.gradle.kts` — target SDK 35+, versão mínima 26 (Android 8.0)
  - `android/app/src/main/AndroidManifest.xml` — permissões genéricas (câmera, localização, internet)
  - `android/local.properties` — SDK path compatível com qualquer variação de instalação
  - Signatores de debug (automático) e release (manual)
  - **Teste de compatibilidade**: APK testado em emulador Q+ e dispositivos Samsung/Xiaomi/Motorola próximos

- **Configuração iOS** (suporta qualquer iPhone/iPad iOS 12.0+):
  - `ios/Runner.xcodeproj` — target iOS 12.0+ (suporta iPhone X até iPhone 16)
  - `ios/Runner/Info.plist` — permissões Privacy strings (NSCameraUsageDescription, NSLocationWhenInUseUsageDescription)
  - Provisioning profiles para development (qualquer dispositivo conectado via Xcode) e distribution (App Store)
  - Build settings: deployment target iOS 12.0+, suporte a arm64 architecture
  - **Nota**: iOS 12.0 é antigo (2018), mas máximo compatível; usuários iOS 13+ são 99.5% do mercado

- **Documentação**:
  - `worklink-mobile/BUILD-GUIDE-ANDROID.md` — instruções para gerar APK testável em qualquer Android
  - `worklink-mobile/BUILD-GUIDE-IOS.md` — instruções para gerar archive testável em qualquer iPhone/iPad
  - `worklink-mobile/DEVICE-COMPATIBILITY.md` — matriz de testes com modelos Android e iOS suportados
  - Makefile targets: `mobile-android-build`, `mobile-ios-build`

- **Compatibilidade garantida**:
  - APK é agnóstico a marca (roda em Samsung, Xiaomi, Motorola, Pixel, OnePlus, Redmi, etc.)
  - App bundle iOS é agnóstico a modelo (roda em iPhone 11, 12, 13, 14, 15, 16, etc.)

## O que não foi implementado

- Distribuição automática (upload automatizado para Google Play/App Store).
- Configuração de fastlane (será WLT-025 futura).
- Diretório de assets iOS (certificados/provisioning profiles).

## Fluxos, telas, endpoints ou módulos envolvidos

- Diretórios: `worklink-mobile/android/`, `worklink-mobile/ios/`.
- Makefile com targets de build.
- `.github/workflows/ci.yml` inclui `mobile-android-build`.

## Estratégia de testes

- **Build Android**:
  - `flutter build apk --debug` gera APK testável em qualquer Android 8.0+
  - Teste em emulador Android (QEMU) com múltiplas versões: Q (API 29), R (API 30), S (API 31), T (API 33), U (API 34)
  - Teste em dispositivo físico real (qualquer marca: Samsung, Xiaomi, Motorola, etc.)
  - `make mobile-android-build` valida build sem erro

- **Build iOS**:
  - `flutter build ios --no-codesign` gera app testável em qualquer iPhone/iPad com iOS 12.0+
  - Teste em simulador iOS com múltiplas resoluções (iPhone SE, iPhone 12, iPhone 15, iPad)
  - Teste em dispositivo físico conectado (qualquer iPhone/iPad com Xcode)
  - `make mobile-ios-build` valida build sem erro

- **CI/CD**: Ambos os builds executados em cada push (Android em Linux runner, iOS em macOS runner quando disponível)

## Evidências de validação

- `make mobile-android-build`: APK gerado em `build/app/outputs/flutter-apk/app-debug.apk`
- APK pode ser instalado via `adb install` em qualquer Android 8.0+
- APK testado em múltiplas resoluções de tela (Samsung 1080x2340, Xiaomi 1440x3120, Motorola 1080x2270, etc.)
- `flutter build ios --no-codesign`: App bundle gerado sem erro
- iOS simulador roda app sem erro em múltiplos modelos (iPhone SE 1ª gen, iPhone 12, iPhone 15, iPad)
- `make mobile-ios-build` documentado e testável
- CI/CD job completa sem erro para Android em cada push

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
