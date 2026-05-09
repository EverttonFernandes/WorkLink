import 'package:flutter/material.dart';

import 'professional_contact_controller.dart';
import 'professional_contact_state.dart';

class ProfessionalContactScreen extends StatelessWidget {
  const ProfessionalContactScreen({
    super.key,
    required this.professionalIdentifier,
    required this.professionalName,
    required this.professionalContactController,
  });

  final String professionalIdentifier;
  final String professionalName;
  final ProfessionalContactController professionalContactController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Falar com o profissional')),
      body: AnimatedBuilder(
        animation: professionalContactController,
        builder: (context, child) {
          final state = professionalContactController.state;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                professionalName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              const _ContactNotice(
                icon: Icons.open_in_new_outlined,
                text: 'A negociação acontece fora do WorkLink pelo WhatsApp.',
              ),
              const SizedBox(height: 12),
              const _ContactNotice(
                icon: Icons.info_outline,
                text:
                    'O WorkLink não garante a execução do serviço contratado.',
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                key: const ValueKey('start-whatsapp-contact-button'),
                onPressed: state.isBusy
                    ? null
                    : () => professionalContactController
                        .startProfessionalContact(professionalIdentifier),
                icon: state.isBusy
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chat_outlined),
                label: Text(_buttonLabelForStatus(state.status)),
              ),
              if (state.hasRegisteredContactIntention) ...[
                const SizedBox(height: 16),
                const Text('Intenção de contato registrada.'),
              ],
              if (state.hasError) ...[
                const SizedBox(height: 16),
                Text(
                  state.errorMessage!,
                  key: const ValueKey('professional-contact-error-message'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              if (state.status == ProfessionalContactStatus.completed) ...[
                const SizedBox(height: 16),
                const Text('WhatsApp aberto para continuar a conversa.'),
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
      _ => 'Abrir WhatsApp',
    };
  }
}

class _ContactNotice extends StatelessWidget {
  const _ContactNotice({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}
