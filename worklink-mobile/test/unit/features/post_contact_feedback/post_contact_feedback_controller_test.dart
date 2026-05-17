import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/post_contact_feedback/post_contact_feedback_controller.dart';
import 'package:worklink_mobile/features/post_contact_feedback/post_contact_feedback_state.dart';

void main() {
  test(
      'GIVEN feedback incompleto WHEN enviar THEN deve exibir erro e nao chamar submissao',
      () async {
    // GIVEN
    var submitAttempts = 0;
    final controller = PostContactFeedbackController(
      contactIntentionIdentifier: 'contact-intention-1',
      submitPostContactFeedback: (_, __) async {
        submitAttempts++;
      },
    );

    // WHEN
    await controller.submitFeedback();

    // THEN
    expect(submitAttempts, 0);
    expect(
      controller.state.errorMessage,
      'Responda todas as perguntas para enviar.',
    );
    expect(controller.state.submitted, isFalse);
  });

  test(
      'GIVEN contato respondido WHEN enviar feedback THEN deve submeter respostas estruturadas',
      () async {
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

    // WHEN
    controller.selectConversationOutcome(
      PostContactConversationOutcome.customerReachedProfessional,
    );
    controller.selectContactResponsiveness(
      PostContactResponsiveness.fastResponse,
    );
    controller.selectServiceExecutionOutcome(
      PostContactServiceExecutionOutcome.servicePerformed,
    );
    await controller.submitFeedback();

    // THEN
    expect(submittedContactIntentionIdentifier, 'contact-intention-1');
    expect(
      submittedFeedbackState?.conversationOutcome,
      PostContactConversationOutcome.customerReachedProfessional,
    );
    expect(
      submittedFeedbackState?.contactResponsiveness,
      PostContactResponsiveness.fastResponse,
    );
    expect(
      submittedFeedbackState?.serviceExecutionOutcome,
      PostContactServiceExecutionOutcome.servicePerformed,
    );
    expect(controller.state.submitted, isTrue);
    expect(controller.state.hasError, isFalse);
  });

  test(
      'GIVEN contato sem resposta WHEN enviar feedback THEN deve submeter ausencia de resposta e servico',
      () async {
    // GIVEN
    PostContactFeedbackState? submittedFeedbackState;
    final controller = PostContactFeedbackController(
      contactIntentionIdentifier: 'contact-intention-2',
      submitPostContactFeedback: (_, feedbackState) {
        submittedFeedbackState = feedbackState;
        return Future<void>.value();
      },
    );

    // WHEN
    controller.selectConversationOutcome(
      PostContactConversationOutcome.customerDidNotReachProfessional,
    );
    controller
        .selectContactResponsiveness(PostContactResponsiveness.noResponse);
    controller.selectServiceExecutionOutcome(
      PostContactServiceExecutionOutcome.serviceNotPerformed,
    );
    await controller.submitFeedback();

    // THEN
    expect(
      submittedFeedbackState?.conversationOutcome,
      PostContactConversationOutcome.customerDidNotReachProfessional,
    );
    expect(
      submittedFeedbackState?.contactResponsiveness,
      PostContactResponsiveness.noResponse,
    );
    expect(
      submittedFeedbackState?.serviceExecutionOutcome,
      PostContactServiceExecutionOutcome.serviceNotPerformed,
    );
    expect(controller.state.submitted, isTrue);
  });
}
