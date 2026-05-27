import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/professional_contact/professional_contact_controller.dart';
import 'package:worklink_mobile/features/professional_contact/professional_contact_intention.dart';
import 'package:worklink_mobile/features/professional_contact/professional_contact_screen.dart';

void main() {
  const contactIntention = ProfessionalContactIntention(
    contactIntentionIdentifier: 'contact-intention-1',
    professionalIdentifier: 'maria-eletricista',
    professionalName: 'Maria Eletricista',
    whatsappContactLink: 'https://wa.me/51999999999',
  );

  Future<void> pumpProfessionalContactScreen(
    WidgetTester widgetTester,
    ProfessionalContactController controller, {
    ValueChanged<String>? onOpenPostContactFeedback,
  }) async {
    widgetTester.view.physicalSize = const Size(800, 1600);
    widgetTester.view.devicePixelRatio = 1;
    addTearDown(widgetTester.view.resetPhysicalSize);
    addTearDown(widgetTester.view.resetDevicePixelRatio);
    await widgetTester.pumpWidget(
      MaterialApp(
        home: ProfessionalContactScreen(
          professionalIdentifier: 'maria-eletricista',
          professionalName: 'Maria Eletricista',
          professionalContactController: controller,
          onOpenPostContactFeedback: onOpenPostContactFeedback,
        ),
      ),
    );
  }

  testWidgets(
      'GIVEN tela de contato WHEN renderizar THEN deve exibir avisos obrigatorios',
      (widgetTester) async {
    // GIVEN
    final controller = ProfessionalContactController(
      registerProfessionalContactIntention: (_) async => contactIntention,
      openProfessionalWhatsappContact: (_) async => true,
    );

    // WHEN
    await pumpProfessionalContactScreen(widgetTester, controller);

    // THEN
    expect(find.text('Falar com o profissional'), findsOneWidget);
    expect(find.text('Maria Eletricista'), findsOneWidget);
    expect(
      find.textContaining('Você será redirecionado para o WhatsApp'),
      findsOneWidget,
    );
    expect(
      find.text('Sua segurança importa'),
      findsOneWidget,
    );
    expect(find.text('Abrir no WhatsApp'), findsOneWidget);
  });

  testWidgets(
      'GIVEN contato autenticado WHEN abrir WhatsApp THEN deve mostrar intencao registrada',
      (widgetTester) async {
    // GIVEN
    final controller = ProfessionalContactController(
      registerProfessionalContactIntention: (_) async => contactIntention,
      openProfessionalWhatsappContact: (_) async => true,
    );
    await pumpProfessionalContactScreen(widgetTester, controller);

    // WHEN
    await widgetTester.tap(
      find.byKey(const ValueKey('start-whatsapp-contact-button')),
    );
    await widgetTester.pumpAndSettle();

    // THEN
    expect(find.text('Intenção de contato registrada.'), findsOneWidget);
    expect(
      find.text('WhatsApp aberto para continuar a conversa.'),
      findsOneWidget,
    );
  });

  testWidgets(
      'GIVEN erro no redirecionamento WHEN abrir WhatsApp THEN deve exibir falha',
      (widgetTester) async {
    // GIVEN
    final controller = ProfessionalContactController(
      registerProfessionalContactIntention: (_) async => contactIntention,
      openProfessionalWhatsappContact: (_) async => false,
    );
    await pumpProfessionalContactScreen(widgetTester, controller);

    // WHEN
    await widgetTester.tap(
      find.byKey(const ValueKey('start-whatsapp-contact-button')),
    );
    await widgetTester.pumpAndSettle();

    // THEN
    expect(find.text('Intenção de contato registrada.'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('professional-contact-error-message')),
      findsOneWidget,
    );
  });

  testWidgets(
      'GIVEN contato finalizado WHEN abrir pos-contato THEN deve emitir identificador da intencao',
      (widgetTester) async {
    // GIVEN
    String? openedContactIntentionIdentifier;
    final controller = ProfessionalContactController(
      registerProfessionalContactIntention: (_) async => contactIntention,
      openProfessionalWhatsappContact: (_) async => true,
    );
    await pumpProfessionalContactScreen(
      widgetTester,
      controller,
      onOpenPostContactFeedback: (contactIntentionIdentifier) {
        openedContactIntentionIdentifier = contactIntentionIdentifier;
      },
    );
    await widgetTester.tap(
      find.byKey(const ValueKey('start-whatsapp-contact-button')),
    );
    await widgetTester.pumpAndSettle();

    // WHEN
    await widgetTester.tap(
      find.byKey(const ValueKey('open-post-contact-feedback-button')),
    );
    await widgetTester.pumpAndSettle();

    // THEN
    expect(openedContactIntentionIdentifier, 'contact-intention-1');
  });
}
