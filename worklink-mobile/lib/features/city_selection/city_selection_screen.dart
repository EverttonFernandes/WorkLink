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
    final selectedCities = citySelectionState.availableCities
        .where(citySelectionState.isCitySelected)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
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
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text(
            'Use sua localizacao atual como padrao ou adicione outras cidades manualmente.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF6A7D96),
                  height: 1.45,
                ),
          ),
          const SizedBox(height: 18),
          _CurrentLocationCard(
            currentLocationEnabled: citySelectionState.currentLocationEnabled,
            onChanged:
                widget.citySelectionController.toggleCurrentLocationUsage,
          ),
          const SizedBox(height: 18),
          const _ManualCitySearchField(),
          const SizedBox(height: 10),
          Text(
            'Digite o nome da cidade e selecione para adicionar.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6A7D96),
                ),
          ),
          const SizedBox(height: 24),
          if (citySelectionState.currentLocationEnabled) ...[
            Text(
              'Cidades proximas a sua localizacao atual',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF13243C),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sugestoes baseadas na cidade padrao (Charqueadas, RS).',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF6A7D96),
                  ),
            ),
            const SizedBox(height: 16),
          ],
          for (final citySelectionCity in citySelectionState.availableCities)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CitySelectionListItem(
                citySelectionCity: citySelectionCity,
                selected: citySelectionState.isCitySelected(citySelectionCity),
                currentLocationEnabled: citySelectionState.currentLocationEnabled,
                onPressed: () => widget.citySelectionController
                    .toggleCitySelection(citySelectionCity),
              ),
            ),
          if (citySelectionState.currentLocationEnabled &&
              citySelectionState.nearbySuggestedCities.isNotEmpty) ...[
            const SizedBox(height: 6),
            for (final citySelectionCity
                in citySelectionState.nearbySuggestedCities)
              _NearbyCityListItem(citySelectionCity: citySelectionCity),
          ],
          if (selectedCities.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              'Selecionadas (${selectedCities.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF13243C),
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final selectedCity in selectedCities)
                  InputChip(
                    label: Text(
                      selectedCity.cityName == 'Charqueadas'
                          ? '${selectedCity.cityName} (atual)'
                          : selectedCity.cityName,
                    ),
                    selected: true,
                    onDeleted: () => widget.citySelectionController
                        .toggleCitySelection(selectedCity),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.check_circle_outline_rounded),
            label: const Text('Aplicar filtros'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: widget.citySelectionController.clearCitySelection,
            child: const Text('Limpar selecao'),
          ),
        ],
      ),
    );
  }
}

class _CurrentLocationCard extends StatelessWidget {
  const _CurrentLocationCard({
    required this.currentLocationEnabled,
    required this.onChanged,
  });

  final bool currentLocationEnabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF5FBF7),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFD4EFDE)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 26,
            backgroundColor: Color(0xFFE2F7E8),
            child: Icon(
              Icons.place_rounded,
              color: Color(0xFF16C35B),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Usando minha localizacao atual',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF13243C),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Charqueadas, RS',
                  style: TextStyle(
                    color: Color(0xFF6A7D96),
                    fontSize: 16,
                  ),
                ),
                if (currentLocationEnabled) ...[
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF16C35B),
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Padrao ativo',
                        style: TextStyle(
                          color: Color(0xFF16C35B),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: currentLocationEnabled,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ManualCitySearchField extends StatelessWidget {
  const _ManualCitySearchField();

  @override
  Widget build(BuildContext context) {
    return const TextField(
      enabled: false,
      decoration: InputDecoration(
        hintText: 'Adicionar cidade manualmente...',
        prefixIcon: Icon(Icons.search),
      ),
    );
  }
}

class _CitySelectionListItem extends StatelessWidget {
  const _CitySelectionListItem({
    required this.citySelectionCity,
    required this.selected,
    required this.currentLocationEnabled,
    required this.onPressed,
  });

  final CitySelectionCity citySelectionCity;
  final bool selected;
  final bool currentLocationEnabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isCurrentLocationCity = currentLocationEnabled &&
        citySelectionCity.cityName == 'Charqueadas';

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onPressed,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF5FBF7) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? const Color(0xFF7DDE9C) : const Color(0xFFD7E0EA),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_city_outlined, color: Color(0xFF7D8FA8)),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      citySelectionCity.displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF13243C),
                      ),
                    ),
                  ),
                  if (isCurrentLocationCity) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7F8EC),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Atual',
                        style: TextStyle(
                          color: Color(0xFF16C35B),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color:
                  selected ? const Color(0xFF16C35B) : const Color(0xFFB9C5D2),
            ),
          ],
        ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD7E0EA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.place_outlined, color: Color(0xFF7D8FA8)),
          const SizedBox(width: 12),
          Text(
            citySelectionCity.displayName,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFF13243C),
            ),
          ),
        ],
      ),
    );
  }
}
