// ignore_for_file: sort_constructors_first

class ServiceCategory {
  const ServiceCategory({
    required this.categoryIdentifier,
    required this.categoryName,
    required this.categorySlug,
  });

  final String categoryIdentifier;
  final String categoryName;
  final String categorySlug;

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      categoryIdentifier: json['categoryIdentifier']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      categorySlug: json['categorySlug']?.toString() ?? '',
    );
  }
}

class ServiceCity {
  const ServiceCity({
    required this.cityIdentifier,
    required this.cityName,
    required this.stateCode,
    required this.citySlug,
  });

  final String cityIdentifier;
  final String cityName;
  final String stateCode;
  final String citySlug;

  String get displayName => '$cityName - $stateCode';

  factory ServiceCity.fromJson(Map<String, dynamic> json) {
    return ServiceCity(
      cityIdentifier: json['cityIdentifier']?.toString() ?? '',
      cityName: json['cityName']?.toString() ?? '',
      stateCode: json['stateCode']?.toString() ?? '',
      citySlug: json['citySlug']?.toString() ?? '',
    );
  }
}
