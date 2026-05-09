class ProfessionalProfileReviewSummary {
  const ProfessionalProfileReviewSummary({
    required this.averageRating,
    required this.reviewCount,
    this.comments = const [],
  });

  final double averageRating;
  final int reviewCount;
  final List<ProfessionalProfileReviewComment> comments;

  bool get hasReviews => reviewCount > 0;

  bool get hasComments => comments.isNotEmpty;

  String get averageRatingLabel => averageRating.toStringAsFixed(1);

  String get reviewCountLabel =>
      reviewCount == 1 ? '1 avaliação' : '$reviewCount avaliações';
}

class ProfessionalProfileReviewComment {
  const ProfessionalProfileReviewComment({
    required this.professionalReviewIdentifier,
    required this.starRating,
    required this.publicAuthorDisplayName,
    required this.comment,
    this.anonymousToPublic = true,
  });

  final String professionalReviewIdentifier;
  final int starRating;
  final String publicAuthorDisplayName;
  final String comment;
  final bool anonymousToPublic;

  bool get hasComment => comment.trim().isNotEmpty;
}
