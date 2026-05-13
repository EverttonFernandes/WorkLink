// ignore_for_file: sort_constructors_first

class ProfessionalReviewProfile {
  const ProfessionalReviewProfile({
    required this.professionalIdentifier,
    required this.summary,
    required this.reviews,
  });

  final String professionalIdentifier;
  final ProfessionalReviewSummary summary;
  final List<ProfessionalReview> reviews;

  factory ProfessionalReviewProfile.fromJson(Map<String, dynamic> json) {
    final reviews = json['reviews'] as List<dynamic>? ?? const [];
    return ProfessionalReviewProfile(
      professionalIdentifier: json['professionalIdentifier']?.toString() ?? '',
      summary: ProfessionalReviewSummary.fromJson(
        Map<String, dynamic>.from(json['summary'] as Map? ?? const {}),
      ),
      reviews: reviews
          .map(
            (reviewJson) => ProfessionalReview.fromJson(
              Map<String, dynamic>.from(reviewJson as Map),
            ),
          )
          .toList(),
    );
  }
}

class ProfessionalReviewSummary {
  const ProfessionalReviewSummary({
    required this.averageRating,
    required this.reviewCount,
    required this.hasReviews,
  });

  final double averageRating;
  final int reviewCount;
  final bool hasReviews;

  factory ProfessionalReviewSummary.fromJson(Map<String, dynamic> json) {
    return ProfessionalReviewSummary(
      averageRating:
          double.tryParse(json['averageRating']?.toString() ?? '') ?? 0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      hasReviews: json['hasReviews'] == true,
    );
  }
}

class ProfessionalReview {
  const ProfessionalReview({
    required this.professionalReviewIdentifier,
    required this.starRating,
    required this.comment,
    required this.anonymousToPublic,
    this.publicAuthorIdentifier,
    this.publicAuthorDisplayName,
    required this.createdAt,
    this.contactIntentIdentifier,
    this.professionalIdentifier,
  });

  final String professionalReviewIdentifier;
  final int starRating;
  final String comment;
  final bool anonymousToPublic;
  final String? publicAuthorIdentifier;
  final String? publicAuthorDisplayName;
  final DateTime createdAt;
  final String? contactIntentIdentifier;
  final String? professionalIdentifier;

  factory ProfessionalReview.fromJson(Map<String, dynamic> json) {
    return ProfessionalReview(
      professionalReviewIdentifier:
          json['professionalReviewIdentifier']?.toString() ?? '',
      starRating: json['starRating'] as int? ?? 0,
      comment: json['comment']?.toString() ?? '',
      anonymousToPublic: json['anonymousToPublic'] != false,
      publicAuthorIdentifier: json['publicAuthorIdentifier']?.toString(),
      publicAuthorDisplayName: json['publicAuthorDisplayName']?.toString(),
      createdAt: DateTime.parse(json['createdAt'].toString()),
      contactIntentIdentifier: json['contactIntentIdentifier']?.toString(),
      professionalIdentifier: json['professionalIdentifier']?.toString(),
    );
  }
}

class RegisterProfessionalReviewRequest {
  const RegisterProfessionalReviewRequest({
    required this.contactIntentIdentifier,
    required this.starRating,
    required this.comment,
    required this.anonymousToPublic,
  });

  final String contactIntentIdentifier;
  final int starRating;
  final String comment;
  final bool anonymousToPublic;

  Map<String, Object?> toJson() {
    return {
      'contactIntentIdentifier': contactIntentIdentifier,
      'starRating': starRating,
      'comment': comment.trim().isEmpty ? null : comment.trim(),
      'anonymousToPublic': anonymousToPublic,
    };
  }
}

class ReviewAnalysisRequest {
  const ReviewAnalysisRequest({
    required this.reviewAnalysisRequestIdentifier,
    required this.professionalReviewIdentifier,
    required this.professionalIdentifier,
    required this.requestedByProfessionalIdentifier,
    required this.reason,
    required this.createdAt,
  });

  final String reviewAnalysisRequestIdentifier;
  final String professionalReviewIdentifier;
  final String professionalIdentifier;
  final String requestedByProfessionalIdentifier;
  final String reason;
  final DateTime createdAt;

  factory ReviewAnalysisRequest.fromJson(Map<String, dynamic> json) {
    return ReviewAnalysisRequest(
      reviewAnalysisRequestIdentifier:
          json['reviewAnalysisRequestIdentifier']?.toString() ?? '',
      professionalReviewIdentifier:
          json['professionalReviewIdentifier']?.toString() ?? '',
      professionalIdentifier: json['professionalIdentifier']?.toString() ?? '',
      requestedByProfessionalIdentifier:
          json['requestedByProfessionalIdentifier']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      createdAt: DateTime.parse(json['createdAt'].toString()),
    );
  }
}

class ReviewValidation {
  static const int minRating = 1;
  static const int maxRating = 5;
  static const int maxCommentLength = 1000;

  static String? validateRating(int rating) {
    if (rating < minRating || rating > maxRating) {
      return 'Classificacao deve estar entre $minRating e $maxRating.';
    }
    return null;
  }

  static String? validateComment(String comment) {
    if (comment.trim().length > maxCommentLength) {
      return 'Comentario nao pode ter mais de $maxCommentLength caracteres.';
    }
    return null;
  }

  static bool isValid(int rating, String comment) {
    return validateRating(rating) == null && validateComment(comment) == null;
  }
}
