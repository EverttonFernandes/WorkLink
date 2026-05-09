import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/professional_review/professional_review_state.dart';

void main() {
  test(
      'GIVEN avaliacao sem nota WHEN consultar envio THEN deve bloquear submissao',
      () {
    // GIVEN
    const reviewState = ProfessionalReviewState(comment: 'Bom atendimento.');

    // WHEN
    final canSubmitReview = reviewState.canSubmit;

    // THEN
    expect(canSubmitReview, isFalse);
  });

  test(
      'GIVEN avaliacao com nota valida WHEN consultar envio THEN deve permitir submissao',
      () {
    // GIVEN
    const reviewState = ProfessionalReviewState(starRating: 5);

    // WHEN
    final canSubmitReview = reviewState.canSubmit;

    // THEN
    expect(canSubmitReview, isTrue);
  });

  test(
      'GIVEN comentario com espacos WHEN normalizar THEN deve preservar apenas texto util',
      () {
    // GIVEN
    const reviewState = ProfessionalReviewState(
      starRating: 4,
      comment: '  Atendimento dentro do combinado.  ',
    );

    // WHEN
    final normalizedComment = reviewState.normalizedComment;

    // THEN
    expect(normalizedComment, 'Atendimento dentro do combinado.');
    expect(reviewState.hasComment, isTrue);
  });
}
