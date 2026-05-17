enum PostContactConversationOutcome {
  customerReachedProfessional,
  customerDidNotReachProfessional,
}

enum PostContactResponsiveness {
  fastResponse,
  slowResponse,
  noResponse,
}

enum PostContactServiceExecutionOutcome {
  servicePerformed,
  serviceNotPerformed,
}

class PostContactFeedbackState {
  const PostContactFeedbackState({
    this.conversationOutcome,
    this.contactResponsiveness,
    this.serviceExecutionOutcome,
    this.submitted = false,
    this.errorMessage,
  });

  final PostContactConversationOutcome? conversationOutcome;
  final PostContactResponsiveness? contactResponsiveness;
  final PostContactServiceExecutionOutcome? serviceExecutionOutcome;
  final bool submitted;
  final String? errorMessage;

  bool get canSubmit =>
      conversationOutcome != null &&
      contactResponsiveness != null &&
      serviceExecutionOutcome != null;

  bool get hasError => errorMessage != null && errorMessage!.trim().isNotEmpty;

  PostContactFeedbackState copyWith({
    PostContactConversationOutcome? conversationOutcome,
    PostContactResponsiveness? contactResponsiveness,
    PostContactServiceExecutionOutcome? serviceExecutionOutcome,
    bool? submitted,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return PostContactFeedbackState(
      conversationOutcome: conversationOutcome ?? this.conversationOutcome,
      contactResponsiveness:
          contactResponsiveness ?? this.contactResponsiveness,
      serviceExecutionOutcome:
          serviceExecutionOutcome ?? this.serviceExecutionOutcome,
      submitted: submitted ?? this.submitted,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}
