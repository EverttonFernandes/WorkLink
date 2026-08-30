import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/main.dart';

const _visualEvidenceRootKey = ValueKey<String>('wl-026-visual-evidence-root');
const _goldenFontFamily = 'Roboto';
const _flutterTestDefaultFontFamily = 'Ahem';
const _materialIconsFontFamily = 'MaterialIcons';
const _previewProfessionalIdentifier = 'ana-costa-energia-residencial';
const _openPreviewProfessionalProfileKey =
    'open-professional-profile-$_previewProfessionalIdentifier';

void main() {
  setUpAll(() async {
    const materialFontsDirectory =
        '/sdks/flutter/bin/cache/artifacts/material_fonts';
    final robotoFontLoader = FontLoader(_goldenFontFamily);
    final flutterTestDefaultFontLoader = FontLoader(
      _flutterTestDefaultFontFamily,
    );
    for (final fontFileName in [
      'Roboto-Light.ttf',
      'Roboto-Regular.ttf',
      'Roboto-Medium.ttf',
      'Roboto-Bold.ttf',
      'Roboto-Black.ttf',
    ]) {
      final fontBytes = await File(
        '$materialFontsDirectory/$fontFileName',
      ).readAsBytes();
      robotoFontLoader.addFont(
        Future.value(ByteData.sublistView(Uint8List.fromList(fontBytes))),
      );
      flutterTestDefaultFontLoader.addFont(
        Future.value(ByteData.sublistView(Uint8List.fromList(fontBytes))),
      );
    }
    final materialIconsFontBytes = await File(
      '$materialFontsDirectory/MaterialIcons-Regular.otf',
    ).readAsBytes();
    await robotoFontLoader.load();
    await flutterTestDefaultFontLoader.load();
    await (FontLoader(_materialIconsFontFamily)
          ..addFont(
            Future.value(
              ByteData.sublistView(Uint8List.fromList(materialIconsFontBytes)),
            ),
          ))
        .load();
  });

  Future<void> pumpAnonymousDiscovery(WidgetTester widgetTester) async {
    widgetTester.view.physicalSize = const Size(430, 932);
    widgetTester.view.devicePixelRatio = 1;
    addTearDown(widgetTester.view.resetPhysicalSize);
    addTearDown(widgetTester.view.resetDevicePixelRatio);
    await widgetTester.pumpWidget(
      const RepaintBoundary(
        key: _visualEvidenceRootKey,
        child: WorkLinkApp.preview(themeFontFamily: _goldenFontFamily),
      ),
    );
    await widgetTester.pumpAndSettle();
  }

  Future<void> openProfessionalAuthenticationGate(
    WidgetTester widgetTester,
  ) async {
    final professionalCard = find.byKey(
      const ValueKey(_openPreviewProfessionalProfileKey),
    );
    await widgetTester.drag(
      find.byType(ListView),
      const Offset(0, -600),
    );
    await widgetTester.pumpAndSettle();
    await widgetTester.ensureVisible(professionalCard);
    await widgetTester.pumpAndSettle();
    await widgetTester.tap(professionalCard);
    await widgetTester.pumpAndSettle();
  }

  Future<void> authenticateCustomer(WidgetTester widgetTester) async {
    await widgetTester.enterText(
      find.byKey(const ValueKey('authentication-email-field')),
      'cliente@exemplo.com',
    );
    await widgetTester.enterText(
      find.byKey(const ValueKey('authentication-password-field')),
      'senha-segura-123',
    );
    await widgetTester.ensureVisible(
      find.byKey(const ValueKey('sign-in-button')),
    );
    await widgetTester.tap(find.byKey(const ValueKey('sign-in-button')));
    await widgetTester.pumpAndSettle();
  }

  Future<void> captureGolden(
    WidgetTester widgetTester,
    String goldenFileName,
  ) async {
    await expectLater(
      find.byKey(_visualEvidenceRootKey),
      matchesGoldenFile('goldens/$goldenFileName'),
    );
  }

  group('WL-026 evidencias visuais automatizadas', () {
    testWidgets(
        'GIVEN descoberta anonima WHEN renderizar THEN deve registrar card de entrada opcional',
        (widgetTester) async {
      // GIVEN
      await pumpAnonymousDiscovery(widgetTester);

      // WHEN
      await captureGolden(
        widgetTester,
        'wl-026-01-descoberta-card-anonimo.png',
      );

      // THEN
      expect(find.text('Explore antes de entrar'), findsOneWidget);
    });

    testWidgets(
        'GIVEN descoberta anonima WHEN tocar no profissional THEN deve registrar gate de login',
        (widgetTester) async {
      // GIVEN
      await pumpAnonymousDiscovery(widgetTester);

      // WHEN
      await openProfessionalAuthenticationGate(widgetTester);
      await captureGolden(
        widgetTester,
        'wl-026-02-gate-login-profissional.png',
      );

      // THEN
      expect(find.text('Acesse sua conta'), findsOneWidget);
    });

    testWidgets(
        'GIVEN gate de login WHEN autenticar THEN deve registrar retorno ao perfil solicitado',
        (widgetTester) async {
      // GIVEN
      await pumpAnonymousDiscovery(widgetTester);
      await openProfessionalAuthenticationGate(widgetTester);

      // WHEN
      await authenticateCustomer(widgetTester);
      await captureGolden(
        widgetTester,
        'wl-026-03-retorno-perfil-autenticado.png',
      );

      // THEN
      expect(find.text('Perfil do profissional'), findsOneWidget);
      expect(find.text('Ana Costa Energia Residencial'), findsOneWidget);
    });
  });
}
