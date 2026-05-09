import 'package:flutter_test/flutter_test.dart';
import 'package:worklink_mobile/features/professional_profile/professional_profile_review.dart';

void main() {
  test(
      'GIVEN resumo com avaliacoes WHEN formatar THEN deve exibir media e quantidade',
      () {
    // GIVEN
    const reviewSummary = ProfessionalProfileReviewSummary(
      averageRating: 4.5,
      reviewCount: 2,
    );

    // WHEN / THEN
    expect(reviewSummary.hasReviews, isTrue);
    expect(reviewSummary.averageRatingLabel, '4.5');
    expect(reviewSummary.reviewCountLabel, '2 avaliações');
  });

  test('GIVEN comentario vazio WHEN consultar THEN deve indicar ausencia', () {
    // GIVEN
    const reviewComment = ProfessionalProfileReviewComment(
      professionalReviewIdentifier: 'review-1',
      starRating: 5,
      publicAuthorDisplayName: 'Usuario anonimo',
      comment: '   ',
    );

    // WHEN / THEN
    expect(reviewComment.hasComment, isFalse);
  });
}
