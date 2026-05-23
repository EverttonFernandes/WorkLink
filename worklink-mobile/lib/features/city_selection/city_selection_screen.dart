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
          Text(
            'Use sua localizacao atual como padrao ou adicione outras cidades manualmente.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF6A7D96),
                  height: 1.45,
                ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF5FBF7),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFD4EFDE)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: Color(0xFFE2F7E8),
                  child: Icon(
                    Icons.place_rounded,
                    color: Color(0xFF16C35B),
                  ),
                ),
                const SizedBox(width: 12),
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
                      Text(
                        citySelectionState.currentLocationEnabled
                            ? 'Charqueadas, RS'
                            : 'Ative para usar uma cidade padrao',
                        style: const TextStyle(
                          color: Color(0xFF6A7D96),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: citySelectionState.currentLocationEnabled,
                  onChanged: widget.citySelectionController
                      .toggleCurrentLocationUsage,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const TextField(
            enabled: false,
            decoration: InputDecoration(
              hintText: 'Adicionar cidade manualmente...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Digite o nome da cidade e selecione para adicionar.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6A7D96),
                ),
          ),
          const SizedBox(height: 20),
          if (citySelectionState.currentLocationEnabled) ...[
            Text(
              'Cidades proximas a sua localizacao atual',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF13243C),
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Sugestoes baseadas na cidade padrao.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6A7D96),
                  ),
            ),
            const SizedBox(height: 12),
          ],
          for (final citySelectionCity in citySelectionState.availableCities)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CitySelectionListItem(
                citySelectionCity: citySelectionCity,
                selected:
                    citySelectionState.isCitySelected(citySelectionCity),
                onPressed: () => widget.citySelectionController
                    .toggleCitySelection(citySelectionCity),
              ),
            ),
          if (citySelectionState.currentLocationEnabled) ...[
            const SizedBox(height: 16),
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
                    label: Text(selectedCity.cityName),
                    selected: true,
                    onDeleted: () => widget.citySelectionController
                        .toggleCitySelection(selectedCity),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Aplicar filtros'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: widget.citySelectionController.clearCitySelection,
            child: const Text('Limpar selecao'),
          ),
        ],
      ),
    );
  }
}

class _CitySelectionListItem extends StatelessWidget {
  const _CitySelectionListItem({
    required this.citySelectionCity,
    required this.selected,
    required this.onPressed,
  });

  final CitySelectionCity citySelectionCity;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
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
              child: Text(
                citySelectionCity.displayName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF13243C),
                ),
              ),
            ),
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
