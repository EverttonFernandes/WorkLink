class ProfessionalReviewState {
  const ProfessionalReviewState({
    this.starRating,
    this.comment = '',
    this.anonymousToPublic = true,
    this.submitted = false,
    this.errorMessage,
  });

  final int? starRating;
  final String comment;
  final bool anonymousToPublic;
  final bool submitted;
  final String? errorMessage;

  String get normalizedComment => comment.trim();

  bool get hasComment => normalizedComment.isNotEmpty;

  bool get canSubmit =>
      starRating != null && starRating! >= 1 && starRating! <= 5;

  bool get hasError => errorMessage != null && errorMessage!.trim().isNotEmpty;

  ProfessionalReviewState copyWith({
    int? starRating,
    String? comment,
    bool? anonymousToPublic,
    bool? submitted,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ProfessionalReviewState(
      starRating: starRating ?? this.starRating,
      comment: comment ?? this.comment,
      anonymousToPublic: anonymousToPublic ?? this.anonymousToPublic,
      submitted: submitted ?? this.submitted,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}
