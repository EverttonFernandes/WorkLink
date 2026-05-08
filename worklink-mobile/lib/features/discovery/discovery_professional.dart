class DiscoveryProfessional {
  const DiscoveryProfessional({
    required this.professionalIdentifier,
    required this.professionalName,
    required this.categoryName,
    required this.cityName,
    required this.stateCode,
    required this.shortDescription,
    this.profilePhotoUrl,
    this.profileBadgeLabel,
    this.availabilityBadgeLabel,
    this.recentActivityLabel,
  });

  final String professionalIdentifier;
  final String professionalName;
  final String categoryName;
  final String cityName;
  final String stateCode;
  final String shortDescription;
  final String? profilePhotoUrl;
  final String? profileBadgeLabel;
  final String? availabilityBadgeLabel;
  final String? recentActivityLabel;

  String get cityDisplayName => '$cityName - $stateCode';

  List<String> get comparisonSignalLabels {
    return [
      profileBadgeLabel,
      availabilityBadgeLabel,
      recentActivityLabel,
    ]
        .where(
          (signalLabel) => signalLabel != null && signalLabel.trim().isNotEmpty,
        )
        .cast<String>()
        .toList();
  }

  bool matchesCategory(String? selectedCategoryName) {
    return selectedCategoryName == null || categoryName == selectedCategoryName;
  }

  bool matchesCity(String? selectedCityDisplayName) {
    return selectedCityDisplayName == null ||
        cityDisplayName == selectedCityDisplayName;
  }

  bool matchesKeyword(String keyword) {
    final normalizedKeyword = keyword.trim().toLowerCase();
    if (normalizedKeyword.isEmpty) {
      return true;
    }
    return professionalName.toLowerCase().contains(normalizedKeyword) ||
        shortDescription.toLowerCase().contains(normalizedKeyword);
  }
}
