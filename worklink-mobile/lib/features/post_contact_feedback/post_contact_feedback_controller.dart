import 'package:flutter/foundation.dart';

import 'post_contact_feedback_state.dart';

typedef SubmitPostContactFeedback = Future<void> Function(
  String contactIntentionIdentifier,
  PostContactFeedbackState feedbackState,
);

class PostContactFeedbackController extends ChangeNotifier {
  PostContactFeedbackController({
    required this.contactIntentionIdentifier,
    required this.submitPostContactFeedback,
  });

  final String contactIntentionIdentifier;
  final SubmitPostContactFeedback submitPostContactFeedback;

  PostContactFeedbackState _state = const PostContactFeedbackState();

  PostContactFeedbackState get state => _state;

  void selectConversationOutcome(
    PostContactConversationOutcome conversationOutcome,
  ) {
    _updateState(
      _state.copyWith(
        conversationOutcome: conversationOutcome,
        clearErrorMessage: true,
      ),
    );
  }

  void selectContactResponsiveness(
    PostContactResponsiveness contactResponsiveness,
  ) {
    _updateState(
      _state.copyWith(
        contactResponsiveness: contactResponsiveness,
        clearErrorMessage: true,
      ),
    );
  }

  void selectServiceExecutionOutcome(
    PostContactServiceExecutionOutcome serviceExecutionOutcome,
  ) {
    _updateState(
      _state.copyWith(
        serviceExecutionOutcome: serviceExecutionOutcome,
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> submitFeedback() async {
    if (!_state.canSubmit) {
      _updateState(
        _state.copyWith(
          errorMessage: 'Responda todas as perguntas para enviar.',
        ),
      );
      return;
    }
    await submitPostContactFeedback(contactIntentionIdentifier, _state);
    _updateState(_state.copyWith(submitted: true, clearErrorMessage: true));
  }

  void _updateState(PostContactFeedbackState nextState) {
    _state = nextState;
    notifyListeners();
  }
}
