class CustomerProfileCity {
  const CustomerProfileCity({
    required this.cityIdentifier,
    required this.cityName,
    required this.stateCode,
  });

  factory CustomerProfileCity.fromJson(Map<String, dynamic> json) {
    return CustomerProfileCity(
      cityIdentifier: json['cityIdentifier']?.toString() ?? '',
      cityName: json['cityName']?.toString() ?? '',
      stateCode: json['stateCode']?.toString() ?? '',
    );
  }

  final String cityIdentifier;
  final String cityName;
  final String stateCode;
}

class CustomerSavedProfessionalModel {
  const CustomerSavedProfessionalModel({
    required this.professionalIdentifier,
    required this.professionalName,
    required this.categoryName,
    required this.city,
  });

  factory CustomerSavedProfessionalModel.fromJson(Map<String, dynamic> json) {
    return CustomerSavedProfessionalModel(
      professionalIdentifier: json['professionalIdentifier']?.toString() ?? '',
      professionalName: json['professionalName']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      city: CustomerProfileCity.fromJson(
        Map<String, dynamic>.from(json['city'] as Map? ?? const {}),
      ),
    );
  }

  final String professionalIdentifier;
  final String professionalName;
  final String categoryName;
  final CustomerProfileCity city;
}

class CustomerSubmittedReviewModel {
  const CustomerSubmittedReviewModel({
    required this.professionalReviewIdentifier,
    required this.professionalIdentifier,
    required this.professionalName,
    required this.starRating,
    required this.publiclyAnonymous,
    required this.comment,
  });

  factory CustomerSubmittedReviewModel.fromJson(Map<String, dynamic> json) {
    return CustomerSubmittedReviewModel(
      professionalReviewIdentifier:
          json['professionalReviewIdentifier']?.toString() ?? '',
      professionalIdentifier: json['professionalIdentifier']?.toString() ?? '',
      professionalName: json['professionalName']?.toString() ?? '',
      starRating: json['starRating'] as int? ?? 0,
      publiclyAnonymous: json['publiclyAnonymous'] == true,
      comment: json['comment']?.toString() ?? '',
    );
  }

  final String professionalReviewIdentifier;
  final String professionalIdentifier;
  final String professionalName;
  final int starRating;
  final bool publiclyAnonymous;
  final String comment;
}

class CustomerProfileModel {
  const CustomerProfileModel({
    required this.customerIdentifier,
    required this.customerName,
    required this.phoneNumber,
    required this.selectedCities,
    required this.savedProfessionals,
    required this.submittedReviews,
    required this.whatsappNotificationsEnabled,
    required this.profilePersonalizationEnabled,
    this.mainCity,
  });

  factory CustomerProfileModel.fromJson(Map<String, dynamic> json) {
    return CustomerProfileModel(
      customerIdentifier: json['customerIdentifier']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      mainCity: json['mainCity'] == null
          ? null
          : CustomerProfileCity.fromJson(
              Map<String, dynamic>.from(json['mainCity'] as Map),
            ),
      selectedCities: (json['selectedCities'] as List? ?? const [])
          .map(
            (dynamic cityJson) => CustomerProfileCity.fromJson(
              Map<String, dynamic>.from(cityJson as Map),
            ),
          )
          .toList(),
      savedProfessionals: (json['savedProfessionals'] as List? ?? const [])
          .map(
            (dynamic professionalJson) =>
                CustomerSavedProfessionalModel.fromJson(
              Map<String, dynamic>.from(professionalJson as Map),
            ),
          )
          .toList(),
      submittedReviews: (json['submittedReviews'] as List? ?? const [])
          .map(
            (dynamic reviewJson) => CustomerSubmittedReviewModel.fromJson(
              Map<String, dynamic>.from(reviewJson as Map),
            ),
          )
          .toList(),
      whatsappNotificationsEnabled:
          json['whatsappNotificationsEnabled'] == true,
      profilePersonalizationEnabled:
          json['profilePersonalizationEnabled'] == true,
    );
  }

  final String customerIdentifier;
  final String customerName;
  final String phoneNumber;
  final CustomerProfileCity? mainCity;
  final List<CustomerProfileCity> selectedCities;
  final List<CustomerSavedProfessionalModel> savedProfessionals;
  final List<CustomerSubmittedReviewModel> submittedReviews;
  final bool whatsappNotificationsEnabled;
  final bool profilePersonalizationEnabled;
}
