import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/post_contact_feedback/post_contact_feedback_controller.dart';
import 'package:worklink_mobile/features/post_contact_feedback/post_contact_feedback_screen.dart';
import 'package:worklink_mobile/features/post_contact_feedback/post_contact_feedback_state.dart';

void main() {
  Future<void> pumpPostContactFeedbackScreen(
    WidgetTester widgetTester,
    PostContactFeedbackController controller,
  ) async {
    await widgetTester.pumpWidget(
      MaterialApp(
        home: PostContactFeedbackScreen(
          postContactFeedbackController: controller,
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
    expect(find.text('Pós-contato'), findsOneWidget);
    expect(find.text('Como foi o contato?'), findsOneWidget);
    expect(find.text('Conseguiu falar?'), findsOneWidget);
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
    await widgetTester.tap(find.text('Consegui falar'));
    await widgetTester.tap(find.text('Respondeu rápido'));
    await widgetTester.tap(find.text('Serviço realizado'));
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
}
