// coverage:ignore-file

import 'package:flutter/material.dart';

import 'discovery_controller.dart';
import 'discovery_filter_state.dart';
import 'discovery_professional.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({
    super.key,
    required this.discoveryController,
    this.preFiltersContent,
    this.onOpenProfessionalProfile,
    this.onOpenProfessionalRegistration,
    this.onOpenAdministrativeConsole,
    this.onOpenCustomerProfile,
  });

  final DiscoveryController discoveryController;
  final Widget? preFiltersContent;
  final ValueChanged<String>? onOpenProfessionalProfile;
  final VoidCallback? onOpenProfessionalRegistration;
  final VoidCallback? onOpenAdministrativeConsole;
  final VoidCallback? onOpenCustomerProfile;

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
        title: const Text('Buscar profissionais'),
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
          if (widget.onOpenAdministrativeConsole != null)
            IconButton(
              key: const ValueKey('open-administrative-console-button'),
              tooltip: 'Console administrativo',
              onPressed: widget.onOpenAdministrativeConsole,
              icon: const Icon(Icons.admin_panel_settings_outlined),
            ),
          IconButton(
            key: const ValueKey('open-customer-profile-button'),
            tooltip: 'Meu perfil',
            onPressed: widget.onOpenCustomerProfile,
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.preFiltersContent != null) ...[
            widget.preFiltersContent!,
            const SizedBox(height: 16),
          ],
          TextField(
            key: const ValueKey('keyword-search-field'),
            decoration: const InputDecoration(
              hintText: 'Buscar por categoria ou palavra-chave',
              prefixIcon: Icon(Icons.search),
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
          if (discoveryState.hasActiveFilters)
            _ActiveFilterSummary(discoveryState: discoveryState),
          if (discoveryState.hasActiveFilters) const SizedBox(height: 16),
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

class _ActiveFilterSummary extends StatelessWidget {
  const _ActiveFilterSummary({
    required this.discoveryState,
  });

  final DiscoveryFilterState discoveryState;

  @override
  Widget build(BuildContext context) {
    final activeLabels = <String>[
      if (discoveryState.selectedCityDisplayName != null)
        discoveryState.selectedCityDisplayName!,
      if (discoveryState.selectedCategoryName != null)
        discoveryState.selectedCategoryName!,
      if (discoveryState.keyword.trim().isNotEmpty) discoveryState.keyword.trim(),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final activeLabel in activeLabels) Chip(label: Text(activeLabel)),
      ],
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
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF13243C),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${professional.categoryName} - ${professional.cityDisplayName}',
                      style: const TextStyle(color: Color(0xFF6A7D96)),
                    ),
                    const SizedBox(height: 8),
                    Text(professional.shortDescription),
                    if (professional.comparisonSignalLabels.isNotEmpty) ...[
                      const SizedBox(height: 10),
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
        radius: 26,
        backgroundColor: Color(0xFFEAF8EF),
        child: Icon(
          Icons.handyman_outlined,
          color: Color(0xFF16C35B),
        ),
      );
    }

    return CircleAvatar(
      radius: 26,
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
          Icon(
            Icons.search_off_rounded,
            size: 56,
            color: Color(0xFF7D8FA8),
          ),
          SizedBox(height: 20),
          Text(
            'Nenhum profissional encontrado',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Nao encontramos profissionais para esta busca. Ajuste os filtros ou tente outra palavra-chave.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
