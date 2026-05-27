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
  static const List<_NearbySuggestedCity> _nearbySuggestedCities = [
    _NearbySuggestedCity(cityName: 'Sao Jeronimo', distanceLabel: '21 km'),
    _NearbySuggestedCity(cityName: 'Triunfo', distanceLabel: '24 km'),
    _NearbySuggestedCity(cityName: 'Arroio dos Ratos', distanceLabel: '27 km'),
  ];

  late final TextEditingController keywordTextController;

  @override
  void initState() {
    super.initState();
    keywordTextController = TextEditingController(
      text: widget.discoveryController.state.keyword,
    );
    widget.discoveryController.addListener(refreshScreen);
  }

  @override
  void dispose() {
    widget.discoveryController.removeListener(refreshScreen);
    keywordTextController.dispose();
    super.dispose();
  }

  void refreshScreen() {
    final keyword = widget.discoveryController.state.keyword;
    if (keywordTextController.text != keyword) {
      keywordTextController.value = TextEditingValue(
        text: keyword,
        selection: TextSelection.collapsed(offset: keyword.length),
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final discoveryState = widget.discoveryController.state;
    final filteredProfessionals = discoveryState.filteredProfessionals;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
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
      bottomNavigationBar: const _DiscoveryBottomNavigationBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          if (widget.preFiltersContent != null) ...[
            widget.preFiltersContent!,
            const SizedBox(height: 16),
          ],
          _DiscoverySearchField(
            keywordTextController: keywordTextController,
            onKeywordChanged: widget.discoveryController.searchByKeyword,
          ),
          const SizedBox(height: 16),
          _DiscoveryFiltersSection(
            discoveryState: discoveryState,
            onSelectCity: widget.discoveryController.selectCity,
            onSelectCategory: widget.discoveryController.selectCategory,
          ),
          const SizedBox(height: 24),
          if (filteredProfessionals.isEmpty)
            _EmptyDiscoveryState(
              onSearchNearbyCities: widget.discoveryController.clearFilters,
              onChangeFilters: widget.discoveryController.clearFilters,
            )
          else ...[
            _DiscoveryResultsHeader(
              resultCount: filteredProfessionals.length,
              hasActiveFilters: discoveryState.hasActiveFilters,
            ),
            const SizedBox(height: 18),
            for (final professional in filteredProfessionals) ...[
              _ProfessionalListItem(
                professional: professional,
                onOpenProfessionalProfile: widget.onOpenProfessionalProfile,
              ),
              const SizedBox(height: 14),
            ],
          ],
        ],
      ),
    );
  }
}

class _DiscoverySearchField extends StatelessWidget {
  const _DiscoverySearchField({
    required this.keywordTextController,
    required this.onKeywordChanged,
  });

  final TextEditingController keywordTextController;
  final ValueChanged<String> onKeywordChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2EAF2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120E223D),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        key: const ValueKey('keyword-search-field'),
        controller: keywordTextController,
        decoration: const InputDecoration(
          hintText: 'Buscar por categoria ou palavra-chave',
          prefixIcon: Icon(Icons.search_rounded),
          border: InputBorder.none,
        ),
        onChanged: onKeywordChanged,
      ),
    );
  }
}

class _DiscoveryFiltersSection extends StatelessWidget {
  const _DiscoveryFiltersSection({
    required this.discoveryState,
    required this.onSelectCity,
    required this.onSelectCategory,
  });

