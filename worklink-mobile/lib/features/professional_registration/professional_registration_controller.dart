import 'package:flutter/foundation.dart';

import 'professional_registration_draft.dart';

class ProfessionalRegistrationController extends ChangeNotifier {
  ProfessionalRegistrationController({
    ProfessionalRegistrationDraft initialDraft =
        const ProfessionalRegistrationDraft(),
  }) : _draft = initialDraft;

  ProfessionalRegistrationDraft _draft;

  ProfessionalRegistrationDraft get draft => _draft;

  void changeProfessionalName(String professionalName) {
    updateDraft(_draft.copyWith(professionalName: professionalName));
  }

  void changeDocumentNumber(String documentNumber) {
    updateDraft(_draft.copyWith(documentNumber: documentNumber));
  }

  void changeCategoryName(String? categoryName) {
    if (categoryName != null) {
      updateDraft(_draft.copyWith(categoryName: categoryName));
    }
  }

  void changeCityDisplayName(String? cityDisplayName) {
    if (cityDisplayName != null) {
      updateDraft(_draft.copyWith(cityDisplayName: cityDisplayName));
    }
  }

  void changeWhatsappNumber(String whatsappNumber) {
    updateDraft(_draft.copyWith(whatsappNumber: whatsappNumber));
  }

  void changeShortDescription(String shortDescription) {
    updateDraft(_draft.copyWith(shortDescription: shortDescription));
  }

  void changeInstagramProfile(String instagramProfile) {
    updateDraft(_draft.copyWith(instagramProfile: instagramProfile));
  }

  void changeUsefulLink(String usefulLink) {
    updateDraft(_draft.copyWith(usefulLink: usefulLink));
  }

  void toggleProfilePhoto() {
    updateDraft(_draft.copyWith(hasProfilePhoto: !_draft.hasProfilePhoto));
  }

  void updateDraft(ProfessionalRegistrationDraft draft) {
    _draft = draft;
    notifyListeners();
  }
}
