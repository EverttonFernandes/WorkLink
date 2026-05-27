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
  static const Color _workLinkDark = Color(0xFF10233F);
  static const Color _workLinkMuted = Color(0xFF7787A0);
  static const Color _workLinkGreen = Color(0xFF16C35B);
  static const Color _workLinkSurface = Color(0xFFF5FBF7);

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
      appBar: AppBar(
        title: const Text('Meu perfil'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5FA),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_none_rounded),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const _CustomerProfileBottomNavigationBar(),
      body: ListView(
        key: const ValueKey('customer-profile-content'),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          _CustomerProfileHero(
            customerProfileState: customerProfileState,
          ),
          const SizedBox(height: 24),
          _CustomerProfileCitiesCard(
            customerProfileState: customerProfileState,
          ),
          const SizedBox(height: 24),
          _CustomerProfileActionCard(
            leadingIcon: Icons.favorite_border_rounded,
            leadingColor: _workLinkGreen,
            leadingBackgroundColor: const Color(0xFFE9F9EE),
            title: 'Profissionais salvos',
            subtitle: customerProfileState.hasSavedProfessionals
                ? customerProfileState.savedProfessionals
                    .map((savedProfessional) => savedProfessional.professionalName)
                    .join(', ')
                : 'Seus profissionais favoritos',
            body: customerProfileState.hasSavedProfessionals
                ? [
                    const SizedBox(height: 18),
                    for (final savedProfessional
                        in customerProfileState.savedProfessionals) ...[
                      _CustomerProfileInfoRow(
                        icon: Icons.bookmark_border_rounded,
                        iconColor: _workLinkGreen,
                        title: savedProfessional.professionalName,
                        subtitle: savedProfessional.subtitle,
                      ),
                      if (savedProfessional !=
                          customerProfileState.savedProfessionals.last)
                        const Divider(height: 24),
                    ],
                  ]
                : const [],
          ),
          const SizedBox(height: 16),
          _CustomerProfileActionCard(
            leadingIcon: Icons.star_border_rounded,
            leadingColor: const Color(0xFFE9A900),
            leadingBackgroundColor: const Color(0xFFFFF6DE),
            title: 'Avaliações enviadas',
            subtitle: customerProfileState.hasSubmittedReviews
                ? 'Avaliações que você fez'
                : 'Nenhuma avaliação enviada.',
            body: customerProfileState.hasSubmittedReviews
                ? [
                    const SizedBox(height: 18),
                    for (final submittedReview
                        in customerProfileState.submittedReviews) ...[
                      _CustomerProfileInfoRow(
                        icon: Icons.reviews_outlined,
                        iconColor: const Color(0xFFE9A900),
                        title: submittedReview.professionalName,
                        subtitle:
                            '${submittedReview.ratingLabel} - ${submittedReview.publicVisibilityLabel}',
                      ),
                      if (submittedReview.hasComment) ...[
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(left: 38),
                          child: Text(
                            submittedReview.comment,
                            style: const TextStyle(
                              color: _workLinkMuted,
                              fontSize: 15,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                      if (submittedReview !=
                          customerProfileState.submittedReviews.last)
                        const Divider(height: 24),
                    ],
                  ]
                : const [],
          ),
          const SizedBox(height: 16),
          const _CustomerProfileActionCard(
            leadingIcon: Icons.shield_outlined,
            leadingColor: Color(0xFF7B4DFF),
            leadingBackgroundColor: Color(0xFFF3ECFF),
            title: 'Privacidade',
            subtitle: 'Controle seus dados e preferências',
            body: [
              SizedBox(height: 18),
              Text(
                'Mostramos apenas dados essenciais da conta e preservamos avaliações anônimas publicamente.',
                style: TextStyle(
                  color: _workLinkMuted,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _CustomerProfileActionCard(
            leadingIcon: Icons.settings_outlined,
            leadingColor: const Color(0xFFFF7A00),
            leadingBackgroundColor: const Color(0xFFFFF0E1),
            title: 'Configurações',
            subtitle: 'Notificações, conta e mais',
            body: [
              const SizedBox(height: 18),
              Material(
                color: Colors.transparent,
                child: SwitchListTile.adaptive(
                  key: const ValueKey('customer-profile-whatsapp-notifications'),
                  value: customerProfileState.whatsappNotificationsEnabled,
                  onChanged: (enabled) async {
                    await widget.customerProfileController
                        .changeWhatsappNotifications(enabled);
                  },
                  title: const Text('Receber avisos no WhatsApp'),
                  subtitle: const Text('Alertas úteis sobre conta e contatos'),
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: _workLinkGreen,
                ),
              ),
              const Divider(height: 8),
              Material(
                color: Colors.transparent,
                child: SwitchListTile.adaptive(
                  key: const ValueKey('customer-profile-personalization'),
                  value: customerProfileState.profilePersonalizationEnabled,
                  onChanged: (enabled) async {
                    await widget.customerProfileController
                        .changeProfilePersonalization(enabled);
                  },
                  title: const Text('Personalizar buscas com preferências'),
                  subtitle: const Text('Sugestões mais próximas do seu perfil'),
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: _workLinkGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          InkWell(
            key: const ValueKey('customer-profile-logout'),
            onTap: () {
              widget.customerProfileController.logout();
              widget.onLogout?.call();
            },
            borderRadius: BorderRadius.circular(28),
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFE9EDF3)),
              ),
              child: const Row(
                children: [
                  _CustomerProfileLeadingBadge(
                    icon: Icons.logout_rounded,
                    iconColor: Color(0xFFFF3B30),
                    backgroundColor: Color(0xFFFFEFEF),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Sair da conta',
                      style: TextStyle(
                        color: Color(0xFFFF3B30),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: _workLinkMuted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: _workLinkSurface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFDDF3E5)),
            ),
            child: const Column(
              children: [
                Icon(Icons.lock_outline_rounded, color: _workLinkGreen),
                SizedBox(height: 8),
                Text(
                  'Seus dados estão protegidos',
                  style: TextStyle(
                    color: _workLinkMuted,
                    fontSize: 15,
                    height: 1.45,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Saiba mais na nossa Política de Privacidade',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _workLinkGreen,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void refreshProfile() {
    setState(() {});
  }
}

class _CustomerProfileHero extends StatelessWidget {
  const _CustomerProfileHero({
    required this.customerProfileState,
  });

  final CustomerProfileState customerProfileState;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 124,
              height: 124,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF0B6BE8), Color(0xFF123E88)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 68,
                color: Colors.white,
              ),
            ),
            Positioned(
              right: -6,
              bottom: 4,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE8EDF3)),
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  color: Color(0xFF16C35B),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerProfileState.customerName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF10233F),
                      ),
                ),
                const SizedBox(height: 10),
                _CustomerProfileMetaLine(
                  icon: Icons.call_outlined,
                  text: customerProfileState.phoneNumber,
                ),
                const SizedBox(height: 8),
                _CustomerProfileMetaLine(
                  icon: Icons.location_on_outlined,
                  text: customerProfileState.mainCityDisplayName,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9F9EE),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        size: 18,
                        color: Color(0xFF16C35B),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Conta verificada',
                        style: TextStyle(
                          color: Color(0xFF16C35B),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CustomerProfileCitiesCard extends StatelessWidget {
  const _CustomerProfileCitiesCard({
    required this.customerProfileState,
  });

  final CustomerProfileState customerProfileState;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE8EDF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              _CustomerProfileLeadingBadge(
                icon: Icons.location_on_outlined,
                iconColor: Color(0xFF16C35B),
                backgroundColor: Color(0xFFE9F9EE),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Cidades selecionadas',
                  style: TextStyle(
                    color: Color(0xFF10233F),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                'Gerenciar',
                style: TextStyle(
                  color: Color(0xFF16C35B),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Color(0xFF7787A0)),
            ],
          ),
          const SizedBox(height: 18),
          if (!customerProfileState.hasSelectedCities)
            const Text(
              'Nenhuma cidade selecionada.',
              style: TextStyle(color: Color(0xFF7787A0)),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final selectedCity in customerProfileState.selectedCities)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF8EF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      selectedCity.displayName,
                      style: const TextStyle(
                        color: Color(0xFF16C35B),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _CustomerProfileActionCard extends StatelessWidget {
  const _CustomerProfileActionCard({
    required this.leadingIcon,
    required this.leadingColor,
    required this.leadingBackgroundColor,
    required this.title,
    required this.subtitle,
    required this.body,
  });

  final IconData leadingIcon;
  final Color leadingColor;
  final Color leadingBackgroundColor;
  final String title;
  final String subtitle;
  final List<Widget> body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE8EDF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CustomerProfileLeadingBadge(
                icon: leadingIcon,
                iconColor: leadingColor,
                backgroundColor: leadingBackgroundColor,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _CustomerProfileScreenState._workLinkDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _CustomerProfileScreenState._workLinkMuted,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: _CustomerProfileScreenState._workLinkMuted,
              ),
            ],
          ),
          ...body,
        ],
      ),
    );
  }
}

class _CustomerProfileInfoRow extends StatelessWidget {
  const _CustomerProfileInfoRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _CustomerProfileScreenState._workLinkDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _CustomerProfileScreenState._workLinkMuted,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CustomerProfileLeadingBadge extends StatelessWidget {
  const _CustomerProfileLeadingBadge({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, color: iconColor, size: 28),
    );
  }
}

class _CustomerProfileMetaLine extends StatelessWidget {
  const _CustomerProfileMetaLine({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF8A97AD),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF8A97AD),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _CustomerProfileBottomNavigationBar extends StatelessWidget {
  const _CustomerProfileBottomNavigationBar();

  @override
  Widget build(BuildContext context) {
    return const BottomAppBar(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 12,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _CustomerProfileBottomNavigationItem(
              icon: Icons.home_outlined,
              label: 'Início',
            ),
            _CustomerProfileBottomNavigationItem(
              icon: Icons.search_rounded,
              label: 'Buscar',
            ),
            _CustomerProfileBottomNavigationItem(
              icon: Icons.favorite_border_rounded,
              label: 'Salvos',
            ),
            _CustomerProfileBottomNavigationItem(
              icon: Icons.person_rounded,
              label: 'Perfil',
              active: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerProfileBottomNavigationItem extends StatelessWidget {
  const _CustomerProfileBottomNavigationItem({
    required this.icon,
    required this.label,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF16C35B) : const Color(0xFF8A97AD);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 1),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            height: 0.95,
          ),
        ),
      ],
    );
  }
}
