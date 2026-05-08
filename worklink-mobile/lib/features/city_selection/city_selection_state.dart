import 'city_selection_city.dart';

class CitySelectionState {
  const CitySelectionState({
    required this.availableCities,
    this.selectedCityIdentifiers = const <String>{},
    this.currentLocationEnabled = false,
    this.nearbySuggestedCities = const <CitySelectionCity>[],
  });

  final List<CitySelectionCity> availableCities;
  final Set<String> selectedCityIdentifiers;
  final bool currentLocationEnabled;
  final List<CitySelectionCity> nearbySuggestedCities;

  bool isCitySelected(CitySelectionCity citySelectionCity) {
    return selectedCityIdentifiers.contains(citySelectionCity.cityIdentifier);
  }

  CitySelectionState copyWith({
    List<CitySelectionCity>? availableCities,
    Set<String>? selectedCityIdentifiers,
    bool? currentLocationEnabled,
    List<CitySelectionCity>? nearbySuggestedCities,
  }) {
    return CitySelectionState(
      availableCities: availableCities ?? this.availableCities,
      selectedCityIdentifiers:
          selectedCityIdentifiers ?? this.selectedCityIdentifiers,
      currentLocationEnabled:
          currentLocationEnabled ?? this.currentLocationEnabled,
      nearbySuggestedCities:
          nearbySuggestedCities ?? this.nearbySuggestedCities,
    );
  }
}
