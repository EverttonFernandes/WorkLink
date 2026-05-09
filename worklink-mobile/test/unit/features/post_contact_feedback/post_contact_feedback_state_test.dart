import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/post_contact_feedback/post_contact_feedback_state.dart';

void main() {
  test(
      'GIVEN feedback incompleto WHEN consultar envio THEN deve bloquear submissao',
      () {
    // GIVEN
    const feedbackState = PostContactFeedbackState(
      conversationOutcome:
          PostContactConversationOutcome.customerReachedProfessional,
      contactResponsiveness: PostContactResponsiveness.fastResponse,
    );

    // WHEN
    final canSubmitFeedback = feedbackState.canSubmit;

    // THEN
    expect(canSubmitFeedback, isFalse);
  });

  test(
      'GIVEN feedback completo WHEN consultar envio THEN deve permitir submissao',
      () {
    // GIVEN
    const feedbackState = PostContactFeedbackState(
      conversationOutcome:
          PostContactConversationOutcome.customerReachedProfessional,
      contactResponsiveness: PostContactResponsiveness.fastResponse,
      serviceExecutionOutcome:
          PostContactServiceExecutionOutcome.servicePerformed,
    );

    // WHEN
    final canSubmitFeedback = feedbackState.canSubmit;

    // THEN
    expect(canSubmitFeedback, isTrue);
  });

  test('GIVEN mensagem de erro WHEN consultar estado THEN deve indicar falha',
      () {
    // GIVEN
    const feedbackState = PostContactFeedbackState(
      errorMessage: 'Responda todas as perguntas para enviar.',
    );

    // WHEN
    final hasError = feedbackState.hasError;

    // THEN
    expect(hasError, isTrue);
  });
}