  final DiscoveryFilterState discoveryState;
  final ValueChanged<String?> onSelectCity;
  final ValueChanged<String?> onSelectCategory;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (discoveryState.hasActiveFilters)
          _ActiveFilterSummary(discoveryState: discoveryState)
        else
          const Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _DiscoveryFilterChip(
                icon: Icons.location_on_rounded,
                label: 'Charqueadas, RS',
                highlighted: true,
              ),
              _DiscoveryFilterChip(
                icon: Icons.star_outline_rounded,
                label: 'Avaliacao: 4,0+',
              ),
            ],
          ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _FilterDropdown(
                label: 'Categoria',
                value: discoveryState.selectedCategoryName,
                values: discoveryState.availableCategoryNames,
                onChanged: onSelectCategory,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FilterDropdown(
                label: 'Cidade',
                value: discoveryState.selectedCityDisplayName,
                values: discoveryState.availableCityDisplayNames,
                onChanged: onSelectCity,
              ),
            ),
          ],
        ),
      ],
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
      initialValue: value,
      decoration: InputDecoration(labelText: label),
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
    final activeFilters = <({IconData icon, String label, bool highlighted})>[
      if (discoveryState.selectedCityDisplayName != null)
        (
          icon: Icons.location_on_rounded,
          label: discoveryState.selectedCityDisplayName!,
          highlighted: true,
        ),
      if (discoveryState.selectedCategoryName != null)
        (
          icon: Icons.handyman_outlined,
          label: discoveryState.selectedCategoryName!,
          highlighted: false,
        ),
      if (discoveryState.keyword.trim().isNotEmpty)
        (
          icon: Icons.search_rounded,
          label: discoveryState.keyword.trim(),
          highlighted: false,
        ),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final activeFilter in activeFilters)
          _DiscoveryFilterChip(
            icon: activeFilter.icon,
            label: activeFilter.label,
            highlighted: activeFilter.highlighted,
          ),
      ],
    );
  }
}

class _DiscoveryFilterChip extends StatelessWidget {
  const _DiscoveryFilterChip({
    required this.icon,
    required this.label,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFFEFFAF3) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color:
              highlighted ? const Color(0xFFC9EFDA) : const Color(0xFFDCE4EE),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: highlighted ? const Color(0xFF16C35B) : const Color(0xFF7D8FA8),
            size: 22,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color:
                  highlighted ? const Color(0xFF16C35B) : const Color(0xFF546A86),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 10),
          Icon(
            Icons.close_rounded,
            color: highlighted ? const Color(0xFF16C35B) : const Color(0xFF9BACBE),
            size: 18,
          ),
        ],
      ),
    );
  }
}

class _DiscoveryResultsHeader extends StatelessWidget {
  const _DiscoveryResultsHeader({
    required this.resultCount,
    required this.hasActiveFilters,
  });

  final int resultCount;
  final bool hasActiveFilters;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                resultCount == 1
                    ? '1 profissional encontrado'
                    : '$resultCount profissionais encontrados',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF10233F),
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                hasActiveFilters
                    ? 'Resultados filtrados para sua busca atual.'
                    : 'Veja opcoes disponiveis perto da sua regiao.',
                style: const TextStyle(
                  color: Color(0xFF73839B),
                  fontSize: 16,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.tune_rounded,
            color: Color(0xFF16C35B),
          ),
        ),
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
    return InkWell(
      key: ValueKey(
        'open-professional-profile-${professional.professionalIdentifier}',
      ),
      onTap: () => onOpenProfessionalProfile?.call(
        professional.professionalIdentifier,
      ),
      borderRadius: BorderRadius.circular(28),
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFE3EAF2)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x120E223D),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfessionalAvatar(profilePhotoUrl: professional.profilePhotoUrl),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    professional.professionalName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF13243C),
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${professional.categoryName} - ${professional.cityDisplayName}',
                    style: const TextStyle(
                      color: Color(0xFF6A7D96),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    professional.shortDescription,
                    style: const TextStyle(
                      color: Color(0xFF2F445F),
                      fontSize: 16,
                      height: 1.45,
                    ),
                  ),
                  if (professional.comparisonSignalLabels.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final comparisonSignalLabel
                            in professional.comparisonSignalLabels)
                          _ProfessionalSignalChip(label: comparisonSignalLabel),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF97A5B7),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfessionalSignalChip extends StatelessWidget {
  const _ProfessionalSignalChip({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    final isAvailabilityChip = label.contains('Dispon');
    final isRecentActivityChip = label.contains('Ativo');
    final icon = isAvailabilityChip
        ? Icons.bolt_rounded
        : isRecentActivityChip
            ? Icons.schedule_rounded
            : Icons.verified_user_outlined;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isAvailabilityChip
            ? const Color(0xFFEFFAF3)
            : const Color(0xFFF6F9FC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isAvailabilityChip
              ? const Color(0xFFD6EFDE)
              : const Color(0xFFE1E8F0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF16C35B)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF3B536E),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
      return Container(
        width: 62,
        height: 62,
        decoration: const BoxDecoration(
          color: Color(0xFFEAF8EF),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.handyman_outlined,
          color: Color(0xFF16C35B),
          size: 30,
        ),
      );
    }

    return CircleAvatar(
      radius: 31,
      backgroundImage: NetworkImage(availableProfilePhotoUrl),
    );
  }
}

