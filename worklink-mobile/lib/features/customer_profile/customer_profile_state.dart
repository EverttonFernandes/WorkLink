class CustomerProfileCity {
  const CustomerProfileCity({
    required this.cityName,
    required this.stateCode,
  });

  final String cityName;
  final String stateCode;

  String get displayName => '$cityName - $stateCode';
}

class CustomerSavedProfessional {
  const CustomerSavedProfessional({
    required this.professionalIdentifier,
    required this.professionalName,
    required this.categoryName,
    required this.cityDisplayName,
  });

  final String professionalIdentifier;
  final String professionalName;
  final String categoryName;
  final String cityDisplayName;

  String get subtitle => '$categoryName - $cityDisplayName';
}

class CustomerSubmittedReview {
  const CustomerSubmittedReview({
    required this.professionalName,
    required this.starRating,
    required this.publiclyAnonymous,
    this.comment = '',
  });

  final String professionalName;
  final int starRating;
  final bool publiclyAnonymous;
  final String comment;

  String get ratingLabel => '$starRating de 5';

  bool get hasComment => comment.trim().isNotEmpty;

  String get publicVisibilityLabel =>
      publiclyAnonymous ? 'Anonima publicamente' : 'Identificada publicamente';
}

class CustomerProfileState {
  const CustomerProfileState({
    required this.customerName,
    required this.phoneNumber,
    this.mainCity,
    this.selectedCities = const [],
    this.savedProfessionals = const [],
    this.submittedReviews = const [],
    this.whatsappNotificationsEnabled = true,
    this.profilePersonalizationEnabled = true,
    this.loggedOut = false,
  });

  final String customerName;
  final String phoneNumber;
  final CustomerProfileCity? mainCity;
  final List<CustomerProfileCity> selectedCities;
  final List<CustomerSavedProfessional> savedProfessionals;
  final List<CustomerSubmittedReview> submittedReviews;
  final bool whatsappNotificationsEnabled;
  final bool profilePersonalizationEnabled;
  final bool loggedOut;

  String get mainCityDisplayName => mainCity?.displayName ?? 'Cidade principal pendente';

  bool get hasSelectedCities => selectedCities.isNotEmpty;

  bool get hasSavedProfessionals => savedProfessionals.isNotEmpty;

  bool get hasSubmittedReviews => submittedReviews.isNotEmpty;

  CustomerProfileState copyWith({
    CustomerProfileCity? mainCity,
    List<CustomerProfileCity>? selectedCities,
    List<CustomerSavedProfessional>? savedProfessionals,
    List<CustomerSubmittedReview>? submittedReviews,
    bool? whatsappNotificationsEnabled,
    bool? profilePersonalizationEnabled,
    bool? loggedOut,
  }) {
    return CustomerProfileState(
      customerName: customerName,
      phoneNumber: phoneNumber,
      mainCity: mainCity ?? this.mainCity,
      selectedCities: selectedCities ?? this.selectedCities,
      savedProfessionals: savedProfessionals ?? this.savedProfessionals,
      submittedReviews: submittedReviews ?? this.submittedReviews,
      whatsappNotificationsEnabled:
          whatsappNotificationsEnabled ?? this.whatsappNotificationsEnabled,
      profilePersonalizationEnabled:
          profilePersonalizationEnabled ?? this.profilePersonalizationEnabled,
      loggedOut: loggedOut ?? this.loggedOut,
    );
  }
}
