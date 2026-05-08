import 'package:flutter/foundation.dart';

import 'discovery_filter_state.dart';
import 'discovery_professional.dart';

class DiscoveryController extends ChangeNotifier {
  DiscoveryController({
    required List<DiscoveryProfessional> availableProfessionals,
  }) : _state = DiscoveryFilterState(
          availableProfessionals: availableProfessionals,
        );

  DiscoveryFilterState _state;

  DiscoveryFilterState get state => _state;

  void selectCategory(String? categoryName) {
    _state = _state.copyWith(
      selectedCategoryName: categoryName,
      clearCategory: categoryName == null,
    );
    notifyListeners();
  }

  void selectCity(String? cityDisplayName) {
    _state = _state.copyWith(
      selectedCityDisplayName: cityDisplayName,
      clearCity: cityDisplayName == null,
    );
    notifyListeners();
  }

  void searchByKeyword(String keyword) {
    _state = _state.copyWith(keyword: keyword);
    notifyListeners();
  }

  void clearFilters() {
    _state = DiscoveryFilterState(
      availableProfessionals: _state.availableProfessionals,
    );
    notifyListeners();
  }
}
