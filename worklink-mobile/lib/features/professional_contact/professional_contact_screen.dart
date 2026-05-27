// coverage:ignore-file

import 'package:flutter/material.dart';

import 'professional_contact_controller.dart';
import 'professional_contact_state.dart';

class ProfessionalContactScreen extends StatelessWidget {
  const ProfessionalContactScreen({
    super.key,
    required this.professionalIdentifier,
    required this.professionalName,
    required this.professionalContactController,
    this.onOpenPostContactFeedback,
  });

  final String professionalIdentifier;
  final String professionalName;
  final ProfessionalContactController professionalContactController;
  final ValueChanged<String>? onOpenPostContactFeedback;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Falar com o profissional')),
      body: AnimatedBuilder(
        animation: professionalContactController,
        builder: (context, child) {
          final state = professionalContactController.state;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              _ProfessionalContactProfileCard(
                professionalName: professionalName,
              ),
              const SizedBox(height: 18),
              const _ProfessionalContactHighlightCard(),
              const SizedBox(height: 24),
              Text(
                'Antes de continuar',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF10233F),
                    ),
              ),
              const SizedBox(height: 14),
              const _ProfessionalContactChecklistItem(
                icon: Icons.assignment_outlined,
                iconColor: Color(0xFF16C35B),
                text: 'Confirme os detalhes do serviço',
              ),
              const SizedBox(height: 12),
              const _ProfessionalContactChecklistItem(
                icon: Icons.attach_money_rounded,
                iconColor: Color(0xFF16C35B),
                text: 'Combine valores e prazos diretamente',
              ),
              const SizedBox(height: 12),
              const _ProfessionalContactChecklistItem(
                icon: Icons.star_border_rounded,
                iconColor: Color(0xFF16C35B),
                text: 'Após o contato, volte para avaliar o profissional',
              ),
              const SizedBox(height: 18),
              const _ProfessionalContactSafetyCard(),
              const SizedBox(height: 22),
              FilledButton.icon(
                key: const ValueKey('start-whatsapp-contact-button'),
                onPressed: state.isBusy
                    ? null
                    : () => professionalContactController
                        .startProfessionalContact(professionalIdentifier),
                icon: state.isBusy
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.chat_outlined),
                label: Text(_buttonLabelForStatus(state.status)),
              ),
              const SizedBox(height: 14),
              OutlinedButton(
                onPressed: () => Navigator.of(context).maybePop(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  side: const BorderSide(color: Color(0xFFDCE3EC)),
                  foregroundColor: const Color(0xFF73839B),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Cancelar'),
              ),
              const SizedBox(height: 18),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.help_outline_rounded,
                    color: Color(0xFF73839B),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Precisa de ajuda?',
                    style: TextStyle(
                      color: Color(0xFF73839B),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (state.hasRegisteredContactIntention) ...[
                const SizedBox(height: 18),
                const _ProfessionalContactInlineStatus(
                  icon: Icons.check_circle_outline_rounded,
                  text: 'Intenção de contato registrada.',
                ),
              ],
              if (state.hasError) ...[
                const SizedBox(height: 14),
                Text(
                  state.errorMessage!,
                  key: const ValueKey('professional-contact-error-message'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              if (state.status == ProfessionalContactStatus.completed) ...[
                const SizedBox(height: 14),
                const _ProfessionalContactInlineStatus(
                  icon: Icons.open_in_new_outlined,
                  text: 'WhatsApp aberto para continuar a conversa.',
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  key: const ValueKey('open-post-contact-feedback-button'),
                  onPressed: onOpenPostContactFeedback == null
                      ? null
                      : () => onOpenPostContactFeedback!(
                            state.contactIntention!.contactIntentionIdentifier,
                          ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(58),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  icon: const Icon(Icons.rate_review_outlined),
                  label: const Text('Responder pós-contato'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  String _buttonLabelForStatus(ProfessionalContactStatus status) {
    return switch (status) {
      ProfessionalContactStatus.registeringContactIntention =>
        'Registrando contato',
      ProfessionalContactStatus.openingWhatsapp => 'Abrindo WhatsApp',
      _ => 'Abrir no WhatsApp',
    };
  }
}

class _ProfessionalContactProfileCard extends StatelessWidget {
  const _ProfessionalContactProfileCard({
    required this.professionalName,
  });

  final String professionalName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE8EDF3)),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE9EEF4),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Color(0xFF73839B),
                  size: 52,
                ),
              ),
              Positioned(
                right: -4,
                bottom: 2,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFF16C35B),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  professionalName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: const Color(0xFF10233F),
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Eletricista residencial',
                  style: TextStyle(
                    color: Color(0xFF73839B),
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 12),
                const Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _ProfessionalContactBadge(
                      icon: Icons.star_rounded,
                      text: '4.9',
                      color: Color(0xFFE9A900),
                      backgroundColor: Color(0xFFFFF6DE),
                    ),
                    _ProfessionalContactBadge(
                      icon: Icons.verified_user_outlined,
                      text: 'Perfil verificado',
                      color: Color(0xFF16C35B),
                      backgroundColor: Color(0xFFEAF8EF),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: Color(0xFF8A97AD),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Charqueadas (Centro) • 1,2 km',
                        style: TextStyle(
                          color: Color(0xFF8A97AD),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfessionalContactHighlightCard extends StatelessWidget {
  const _ProfessionalContactHighlightCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF5FFF8), Color(0xFFF8FBFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE0F2E7)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Color(0xFFE9F9EE),
            child: Icon(
              Icons.chat_outlined,
              color: Color(0xFF16C35B),
              size: 34,
            ),
          ),
          SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Você será redirecionado para o WhatsApp para falar direto com o profissional.',
                  style: TextStyle(
                    color: Color(0xFF10233F),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Isso ajuda a agilizar o atendimento e facilita o fechamento do serviço.',
                  style: TextStyle(
                    color: Color(0xFF73839B),
                    fontSize: 16,
                    height: 1.5,
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

class _ProfessionalContactChecklistItem extends StatelessWidget {
  const _ProfessionalContactChecklistItem({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  final IconData icon;
  final Color iconColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8EDF3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFEAF8EF),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF10233F),
                fontSize: 18,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfessionalContactSafetyCard extends StatelessWidget {
  const _ProfessionalContactSafetyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFF),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE1EAF7)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Color(0xFFE8F1FF),
            child: Icon(
              Icons.shield_outlined,
              color: Color(0xFF2F80ED),
              size: 32,
            ),
          ),
          SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sua segurança importa',
                  style: TextStyle(
                    color: Color(0xFF10233F),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Use a plataforma com responsabilidade. Se precisar, você pode denunciar ou reportar qualquer problema depois do atendimento.',
                  style: TextStyle(
                    color: Color(0xFF73839B),
                    fontSize: 16,
                    height: 1.5,
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

class _ProfessionalContactInlineStatus extends StatelessWidget {
  const _ProfessionalContactInlineStatus({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFFAF3),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD5EFDD)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF16C35B)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF10233F),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfessionalContactBadge extends StatelessWidget {
  const _ProfessionalContactBadge({
    required this.icon,
    required this.text,
    required this.color,
    required this.backgroundColor,
  });

  final IconData icon;
  final String text;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
