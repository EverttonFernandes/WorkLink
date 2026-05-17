import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/discovery/discovery_controller.dart';
import 'package:worklink_mobile/features/discovery/discovery_professional.dart';
import 'package:worklink_mobile/features/discovery/discovery_screen.dart';
import 'package:worklink_mobile/features/post_contact_feedback/pending_post_contact_feedback_prompt.dart';
import 'package:worklink_mobile/features/post_contact_feedback/post_contact_feedback_request.dart';
import 'package:worklink_mobile/features/professional_availability/professional_availability_status.dart';

void main() {
  testWidgets(
      'GIVEN solicitacao pendente WHEN renderizar prompt THEN deve oferecer responder e dispensar',
      (tester) async {
    // GIVEN
    var responded = false;
    var dismissed = false;
    final request = PostContactFeedbackRequest(
      contactIntentionIdentifier: 'contact-1',
      professionalIdentifier: 'professional-1',
      professionalName: 'Maria Eletricista',
      contactCreatedAt: DateTime.parse('2026-05-13T10:00:00Z'),
    );

    // WHEN
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PendingPostContactFeedbackPrompt(
            request: request,
            onRespond: () => responded = true,
            onDismiss: () => dismissed = true,
          ),
        ),
      ),
    );
    await tester.tap(
      find.byKey(
        const ValueKey('respond-pending-post-contact-feedback-button'),
      ),
    );
    await tester.tap(
      find.byKey(
        const ValueKey('dismiss-pending-post-contact-feedback-button'),
      ),
    );

    // THEN
    expect(
      find.byKey(const ValueKey('pending-post-contact-feedback-title')),
      findsOneWidget,
    );
    expect(find.textContaining('Maria Eletricista'), findsOneWidget);
    expect(responded, isTrue);
    expect(dismissed, isTrue);
  });

  testWidgets(
      'GIVEN tela de descoberta WHEN houver conteudo previo THEN deve exibir prompt antes dos filtros',
      (tester) async {
    // GIVEN
    final discoveryController = DiscoveryController(
      availableProfessionals: const [
        DiscoveryProfessional(
          professionalIdentifier: 'maria-eletricista',
          professionalName: 'Maria Eletricista',
          categoryName: 'Eletricista',
          cityName: 'Canoas',
          stateCode: 'RS',
          shortDescription: 'Atendimento residencial.',
          availabilityStatus: ProfessionalAvailabilityStatus.availableToday,
        ),
      ],
    );

    // WHEN
    await tester.pumpWidget(
      MaterialApp(
        home: DiscoveryScreen(
          discoveryController: discoveryController,
          preFiltersContent: PendingPostContactFeedbackPrompt(
            request: PostContactFeedbackRequest(
              contactIntentionIdentifier: 'contact-1',
              professionalIdentifier: 'professional-1',
              professionalName: 'Maria Eletricista',
              contactCreatedAt: DateTime(2026, 5, 13, 10),
            ),
            onRespond: _noop,
            onDismiss: _noop,
          ),
        ),
      ),
    );

    // THEN
    final promptTopLeft = tester.getTopLeft(
      find.byKey(const ValueKey('pending-post-contact-feedback-title')),
    );
    final searchTopLeft = tester.getTopLeft(
      find.byKey(const ValueKey('keyword-search-field')),
    );
    expect(promptTopLeft.dy, lessThan(searchTopLeft.dy));
  });
}

void _noop() {}
