class CitySelectionCity {
  const CitySelectionCity({
    required this.cityIdentifier,
    required this.cityName,
    required this.stateCode,
  });

  final String cityIdentifier;
  final String cityName;
  final String stateCode;

  String get displayName => '$cityName - $stateCode';
}
