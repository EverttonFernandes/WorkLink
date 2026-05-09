import 'package:flutter/material.dart';

import 'customer_authentication_controller.dart';
import 'customer_authentication_state.dart';

class CustomerAuthenticationScreen extends StatelessWidget {
  const CustomerAuthenticationScreen({
    super.key,
    required this.customerAuthenticationController,
    this.onAuthenticationCompleted,
  });

  final CustomerAuthenticationController customerAuthenticationController;
  final ValueChanged<String>? onAuthenticationCompleted;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: customerAuthenticationController,
      builder: (context, _) {
        final authenticationState = customerAuthenticationController.state;
        return Scaffold(
          appBar: AppBar(title: const Text('WorkLink')),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (authenticationState.authenticationStep ==
                    CustomerAuthenticationStep.phoneEntry)
                  _PhoneEntryStep(
                    customerAuthenticationController:
                        customerAuthenticationController,
                    authenticationState: authenticationState,
                  )
                else if (authenticationState.authenticationStep ==
                    CustomerAuthenticationStep.codeVerification)
                  _CodeVerificationStep(
                    customerAuthenticationController:
                        customerAuthenticationController,
                    authenticationState: authenticationState,
                    onAuthenticationCompleted: onAuthenticationCompleted,
                  )
                else
                  _AuthenticatedStep(authenticationState: authenticationState),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PhoneEntryStep extends StatelessWidget {
  const _PhoneEntryStep({
    required this.customerAuthenticationController,
    required this.authenticationState,
  });

  final CustomerAuthenticationController customerAuthenticationController;
  final CustomerAuthenticationState authenticationState;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Text(
          'Encontre profissionais perto de voce',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 24),
        const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(child: Icon(Icons.phone_outlined)),
          title: Text('Continuar com seu celular'),
          subtitle: Text('E rapido, seguro e sem complicacao.'),
        ),
        const SizedBox(height: 16),
        TextField(
          key: const ValueKey('customer-phone-field'),
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Telefone',
            prefixText: '+55 ',
          ),
          onChanged: customerAuthenticationController.changePhoneNumber,
        ),
        if (authenticationState.errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            authenticationState.errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 16),
        FilledButton.icon(
          key: const ValueKey('request-code-button'),
          onPressed: customerAuthenticationController.requestVerificationCode,
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Continuar'),
        ),
        const SizedBox(height: 24),
        const Text(
          'Cadastre-se apenas quando for falar com um profissional. '
          'Sua conta e criada so na hora do contato.',
        ),
      ],
    );
  }
}

class _CodeVerificationStep extends StatelessWidget {
  const _CodeVerificationStep({
    required this.customerAuthenticationController,
    required this.authenticationState,
    required this.onAuthenticationCompleted,
  });

  final CustomerAuthenticationController customerAuthenticationController;
  final CustomerAuthenticationState authenticationState;
  final ValueChanged<String>? onAuthenticationCompleted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Text(
          'Verifique seu numero',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text('Enviamos um codigo de 4 digitos para o numero'),
        const SizedBox(height: 4),
        Text(
          authenticationState.displayPhoneNumber,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 24),
        TextField(
          key: const ValueKey('verification-code-field'),
          keyboardType: TextInputType.number,
          maxLength: 4,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Codigo',
            counterText: '',
          ),
          onChanged: customerAuthenticationController.changeVerificationCode,
        ),
        TextButton.icon(
          key: const ValueKey('edit-phone-button'),
          onPressed: customerAuthenticationController.editPhoneNumber,
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Editar telefone'),
        ),
        TextButton(
          key: const ValueKey('resend-code-button'),
          onPressed: customerAuthenticationController.resendVerificationCode,
          child: const Text('Reenviar codigo'),
        ),
        if (authenticationState.statusMessage != null) ...[
          const SizedBox(height: 8),
          Text(authenticationState.statusMessage!),
        ],
        if (authenticationState.errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            authenticationState.errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 16),
        FilledButton.icon(
          key: const ValueKey('confirm-code-button'),
          onPressed: () {
            final verificationAccepted =
                customerAuthenticationController.confirmVerificationCode();
            if (verificationAccepted) {
              onAuthenticationCompleted?.call(
                customerAuthenticationController.state.normalizedPhoneNumber,
              );
            }
          },
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Confirmar'),
        ),
        const SizedBox(height: 24),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.verified_user_outlined),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Usamos criptografia para manter seus dados seguros e protegidos.',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AuthenticatedStep extends StatelessWidget {
  const _AuthenticatedStep({
    required this.authenticationState,
  });

  final CustomerAuthenticationState authenticationState;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Icon(Icons.verified_user_outlined, size: 64),
        const SizedBox(height: 16),
        Text(
          'Telefone verificado',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          authenticationState.displayPhoneNumber,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
