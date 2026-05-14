class PostContactFeedbackRequest {
  const PostContactFeedbackRequest({
    required this.contactIntentionIdentifier,
    required this.professionalIdentifier,
    required this.professionalName,
    required this.contactCreatedAt,
  });

  final String contactIntentionIdentifier;
  final String professionalIdentifier;
  final String professionalName;
  final DateTime contactCreatedAt;
}
