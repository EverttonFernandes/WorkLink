class ProfessionalProfile {
  const ProfessionalProfile({
    required this.professionalIdentifier,
    required this.professionalName,
    required this.categoryName,
    required this.baseCityName,
    required this.baseStateCode,
    required this.attendedCityNames,
    required this.aboutDescription,
    required this.serviceNames,
    this.profilePhotoUrl,
    this.usefulLinks = const [],
    this.portfolioItemDescriptions = const [],
    this.profileBadgeLabels = const [],
    this.availabilityLabel,
    this.reviewSummary,
  });

  final String professionalIdentifier;
  final String professionalName;
  final String categoryName;
  final String baseCityName;
  final String baseStateCode;
  final List<String> attendedCityNames;
  final String aboutDescription;
  final List<String> serviceNames;
  final String? profilePhotoUrl;
  final List<String> usefulLinks;
  final List<String> portfolioItemDescriptions;
  final List<String> profileBadgeLabels;
  final String? availabilityLabel;
  final String? reviewSummary;

  String get baseCityDisplayName => '$baseCityName - $baseStateCode';

  String get attendedCitiesSummary => attendedCityNames.join(', ');

  bool get hasAttendedCities => attendedCityNames.isNotEmpty;

  bool get hasAboutDescription => aboutDescription.trim().isNotEmpty;

  bool get hasServiceNames => serviceNames.isNotEmpty;

  bool get hasUsefulLinks => usefulLinks.isNotEmpty;

  bool get hasPortfolioItems => portfolioItemDescriptions.isNotEmpty;

  bool get hasAvailability =>
      availabilityLabel != null && availabilityLabel!.trim().isNotEmpty;

  bool get hasReviewSummary =>
      reviewSummary != null && reviewSummary!.trim().isNotEmpty;

  List<String> get visibleProfileBadgeLabels {
    return profileBadgeLabels
        .where((profileBadgeLabel) => profileBadgeLabel.trim().isNotEmpty)
        .toList();
  }
}
