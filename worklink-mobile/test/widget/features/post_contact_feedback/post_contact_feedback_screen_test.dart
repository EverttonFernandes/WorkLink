import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/post_contact_feedback/post_contact_feedback_controller.dart';
import 'package:worklink_mobile/features/post_contact_feedback/post_contact_feedback_screen.dart';
import 'package:worklink_mobile/features/post_contact_feedback/post_contact_feedback_state.dart';

void main() {
  Future<void> pumpPostContactFeedbackScreen(
    WidgetTester widgetTester,
    PostContactFeedbackController controller, {
    ValueChanged<String>? onOpenProfessionalReview,
  }) async {
    widgetTester.view.physicalSize = const Size(800, 1600);
    widgetTester.view.devicePixelRatio = 1;
    addTearDown(widgetTester.view.resetPhysicalSize);
    addTearDown(widgetTester.view.resetDevicePixelRatio);
    await widgetTester.pumpWidget(
      MaterialApp(
        home: PostContactFeedbackScreen(
          postContactFeedbackController: controller,
          onOpenProfessionalReview: onOpenProfessionalReview,
        ),
      ),
    );
  }

  testWidgets(
      'GIVEN tela pos-contato WHEN renderizar THEN deve exibir perguntas obrigatorias',
      (widgetTester) async {
    // GIVEN
    final controller = PostContactFeedbackController(
      contactIntentionIdentifier: 'contact-intention-1',
      submitPostContactFeedback: (_, __) async {},
    );

    // WHEN
    await pumpPostContactFeedbackScreen(widgetTester, controller);

    // THEN
    expect(find.text('Como foi seu contato?'), findsOneWidget);
    expect(find.text('Sua opinião faz a diferença!'), findsOneWidget);
    expect(find.text('Você conseguiu falar com o profissional?'), findsOneWidget);
    expect(find.text('Como foi a resposta?'), findsOneWidget);
    expect(find.text('O serviço foi realizado?'), findsOneWidget);
  });

  testWidgets(
      'GIVEN respostas completas WHEN enviar THEN deve registrar feedback com sucesso',
      (widgetTester) async {
    // GIVEN
    String? submittedContactIntentionIdentifier;
    PostContactFeedbackState? submittedFeedbackState;
    final controller = PostContactFeedbackController(
      contactIntentionIdentifier: 'contact-intention-1',
      submitPostContactFeedback: (contactIntentionIdentifier, feedbackState) {
        submittedContactIntentionIdentifier = contactIntentionIdentifier;
        submittedFeedbackState = feedbackState;
        return Future<void>.value();
      },
    );
    await pumpPostContactFeedbackScreen(widgetTester, controller);

    // WHEN
    await widgetTester.tap(
      find.byKey(
        const ValueKey(
          'conversation-outcome-PostContactConversationOutcome.customerReachedProfessional',
        ),
      ),
    );
    await widgetTester.tap(
      find.byKey(
        const ValueKey(
          'contact-responsiveness-PostContactResponsiveness.fastResponse',
        ),
      ),
    );
    await widgetTester.tap(
      find.byKey(
        const ValueKey(
          'service-execution-PostContactServiceExecutionOutcome.servicePerformed',
        ),
      ),
    );
    await widgetTester.tap(
      find.byKey(const ValueKey('submit-post-contact-feedback-button')),
    );
    await widgetTester.pumpAndSettle();

    // THEN
    expect(submittedContactIntentionIdentifier, 'contact-intention-1');
    expect(
      submittedFeedbackState?.conversationOutcome,
      PostContactConversationOutcome.customerReachedProfessional,
    );
    expect(find.text('Feedback pós-contato registrado.'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('open-professional-review-button')),
      findsOneWidget,
    );
  });

  testWidgets(
      'GIVEN respostas incompletas WHEN enviar THEN deve exibir mensagem de erro',
      (widgetTester) async {
    // GIVEN
    final controller = PostContactFeedbackController(
      contactIntentionIdentifier: 'contact-intention-1',
      submitPostContactFeedback: (_, __) async {},
    );
    await pumpPostContactFeedbackScreen(widgetTester, controller);

    // WHEN
    await widgetTester.tap(
      find.byKey(const ValueKey('submit-post-contact-feedback-button')),
    );
    await widgetTester.pumpAndSettle();

    // THEN
    expect(
      find.byKey(const ValueKey('post-contact-feedback-error-message')),
      findsOneWidget,
    );
    expect(
      find.text('Responda todas as perguntas para enviar.'),
      findsOneWidget,
    );
  });

  testWidgets(
      'GIVEN servico realizado WHEN abrir avaliacao THEN deve informar contato elegivel',
      (widgetTester) async {
    // GIVEN
    String? openedReviewContactIntentionIdentifier;
    final controller = PostContactFeedbackController(
      contactIntentionIdentifier: 'contact-intention-1',
      submitPostContactFeedback: (_, __) async {},
    );
    await pumpPostContactFeedbackScreen(
      widgetTester,
      controller,
      onOpenProfessionalReview: (contactIntentionIdentifier) {
        openedReviewContactIntentionIdentifier = contactIntentionIdentifier;
      },
    );

    // WHEN
    await widgetTester.tap(
      find.byKey(
        const ValueKey(
          'conversation-outcome-PostContactConversationOutcome.customerReachedProfessional',
        ),
      ),
    );
    await widgetTester.tap(
      find.byKey(
        const ValueKey(
          'contact-responsiveness-PostContactResponsiveness.fastResponse',
        ),
      ),
    );
    await widgetTester.tap(
      find.byKey(
        const ValueKey(
          'service-execution-PostContactServiceExecutionOutcome.servicePerformed',
        ),
      ),
    );
    await widgetTester.tap(
      find.byKey(const ValueKey('submit-post-contact-feedback-button')),
    );
    await widgetTester.pumpAndSettle();
    await widgetTester.tap(
      find.byKey(const ValueKey('open-professional-review-button')),
    );
    await widgetTester.pumpAndSettle();

    // THEN
    expect(openedReviewContactIntentionIdentifier, 'contact-intention-1');
  });

  testWidgets(
      'GIVEN servico nao realizado WHEN registrar pos-contato THEN nao deve oferecer avaliacao',
      (widgetTester) async {
    // GIVEN
    final controller = PostContactFeedbackController(
      contactIntentionIdentifier: 'contact-intention-1',
      submitPostContactFeedback: (_, __) async {},
    );
    await pumpPostContactFeedbackScreen(widgetTester, controller);

    // WHEN
    await widgetTester.tap(
      find.byKey(
        const ValueKey(
          'conversation-outcome-PostContactConversationOutcome.customerDidNotReachProfessional',
        ),
      ),
    );
    await widgetTester.tap(
      find.byKey(
        const ValueKey(
          'contact-responsiveness-PostContactResponsiveness.noResponse',
        ),
      ),
    );
    await widgetTester.tap(
      find.byKey(
        const ValueKey(
          'service-execution-PostContactServiceExecutionOutcome.serviceNotPerformed',
        ),
      ),
    );
    await widgetTester.tap(
      find.byKey(const ValueKey('submit-post-contact-feedback-button')),
    );
    await widgetTester.pumpAndSettle();

    // THEN
    expect(find.text('Feedback pós-contato registrado.'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('open-professional-review-button')),
      findsNothing,
    );
  });
}
