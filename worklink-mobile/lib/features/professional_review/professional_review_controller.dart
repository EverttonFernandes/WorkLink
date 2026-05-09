import 'package:flutter/foundation.dart';

import 'professional_review_state.dart';

typedef SubmitProfessionalReview = Future<void> Function(
  String contactIntentionIdentifier,
  ProfessionalReviewState reviewState,
);

class ProfessionalReviewController extends ChangeNotifier {
  ProfessionalReviewController({
    required this.contactIntentionIdentifier,
    required this.submitProfessionalReview,
  });

  final String contactIntentionIdentifier;
  final SubmitProfessionalReview submitProfessionalReview;

  ProfessionalReviewState _state = const ProfessionalReviewState();

  ProfessionalReviewState get state => _state;

  void selectStarRating(int starRating) {
    _updateState(
      _state.copyWith(
        starRating: starRating,
        clearErrorMessage: true,
      ),
    );
  }

  void changeComment(String comment) {
    _updateState(
      _state.copyWith(
        comment: comment,
        clearErrorMessage: true,
      ),
    );
  }

  void toggleAnonymousToPublic(bool anonymousToPublic) {
    _updateState(
      _state.copyWith(
        anonymousToPublic: anonymousToPublic,
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> submitReview() async {
    if (!_state.canSubmit) {
      _updateState(
        _state.copyWith(errorMessage: 'Informe uma nota para enviar.'),
      );
      return;
    }

    await submitProfessionalReview(contactIntentionIdentifier, _state);
    _updateState(_state.copyWith(submitted: true, clearErrorMessage: true));
  }

  void _updateState(ProfessionalReviewState nextState) {
    _state = nextState;
    notifyListeners();
  }
}