class _EmptyDiscoveryState extends StatelessWidget {
  const _EmptyDiscoveryState({
    required this.onSearchNearbyCities,
    required this.onChangeFilters,
  });

  final VoidCallback onSearchNearbyCities;
  final VoidCallback onChangeFilters;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          width: 220,
          height: 180,
          decoration: BoxDecoration(
            color: const Color(0xFFF4F8FC),
            borderRadius: BorderRadius.circular(36),
          ),
          child: const Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.description_outlined,
                size: 92,
                color: Color(0xFFDCE5EF),
              ),
              Positioned(
                right: 48,
                top: 34,
                child: Icon(
                  Icons.search_rounded,
                  size: 74,
                  color: Color(0xFF2F4D70),
                ),
              ),
              Positioned(
                right: 38,
                top: 86,
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFF16C35B),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Nenhum profissional encontrado',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF10233F),
            fontSize: 28,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Nao encontramos profissionais para esta busca com os filtros selecionados. Tente ajustar a categoria, ampliar a regiao ou buscar em cidades proximas.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF73839B),
            fontSize: 18,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 28),
        FilledButton.icon(
          onPressed: onSearchNearbyCities,
          icon: const Icon(Icons.location_on_outlined),
          label: const Text('Buscar em cidades proximas'),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: onChangeFilters,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(58),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          icon: const Icon(Icons.tune_rounded),
          label: const Text('Alterar filtros'),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: onChangeFilters,
          child: const Text('Ver outras categorias'),
        ),
        const SizedBox(height: 28),
        const _NearbyCitiesSuggestionCard(),
      ],
    );
  }
}

class _NearbyCitiesSuggestionCard extends StatelessWidget {
  const _NearbyCitiesSuggestionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE3EAF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cidades proximas sugeridas',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF10233F),
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Profissionais disponiveis nessas regioes:',
            style: TextStyle(
              color: Color(0xFF73839B),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final nearbySuggestedCity
                  in _DiscoveryScreenState._nearbySuggestedCities)
                _NearbyCityChip(nearbySuggestedCity: nearbySuggestedCity),
            ],
          ),
        ],
      ),
    );
  }
}

class _NearbyCityChip extends StatelessWidget {
  const _NearbyCityChip({
    required this.nearbySuggestedCity,
  });

  final _NearbySuggestedCity nearbySuggestedCity;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 180),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDDE6EF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_city_outlined,
            color: Color(0xFF16C35B),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nearbySuggestedCity.cityName,
                  style: const TextStyle(
                    color: Color(0xFF10233F),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  nearbySuggestedCity.distanceLabel,
                  style: const TextStyle(
                    color: Color(0xFF73839B),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscoveryBottomNavigationBar extends StatelessWidget {
  const _DiscoveryBottomNavigationBar();

  @override
  Widget build(BuildContext context) {
    return const BottomAppBar(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 14,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _DiscoveryBottomNavigationItem(
                icon: Icons.home_outlined,
                label: 'Inicio',
              ),
              _DiscoveryBottomNavigationItem(
                icon: Icons.search_rounded,
                label: 'Buscar',
                active: true,
              ),
              _DiscoveryBottomNavigationItem(
                icon: Icons.favorite_border_rounded,
                label: 'Salvos',
              ),
              _DiscoveryBottomNavigationItem(
                icon: Icons.person_outline_rounded,
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiscoveryBottomNavigationItem extends StatelessWidget {
  const _DiscoveryBottomNavigationItem({
    required this.icon,
    required this.label,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF16C35B) : const Color(0xFF8695A9);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _NearbySuggestedCity {
  const _NearbySuggestedCity({
    required this.cityName,
    required this.distanceLabel,
  });

  final String cityName;
  final String distanceLabel;
}
