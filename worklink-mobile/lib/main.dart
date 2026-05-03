import 'package:flutter/material.dart';

import 'app/worklink_app_configuration.dart';
import 'features/city_selection/city_selection_city.dart';
import 'features/city_selection/city_selection_controller.dart';
import 'features/city_selection/city_selection_screen.dart';

// coverage:ignore-start
void main() {
  runApp(const WorkLinkApp());
}
// coverage:ignore-end

class WorkLinkApp extends StatelessWidget {
  const WorkLinkApp({
    super.key,
    this.applicationConfiguration = const WorkLinkAppConfiguration(),
  });

  final WorkLinkAppConfiguration applicationConfiguration;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: applicationConfiguration.applicationName,
      home: CitySelectionScreen(
        citySelectionController: CitySelectionController(
          availableCities: const [
            CitySelectionCity(cityIdentifier: 'canoas-rs', cityName: 'Canoas', stateCode: 'RS'),
            CitySelectionCity(cityIdentifier: 'esteio-rs', cityName: 'Esteio', stateCode: 'RS'),
            CitySelectionCity(cityIdentifier: 'porto-alegre-rs', cityName: 'Porto Alegre', stateCode: 'RS'),
          ],
          nearbySuggestedCities: const [
            CitySelectionCity(cityIdentifier: 'esteio-rs', cityName: 'Esteio', stateCode: 'RS'),
            CitySelectionCity(cityIdentifier: 'porto-alegre-rs', cityName: 'Porto Alegre', stateCode: 'RS'),
          ],
        ),
      ),
    );
  }
}
