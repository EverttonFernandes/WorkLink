import 'package:flutter/material.dart';

import 'city_selection_city.dart';
import 'city_selection_controller.dart';

class CitySelectionScreen extends StatefulWidget {
  const CitySelectionScreen({
    super.key,
    required this.citySelectionController,
  });

  final CitySelectionController citySelectionController;

  @override
  State<CitySelectionScreen> createState() => _CitySelectionScreenState();
}

class _CitySelectionScreenState extends State<CitySelectionScreen> {
  @override
  void initState() {
    super.initState();
    widget.citySelectionController.addListener(refreshScreen);
  }

  @override
  void dispose() {
    widget.citySelectionController.removeListener(refreshScreen);
    super.dispose();
  }

  void refreshScreen() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final citySelectionState = widget.citySelectionController.state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar cidades'),
        actions: [
          IconButton(
            tooltip: 'Limpar cidades',
            onPressed: widget.citySelectionController.clearCitySelection,
            icon: const Icon(Icons.clear),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Usar localização atual'),
            subtitle: const Text('Opcional, sem rastreamento contínuo'),
            value: citySelectionState.currentLocationEnabled,
            onChanged:
                widget.citySelectionController.toggleCurrentLocationUsage,
          ),
          const SizedBox(height: 16),
          Text(
            'Cidades',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (final citySelectionCity in citySelectionState.availableCities)
            CheckboxListTile(
              title: Text(citySelectionCity.displayName),
              value: citySelectionState.isCitySelected(citySelectionCity),
              onChanged: (_) => widget.citySelectionController
                  .toggleCitySelection(citySelectionCity),
            ),
          if (citySelectionState.currentLocationEnabled) ...[
            const SizedBox(height: 16),
            Text(
              'Cidades próximas',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final citySelectionCity
                in citySelectionState.nearbySuggestedCities)
              _NearbyCityListItem(citySelectionCity: citySelectionCity),
          ],
        ],
      ),
    );
  }
}

class _NearbyCityListItem extends StatelessWidget {
  const _NearbyCityListItem({
    required this.citySelectionCity,
  });

  final CitySelectionCity citySelectionCity;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.place_outlined),
      title: Text(citySelectionCity.displayName),
    );
  }
}
