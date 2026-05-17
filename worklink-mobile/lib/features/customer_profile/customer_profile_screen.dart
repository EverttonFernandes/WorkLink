// coverage:ignore-file

import 'package:flutter/material.dart';

import 'customer_profile_controller.dart';
import 'customer_profile_state.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({
    super.key,
    required this.customerProfileController,
    this.onLogout,
  });

  final CustomerProfileController customerProfileController;
  final VoidCallback? onLogout;

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  @override
  void initState() {
    super.initState();
    widget.customerProfileController.addListener(refreshProfile);
  }

  @override
  void dispose() {
    widget.customerProfileController.removeListener(refreshProfile);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customerProfileState = widget.customerProfileController.state;
    return Scaffold(
      appBar: AppBar(title: const Text('Meu perfil')),
      body: ListView(
        key: const ValueKey('customer-profile-content'),
        padding: const EdgeInsets.all(16),
        children: [
          _CustomerProfileHeader(customerProfileState: customerProfileState),
          const SizedBox(height: 16),
          _CustomerProfileSection(
            title: 'Cidades selecionadas',
            emptyMessage: 'Nenhuma cidade selecionada.',
            children: [
              for (final selectedCity in customerProfileState.selectedCities)
                ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(selectedCity.displayName),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
            ],
          ),
          const SizedBox(height: 16),
          _CustomerProfileSection(
            title: 'Profissionais salvos',
            emptyMessage: 'Nenhum profissional salvo.',
            children: [
              for (final savedProfessional
                  in customerProfileState.savedProfessionals)
                ListTile(
                  leading: const Icon(Icons.bookmark_border),
                  title: Text(savedProfessional.professionalName),
                  subtitle: Text(savedProfessional.subtitle),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
            ],
          ),
          const SizedBox(height: 16),
          _CustomerProfileSection(
            title: 'Avaliações enviadas',
            emptyMessage: 'Nenhuma avaliação enviada.',
            children: [
              for (final submittedReview
                  in customerProfileState.submittedReviews)
                ListTile(
                  leading: const Icon(Icons.star_outline),
                  title: Text(submittedReview.professionalName),
                  subtitle: Text(
                    '${submittedReview.ratingLabel} - '
                    '${submittedReview.publicVisibilityLabel}',
                  ),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Preferências',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SwitchListTile(
            key: const ValueKey('customer-profile-whatsapp-notifications'),
            value: customerProfileState.whatsappNotificationsEnabled,
            onChanged: (enabled) async {
              await widget.customerProfileController
                  .changeWhatsappNotifications(
                enabled,
              );
            },
            title: const Text('Receber avisos no WhatsApp'),
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            key: const ValueKey('customer-profile-personalization'),
            value: customerProfileState.profilePersonalizationEnabled,
            onChanged: (enabled) async {
              await widget.customerProfileController
                  .changeProfilePersonalization(
                enabled,
              );
            },
            title: const Text('Usar preferências para personalizar buscas'),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          Text(
            'Privacidade',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Mostramos apenas dados essenciais da conta e preservamos '
            'avaliações anônimas publicamente.',
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const ValueKey('customer-profile-logout'),
            onPressed: () {
              widget.customerProfileController.logout();
              widget.onLogout?.call();
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sair da conta'),
          ),
        ],
      ),
    );
  }

  void refreshProfile() {
    setState(() {});
  }
}

class _CustomerProfileHeader extends StatelessWidget {
  const _CustomerProfileHeader({
    required this.customerProfileState,
  });

  final CustomerProfileState customerProfileState;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          child: Icon(Icons.person_outline),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customerProfileState.customerName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(customerProfileState.phoneNumber),
              const SizedBox(height: 4),
              Text(customerProfileState.mainCityDisplayName),
            ],
          ),
        ),
      ],
    );
  }
}

class _CustomerProfileSection extends StatelessWidget {
  const _CustomerProfileSection({
    required this.title,
    required this.emptyMessage,
    required this.children,
  });

  final String title;
  final String emptyMessage;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (children.isEmpty) Text(emptyMessage) else ...children,
      ],
    );
  }
}
