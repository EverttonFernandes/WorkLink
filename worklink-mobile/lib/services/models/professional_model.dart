// ignore_for_file: sort_constructors_first

class ProfessionalSummary {
  const ProfessionalSummary({
    required this.professionalIdentifier,
    required this.professionalName,
    required this.cityIdentifier,
    required this.categoryIdentifier,
    required this.shortDescription,
    this.profilePhotoFileIdentifier,
    this.availabilityStatus = '',
    this.availabilityBadgeLabel = '',
    this.availabilityReducesListingHighlight = false,
    this.phoneNumberVerified = false,
    this.qualityGuarantee = false,
  });

  final String professionalIdentifier;
  final String professionalName;
  final String cityIdentifier;
  final String categoryIdentifier;
  final String shortDescription;
  final String? profilePhotoFileIdentifier;
  final String availabilityStatus;
  final String availabilityBadgeLabel;
  final bool availabilityReducesListingHighlight;
  final bool phoneNumberVerified;
  final bool qualityGuarantee;

  factory ProfessionalSummary.fromJson(Map<String, dynamic> json) {
    return ProfessionalSummary(
      professionalIdentifier: json['professionalIdentifier']?.toString() ?? '',
      professionalName: json['professionalName']?.toString() ?? '',
      cityIdentifier: json['cityIdentifier']?.toString() ?? '',
      categoryIdentifier: json['categoryIdentifier']?.toString() ?? '',
      shortDescription: json['shortDescription']?.toString() ?? '',
      profilePhotoFileIdentifier:
          json['profilePhotoFileIdentifier']?.toString(),
      availabilityStatus: json['availabilityStatus']?.toString() ?? '',
      availabilityBadgeLabel: json['availabilityBadgeLabel']?.toString() ?? '',
      availabilityReducesListingHighlight:
          json['availabilityReducesListingHighlight'] == true,
      phoneNumberVerified: json['phoneNumberVerified'] == true,
      qualityGuarantee: json['qualityGuarantee'] == true,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'professionalIdentifier': professionalIdentifier,
      'professionalName': professionalName,
      'cityIdentifier': cityIdentifier,
      'categoryIdentifier': categoryIdentifier,
      'shortDescription': shortDescription,
      'profilePhotoFileIdentifier': profilePhotoFileIdentifier,
      'availabilityStatus': availabilityStatus,
      'availabilityBadgeLabel': availabilityBadgeLabel,
      'availabilityReducesListingHighlight':
          availabilityReducesListingHighlight,
      'phoneNumberVerified': phoneNumberVerified,
      'qualityGuarantee': qualityGuarantee,
    };
  }
}

class Professional {
  const Professional({
    required this.professionalIdentifier,
    required this.professionalName,
    required this.whatsappNumber,
    required this.cityIdentifier,
    required this.categoryIdentifier,
    required this.shortDescription,
    this.profilePhotoFileIdentifier,
    this.documentProvided = false,
    this.usefulLink,
    this.portfolioDescription,
    this.serviceDescription,
    this.profileCompletenessPercentage = 0,
    this.profileClassification = '',
    this.availabilityStatus = '',
    this.availabilityBadgeLabel = '',
    this.availabilityReducesListingHighlight = false,
    this.phoneNumberVerified = false,
    this.qualityGuarantee = false,
  });

  final String professionalIdentifier;
  final String professionalName;
  final String whatsappNumber;
  final String cityIdentifier;
  final String categoryIdentifier;
  final String shortDescription;
  final String? profilePhotoFileIdentifier;
  final bool documentProvided;
  final String? usefulLink;
  final String? portfolioDescription;
  final String? serviceDescription;
  final int profileCompletenessPercentage;
  final String profileClassification;
  final String availabilityStatus;
  final String availabilityBadgeLabel;
  final bool availabilityReducesListingHighlight;
  final bool phoneNumberVerified;
  final bool qualityGuarantee;

  factory Professional.fromJson(Map<String, dynamic> json) {
    return Professional(
      professionalIdentifier: json['professionalIdentifier']?.toString() ?? '',
      professionalName: json['professionalName']?.toString() ?? '',
      whatsappNumber: json['whatsappNumber']?.toString() ?? '',
      cityIdentifier: json['cityIdentifier']?.toString() ?? '',
      categoryIdentifier: json['categoryIdentifier']?.toString() ?? '',
      shortDescription: json['shortDescription']?.toString() ?? '',
      profilePhotoFileIdentifier:
          json['profilePhotoFileIdentifier']?.toString(),
      documentProvided: json['documentProvided'] == true,
      usefulLink: json['usefulLink']?.toString(),
      portfolioDescription: json['portfolioDescription']?.toString(),
      serviceDescription: json['serviceDescription']?.toString(),
      profileCompletenessPercentage:
          json['profileCompletenessPercentage'] as int? ?? 0,
      profileClassification: json['profileClassification']?.toString() ?? '',
      availabilityStatus: json['availabilityStatus']?.toString() ?? '',
      availabilityBadgeLabel: json['availabilityBadgeLabel']?.toString() ?? '',
      availabilityReducesListingHighlight:
          json['availabilityReducesListingHighlight'] == true,
      phoneNumberVerified: json['phoneNumberVerified'] == true,
      qualityGuarantee: json['qualityGuarantee'] == true,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'professionalIdentifier': professionalIdentifier,
      'professionalName': professionalName,
      'whatsappNumber': whatsappNumber,
      'cityIdentifier': cityIdentifier,
      'categoryIdentifier': categoryIdentifier,
      'shortDescription': shortDescription,
      'profilePhotoFileIdentifier': profilePhotoFileIdentifier,
      'documentProvided': documentProvided,
      'usefulLink': usefulLink,
      'portfolioDescription': portfolioDescription,
      'serviceDescription': serviceDescription,
      'profileCompletenessPercentage': profileCompletenessPercentage,
      'profileClassification': profileClassification,
      'availabilityStatus': availabilityStatus,
      'availabilityBadgeLabel': availabilityBadgeLabel,
      'availabilityReducesListingHighlight':
          availabilityReducesListingHighlight,
      'phoneNumberVerified': phoneNumberVerified,
      'qualityGuarantee': qualityGuarantee,
    };
  }
}

