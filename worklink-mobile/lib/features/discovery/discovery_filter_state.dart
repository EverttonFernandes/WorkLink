import 'discovery_professional.dart';

class DiscoveryFilterState {
  const DiscoveryFilterState({
    required this.availableProfessionals,
    this.selectedCategoryName,
    this.selectedCityDisplayName,
    this.keyword = '',
  });

  final List<DiscoveryProfessional> availableProfessionals;
  final String? selectedCategoryName;
  final String? selectedCityDisplayName;
  final String keyword;

  List<String> get availableCategoryNames {
    return availableProfessionals.map((professional) => professional.categoryName).toSet().toList()..sort();
  }

  List<String> get availableCityDisplayNames {
    return availableProfessionals.map((professional) => professional.cityDisplayName).toSet().toList()..sort();
  }

  List<DiscoveryProfessional> get filteredProfessionals {
    return availableProfessionals
        .where((professional) => professional.matchesCategory(selectedCategoryName))
        .where((professional) => professional.matchesCity(selectedCityDisplayName))
        .where((professional) => professional.matchesKeyword(keyword))
        .toList();
  }

  bool get hasActiveFilters {
    return selectedCategoryName != null || selectedCityDisplayName != null || keyword.trim().isNotEmpty;
  }

  DiscoveryFilterState copyWith({
    List<DiscoveryProfessional>? availableProfessionals,
    String? selectedCategoryName,
    String? selectedCityDisplayName,
    String? keyword,
    bool clearCategory = false,
    bool clearCity = false,
  }) {
    return DiscoveryFilterState(
      availableProfessionals: availableProfessionals ?? this.availableProfessionals,
      selectedCategoryName: clearCategory ? null : selectedCategoryName ?? this.selectedCategoryName,
      selectedCityDisplayName: clearCity ? null : selectedCityDisplayName ?? this.selectedCityDisplayName,
      keyword: keyword ?? this.keyword,
    );
  }
}
