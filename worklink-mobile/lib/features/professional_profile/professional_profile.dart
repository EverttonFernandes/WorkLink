import '../professional_availability/professional_availability_status.dart';
import 'professional_profile_review.dart';

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
    this.profileCompletenessPercentage = 50,
    this.phoneNumberVerified = false,
    this.documentProvided = false,
    this.availabilityStatus =
        ProfessionalAvailabilityStatus.acceptingNewClients,
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
  final int profileCompletenessPercentage;
  final bool phoneNumberVerified;
  final bool documentProvided;
  final ProfessionalAvailabilityStatus availabilityStatus;
  final ProfessionalProfileReviewSummary? reviewSummary;

  String get baseCityDisplayName => '$baseCityName - $baseStateCode';

  String get attendedCitiesSummary => attendedCityNames.join(', ');

  bool get hasAttendedCities => attendedCityNames.isNotEmpty;

  bool get hasAboutDescription => aboutDescription.trim().isNotEmpty;

  bool get hasServiceNames => serviceNames.isNotEmpty;

  bool get hasUsefulLinks => usefulLinks.isNotEmpty;

  bool get hasPortfolioItems => portfolioItemDescriptions.isNotEmpty;

  String get availabilityLabel => availabilityStatus.badgeLabel;

  bool get hasAvailability => availabilityLabel.trim().isNotEmpty;

  bool get hasReviewSummary => reviewSummary != null;

  List<String> get visibleProfileBadgeLabels {
    return [
      if (profileCompletenessPercentage >= 100)
        'Perfil completo'
      else
        'Perfil básico',
      if (phoneNumberVerified) 'Telefone verificado',
      if (documentProvided) 'Documento informado',
      ...profileBadgeLabels,
    ]
        .map((profileBadgeLabel) => profileBadgeLabel.trim())
        .where((profileBadgeLabel) => profileBadgeLabel.isNotEmpty)
        .toSet()
        .toList();
  }
}