class RegisterBasicProfessionalRequest {
  const RegisterBasicProfessionalRequest({
    required this.professionalName,
    required this.whatsappNumber,
    required this.cityIdentifier,
    required this.categoryIdentifier,
    required this.shortDescription,
  });

  final String professionalName;
  final String whatsappNumber;
  final String cityIdentifier;
  final String categoryIdentifier;
  final String shortDescription;

  Map<String, Object?> toJson() {
    return {
      'professionalName': professionalName,
      'whatsappNumber': whatsappNumber,
      'cityIdentifier': cityIdentifier,
      'categoryIdentifier': categoryIdentifier,
      'shortDescription': shortDescription,
    };
  }
}

class CompleteProfessionalProfileRequest {
  const CompleteProfessionalProfileRequest({
    this.profilePhotoFileIdentifier,
    this.documentNumber,
    this.usefulLink,
    this.portfolioDescription,
    this.serviceDescription,
    this.availabilityStatus,
  });

  final String? profilePhotoFileIdentifier;
  final String? documentNumber;
  final String? usefulLink;
  final String? portfolioDescription;
  final String? serviceDescription;
  final String? availabilityStatus;

  Map<String, Object?> toJson() {
    return {
      'profilePhotoFileIdentifier': profilePhotoFileIdentifier,
      'documentNumber': documentNumber,
      'usefulLink': usefulLink,
      'portfolioDescription': portfolioDescription,
      'serviceDescription': serviceDescription,
      'availabilityStatus': availabilityStatus,
    };
  }
}

class ProfessionalPhoneVerificationRequestResult {
  const ProfessionalPhoneVerificationRequestResult({
    required this.professionalIdentifier,
    required this.message,
    required this.expiresAt,
  });

  final String professionalIdentifier;
  final String message;
  final String expiresAt;

  factory ProfessionalPhoneVerificationRequestResult.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProfessionalPhoneVerificationRequestResult(
      professionalIdentifier: json['professionalIdentifier']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      expiresAt: json['expiresAt']?.toString() ?? '',
    );
  }
}

class ConfirmProfessionalPhoneVerificationRequest {
  const ConfirmProfessionalPhoneVerificationRequest({
    required this.verificationCode,
  });

  final String verificationCode;

  Map<String, Object?> toJson() {
    return {
      'verificationCode': verificationCode,
    };
  }
}

class ProfessionalPortfolioItem {
  const ProfessionalPortfolioItem({
    required this.portfolioItemIdentifier,
    required this.professionalIdentifier,
    required this.fileIdentifier,
    required this.title,
    required this.displayOrder,
    this.description,
  });

  final String portfolioItemIdentifier;
  final String professionalIdentifier;
  final String fileIdentifier;
  final String title;
  final String? description;
  final int displayOrder;

  factory ProfessionalPortfolioItem.fromJson(Map<String, dynamic> json) {
    return ProfessionalPortfolioItem(
      portfolioItemIdentifier:
          json['portfolioItemIdentifier']?.toString() ?? '',
      professionalIdentifier: json['professionalIdentifier']?.toString() ?? '',
      fileIdentifier: json['fileIdentifier']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      displayOrder: json['displayOrder'] as int? ?? 0,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'portfolioItemIdentifier': portfolioItemIdentifier,
      'professionalIdentifier': professionalIdentifier,
      'fileIdentifier': fileIdentifier,
      'title': title,
      'description': description,
      'displayOrder': displayOrder,
    };
  }
}

class AddProfessionalPortfolioItemRequest {
  const AddProfessionalPortfolioItemRequest({
    required this.fileIdentifier,
    required this.title,
    this.description,
    this.displayOrder = 0,
  });

  final String fileIdentifier;
  final String title;
  final String? description;
  final int displayOrder;

  Map<String, Object?> toJson() {
    return {
      'fileIdentifier': fileIdentifier,
      'title': title,
      'description': description,
      'displayOrder': displayOrder,
    };
  }
}
