// coverage:ignore-file

import 'package:flutter/material.dart';

import 'discovery_controller.dart';
import 'discovery_professional.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({
    super.key,
    required this.discoveryController,
    this.onOpenProfessionalProfile,
    this.onOpenProfessionalRegistration,
  });

  final DiscoveryController discoveryController;
  final ValueChanged<String>? onOpenProfessionalProfile;
  final VoidCallback? onOpenProfessionalRegistration;

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  @override
  void initState() {
    super.initState();
    widget.discoveryController.addListener(refreshScreen);
  }

  @override
  void dispose() {
    widget.discoveryController.removeListener(refreshScreen);
    super.dispose();
  }

  void refreshScreen() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final discoveryState = widget.discoveryController.state;
    final filteredProfessionals = discoveryState.filteredProfessionals;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Descobrir profissionais'),
        actions: [
          IconButton(
            tooltip: 'Limpar filtros',
            onPressed: widget.discoveryController.clearFilters,
            icon: const Icon(Icons.filter_alt_off_outlined),
          ),
          IconButton(
            key: const ValueKey('open-professional-registration-button'),
            tooltip: 'Cadastrar profissional',
            onPressed: widget.onOpenProfessionalRegistration,
            icon: const Icon(Icons.person_add_alt_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            key: const ValueKey('keyword-search-field'),
            decoration: const InputDecoration(
              labelText: 'Buscar por palavra-chave',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: widget.discoveryController.searchByKeyword,
          ),
          const SizedBox(height: 12),
          _FilterDropdown(
            label: 'Categoria',
            value: discoveryState.selectedCategoryName,
            values: discoveryState.availableCategoryNames,
            onChanged: widget.discoveryController.selectCategory,
          ),
          const SizedBox(height: 12),
          _FilterDropdown(
            label: 'Cidade',
            value: discoveryState.selectedCityDisplayName,
            values: discoveryState.availableCityDisplayNames,
            onChanged: widget.discoveryController.selectCity,
          ),
          const SizedBox(height: 16),
          if (filteredProfessionals.isEmpty)
            const _EmptyDiscoveryState()
          else
            for (final professional in filteredProfessionals)
              _ProfessionalListItem(
                professional: professional,
                onOpenProfessionalProfile: widget.onOpenProfessionalProfile,
              ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<String> values;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem<String>(
          child: Text('Todos'),
        ),
        for (final dropdownValue in values)
          DropdownMenuItem<String>(
            value: dropdownValue,
            child: Text(dropdownValue),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

class _ProfessionalListItem extends StatelessWidget {
  const _ProfessionalListItem({
    required this.professional,
    this.onOpenProfessionalProfile,
  });

  final DiscoveryProfessional professional;
  final ValueChanged<String>? onOpenProfessionalProfile;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        key: ValueKey(
          'open-professional-profile-${professional.professionalIdentifier}',
        ),
        onTap: () => onOpenProfessionalProfile
            ?.call(professional.professionalIdentifier),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfessionalAvatar(
                profilePhotoUrl: professional.profilePhotoUrl,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      professional.professionalName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${professional.categoryName} - ${professional.cityDisplayName}',
                    ),
                    const SizedBox(height: 4),
                    Text(professional.shortDescription),
                    if (professional.comparisonSignalLabels.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final comparisonSignalLabel
                              in professional.comparisonSignalLabels)
                            Chip(
                              visualDensity: VisualDensity.compact,
                              label: Text(comparisonSignalLabel),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfessionalAvatar extends StatelessWidget {
  const _ProfessionalAvatar({
    required this.profilePhotoUrl,
  });

  final String? profilePhotoUrl;

  @override
  Widget build(BuildContext context) {
    final availableProfilePhotoUrl = profilePhotoUrl;
    if (availableProfilePhotoUrl == null ||
        availableProfilePhotoUrl.trim().isEmpty) {
      return const CircleAvatar(
        child: Icon(Icons.handyman_outlined),
      );
    }

    return CircleAvatar(
      backgroundImage: NetworkImage(availableProfilePhotoUrl),
    );
  }
}

class _EmptyDiscoveryState extends StatelessWidget {
  const _EmptyDiscoveryState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 48),
          SizedBox(height: 12),
          Text('Nenhum profissional encontrado'),
          SizedBox(height: 8),
          Text('Ajuste os filtros ou tente outra palavra-chave.'),
        ],
      ),
    );
  }
}
