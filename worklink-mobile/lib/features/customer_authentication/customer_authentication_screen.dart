// coverage:ignore-file

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
    final colorScheme = Theme.of(context).colorScheme;
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
                const SizedBox(height: 12),
                _BrandHeader(colorScheme: colorScheme),
                const SizedBox(height: 24),
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
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Text(
          'Encontre profissionais perto de voce',
          style: textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF13243C),
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Encontre eletricistas, encanadores, pedreiros e muito mais na sua regiao com rapidez e confianca.',
          style: textTheme.titleMedium?.copyWith(
            color: const Color(0xFF6A7D96),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFE4EBF2)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x140E223D),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 26,
                  backgroundColor: Color(0xFFEAF8EF),
                  child: Icon(
                    Icons.phone_outlined,
                    color: Color(0xFF16C35B),
                  ),
                ),
                title: Text('Continuar com seu celular'),
                subtitle: Text('E rapido, seguro e sem complicacao.'),
              ),
              const SizedBox(height: 16),
              TextField(
                key: const ValueKey('customer-phone-field'),
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
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
              const SizedBox(height: 18),
              FilledButton.icon(
                key: const ValueKey('request-code-button'),
                onPressed: customerAuthenticationController
                    .requestVerificationCodeAsync,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Continuar'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF5FBF7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFD4EFDE)),
          ),
          child: const Text(
            'Cadastre-se apenas quando for falar com um profissional. Sua conta e criada so na hora do contato.',
            style: TextStyle(
              color: Color(0xFF2F445F),
              height: 1.5,
            ),
          ),
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
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Text(
          'Verifique seu numero',
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF13243C),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enviamos um codigo de 4 digitos para o numero',
          style: textTheme.titleMedium?.copyWith(
            color: const Color(0xFF6A7D96),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          authenticationState.displayPhoneNumber,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF13243C),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFE4EBF2)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x140E223D),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                key: const ValueKey('verification-code-field'),
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: const InputDecoration(
                  labelText: 'Codigo',
                  counterText: '',
                ),
                onChanged:
                    customerAuthenticationController.changeVerificationCode,
              ),
              TextButton.icon(
                key: const ValueKey('edit-phone-button'),
                onPressed: customerAuthenticationController.editPhoneNumber,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar telefone'),
              ),
              TextButton(
                key: const ValueKey('resend-code-button'),
                onPressed:
                    customerAuthenticationController.resendVerificationCode,
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
                onPressed: () async {
                  final verificationAccepted =
                      await customerAuthenticationController
                          .confirmVerificationCodeAsync();
                  if (verificationAccepted) {
                    onAuthenticationCompleted?.call(
                      customerAuthenticationController
                          .state
                          .normalizedPhoneNumber,
                    );
                  }
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Confirmar'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _SecurityCallout(),
      ],
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({
    required this.colorScheme,
  });

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: colorScheme.primary,
          child: const Icon(
            Icons.verified_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ache',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF13243C),
              ),
            ),
            Text(
              'profissional',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF16C35B),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SecurityCallout extends StatelessWidget {
  const _SecurityCallout();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF5FBF7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD4EFDE)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_user_outlined,
            color: Color(0xFF16C35B),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Usamos criptografia para manter seus dados seguros e protegidos.',
            ),
          ),
        ],
      ),
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
