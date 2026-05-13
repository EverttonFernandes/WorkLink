// ignore_for_file: sort_constructors_first

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
