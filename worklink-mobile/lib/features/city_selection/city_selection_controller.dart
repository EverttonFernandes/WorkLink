import 'package:flutter/foundation.dart';

import 'city_selection_city.dart';
import 'city_selection_state.dart';

class CitySelectionController extends ChangeNotifier {
  CitySelectionController({
    required List<CitySelectionCity> availableCities,
    required List<CitySelectionCity> nearbySuggestedCities,
  }) : _state = CitySelectionState(
          availableCities: availableCities,
          nearbySuggestedCities: nearbySuggestedCities,
        );

  CitySelectionState _state;

  CitySelectionState get state => _state;

  void toggleCitySelection(CitySelectionCity citySelectionCity) {
    final updatedSelectedCityIdentifiers =
        Set<String>.from(_state.selectedCityIdentifiers);
    if (updatedSelectedCityIdentifiers
        .contains(citySelectionCity.cityIdentifier)) {
      updatedSelectedCityIdentifiers.remove(citySelectionCity.cityIdentifier);
    } else {
      updatedSelectedCityIdentifiers.add(citySelectionCity.cityIdentifier);
    }
    _state = _state.copyWith(
      selectedCityIdentifiers: updatedSelectedCityIdentifiers,
    );
    notifyListeners();
  }

  void clearCitySelection() {
    _state = _state.copyWith(
      selectedCityIdentifiers: <String>{},
      currentLocationEnabled: false,
    );
    notifyListeners();
  }

  void toggleCurrentLocationUsage(bool enabled) {
    _state = _state.copyWith(currentLocationEnabled: enabled);
    notifyListeners();
  }
}
