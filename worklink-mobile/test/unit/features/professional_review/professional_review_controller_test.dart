import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/professional_review/professional_review_controller.dart';
import 'package:worklink_mobile/features/professional_review/professional_review_state.dart';

void main() {
  test(
      'GIVEN avaliacao sem nota WHEN enviar THEN deve exibir erro e nao chamar submissao',
      () async {
    // GIVEN
    var submitAttempts = 0;
    final controller = ProfessionalReviewController(
      contactIntentionIdentifier: 'contact-intention-1',
      submitProfessionalReview: (_, __) async {
        submitAttempts++;
      },
    );

    // WHEN
    await controller.submitReview();

    // THEN
    expect(submitAttempts, 0);
    expect(controller.state.errorMessage, 'Informe uma nota para enviar.');
    expect(controller.state.submitted, isFalse);
  });

  test(
      'GIVEN avaliacao anonima com nota WHEN enviar THEN deve submeter autoria publica oculta',
      () async {
    // GIVEN
    String? submittedContactIntentionIdentifier;
    ProfessionalReviewState? submittedReviewState;
    final controller = ProfessionalReviewController(
      contactIntentionIdentifier: 'contact-intention-1',
      submitProfessionalReview: (contactIntentionIdentifier, reviewState) {
        submittedContactIntentionIdentifier = contactIntentionIdentifier;
        submittedReviewState = reviewState;
        return Future<void>.value();
      },
    );

    // WHEN
    controller.selectStarRating(5);
    controller.changeComment('Servico excelente.');
    await controller.submitReview();

    // THEN
    expect(submittedContactIntentionIdentifier, 'contact-intention-1');
    expect(submittedReviewState?.starRating, 5);
    expect(submittedReviewState?.normalizedComment, 'Servico excelente.');
    expect(submittedReviewState?.anonymousToPublic, isTrue);
    expect(controller.state.submitted, isTrue);
    expect(controller.state.hasError, isFalse);
  });

  test(
      'GIVEN avaliacao identificada WHEN enviar THEN deve submeter autoria publica permitida',
      () async {
    // GIVEN
    ProfessionalReviewState? submittedReviewState;
    final controller = ProfessionalReviewController(
      contactIntentionIdentifier: 'contact-intention-2',
      submitProfessionalReview: (_, reviewState) {
        submittedReviewState = reviewState;
        return Future<void>.value();
      },
    );

    // WHEN
    controller.selectStarRating(4);
    controller.toggleAnonymousToPublic(false);
    await controller.submitReview();

    // THEN
    expect(submittedReviewState?.starRating, 4);
    expect(submittedReviewState?.anonymousToPublic, isFalse);
    expect(controller.state.submitted, isTrue);
  });
}
