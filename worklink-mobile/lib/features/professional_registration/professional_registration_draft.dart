class ProfessionalRegistrationDraft {
  const ProfessionalRegistrationDraft({
    this.professionalName = '',
    this.documentNumber = '',
    this.categoryName,
    this.cityDisplayName,
    this.whatsappNumber = '',
    this.shortDescription = '',
    this.instagramProfile = '',
    this.usefulLink = '',
    this.hasProfilePhoto = false,
  });

  final String professionalName;
  final String documentNumber;
  final String? categoryName;
  final String? cityDisplayName;
  final String whatsappNumber;
  final String shortDescription;
  final String instagramProfile;
  final String usefulLink;
  final bool hasProfilePhoto;

  bool get hasMinimumRequiredFields {
    return professionalName.trim().isNotEmpty &&
        categoryName != null &&
        cityDisplayName != null &&
        whatsappNumber.trim().isNotEmpty &&
        shortDescription.trim().isNotEmpty;
  }

  int get profileCompletenessPercentage {
    var percentage = 0;
    if (professionalName.trim().isNotEmpty) {
      percentage += 10;
    }
    if (categoryName != null) {
      percentage += 10;
    }
    if (cityDisplayName != null) {
      percentage += 10;
    }
    if (whatsappNumber.trim().isNotEmpty) {
      percentage += 10;
    }
    if (shortDescription.trim().isNotEmpty) {
      percentage += 20;
    }
    if (hasProfilePhoto) {
      percentage += 10;
    }
    if (documentNumber.trim().isNotEmpty) {
      percentage += 10;
    }
    if (instagramProfile.trim().isNotEmpty) {
      percentage += 10;
    }
    if (usefulLink.trim().isNotEmpty) {
      percentage += 10;
    }
    return percentage;
  }

  String get stepLabel {
    if (profileCompletenessPercentage >= 80) {
      return 'Etapa 2 de 2';
    }
    return 'Etapa 1 de 2';
  }

  String get completenessLabel =>
      '$profileCompletenessPercentage% do perfil preenchido';

  ProfessionalRegistrationDraft copyWith({
    String? professionalName,
    String? documentNumber,
    String? categoryName,
    String? cityDisplayName,
    String? whatsappNumber,
    String? shortDescription,
    String? instagramProfile,
    String? usefulLink,
    bool? hasProfilePhoto,
  }) {
    return ProfessionalRegistrationDraft(
      professionalName: professionalName ?? this.professionalName,
      documentNumber: documentNumber ?? this.documentNumber,
      categoryName: categoryName ?? this.categoryName,
      cityDisplayName: cityDisplayName ?? this.cityDisplayName,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      shortDescription: shortDescription ?? this.shortDescription,
      instagramProfile: instagramProfile ?? this.instagramProfile,
      usefulLink: usefulLink ?? this.usefulLink,
      hasProfilePhoto: hasProfilePhoto ?? this.hasProfilePhoto,
    );
  }
}
