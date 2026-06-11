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
          backgroundColor: const Color(0xFFF8FBFF),
          appBar: AppBar(title: const Text('Profissional Perto')),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
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
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF13243C),
              height: 1.12,
            ),
            children: const [
              TextSpan(text: 'Encontre profissionais\n'),
              TextSpan(
                text: 'perto de voce',
                style: TextStyle(color: Color(0xFF16C35B)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Encontre eletricistas, encanadores e pedreiros\nna sua regiao com rapidez e confianca.',
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(
            color: const Color(0xFF6A7D96),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 20),
        const _RegionChip(),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
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
                  radius: 28,
                  backgroundColor: Color(0xFFEAF8EF),
                  child: Icon(
                    Icons.phone_outlined,
                    color: Color(0xFF16C35B),
                  ),
                ),
                title: Text('Continuar com seu celular'),
                subtitle: Text(
                  'Escolha onde receber o codigo: SMS, WhatsApp ou email.',
                ),
              ),
              const SizedBox(height: 18),
              _PhoneNumberInputField(
                onChanged: customerAuthenticationController.changePhoneNumber,
              ),
              const SizedBox(height: 16),
              _VerificationChannelSelector(
                selectedChannel: authenticationState.verificationChannel,
                onChanged:
                    customerAuthenticationController.changeVerificationChannel,
              ),
              if (authenticationState.emailAddressRequired) ...[
                const SizedBox(height: 16),
                _EmailAddressInputField(
                  onChanged:
                      customerAuthenticationController.changeEmailAddress,
                ),
              ],
              if (authenticationState.errorMessage != null) ...[
                const SizedBox(height: 10),
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
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Continuar'),
              ),
              const SizedBox(height: 22),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'ou continue com',
                      style: TextStyle(color: Color(0xFF8B99AB), fontSize: 15),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 18),
              const _SocialProviderButton(
                icon: Icons.g_mobiledata_rounded,
                label: 'Continuar com Google',
              ),
              const SizedBox(height: 12),
              const _SocialProviderButton(
                icon: Icons.apple_rounded,
                label: 'Continuar com Apple',
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const _OnboardingCallout(),
        const SizedBox(height: 22),
        const Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _TrustBadge(
              icon: Icons.location_on_outlined,
              text: 'Profissionais da sua regiao',
            ),
            _TrustBadge(
              icon: Icons.verified_user_outlined,
              text: 'Avaliados e verificados',
            ),
            _TrustBadge(
              icon: Icons.bolt_rounded,
              text: 'Resposta rapida e pratica',
            ),
          ],
        ),
        const SizedBox(height: 22),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(
                Icons.lock_outline_rounded,
                color: Color(0xFF7D8FA8),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Ao continuar, voce concorda com os Termos de Uso e nossa Politica de Privacidade.',
                style: TextStyle(
                  color: Color(0xFF6A7D96),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
          ],
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
        Text(
          'Verifique seu numero',
          textAlign: TextAlign.center,
          style: textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF13243C),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Enviamos um codigo de 4 digitos por ${authenticationState.verificationChannelDisplayName} para',
          textAlign: TextAlign.center,
          style: textTheme.titleLarge?.copyWith(
            color: const Color(0xFF6A7D96),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          authenticationState.verificationDestination,
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF16C35B),
          ),
        ),
        const SizedBox(height: 28),
        _VerificationCodeBoxes(
          verificationCode: authenticationState.verificationCode,
        ),
        Opacity(
          opacity: 0.02,
          child: SizedBox(
            height: 1,
            child: TextField(
              key: const ValueKey('verification-code-field'),
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: '',
              ),
              onChanged:
                  customerAuthenticationController.changeVerificationCode,
            ),
          ),
        ),
        const SizedBox(height: 18),
        TextButton.icon(
          key: const ValueKey('edit-phone-button'),
          onPressed: customerAuthenticationController.editPhoneNumber,
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Editar numero'),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF5FBF7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFD4EFDE)),
          ),
          child: const Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFFEAF8EF),
                child: Icon(
                  Icons.verified_user_outlined,
                  color: Color(0xFF16C35B),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Em homologacao, o envio pode ser simulado. Em producao, use o canal escolhido para receber o codigo antes de falar com um profissional.',
                  style: TextStyle(
                    color: Color(0xFF51657F),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Divider(height: 1),
        const SizedBox(height: 20),
        const Text(
          'Nao recebeu o codigo?',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF13243C),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          key: const ValueKey('resend-code-button'),
          onPressed: customerAuthenticationController.resendVerificationCode,
          child: Text(
            authenticationState.resendCount == 0
                ? 'Reenviar codigo'
                : 'Reenviar novamente',
          ),
        ),
        if (authenticationState.statusMessage != null) ...[
          const SizedBox(height: 6),
          Text(
            authenticationState.statusMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF73839B),
              fontSize: 15,
            ),
          ),
        ],
        if (authenticationState.errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            authenticationState.errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 18),
        FilledButton.icon(
          key: const ValueKey('confirm-code-button'),
          onPressed: () async {
            final verificationAccepted = await customerAuthenticationController
                .confirmVerificationCodeAsync();
            if (verificationAccepted) {
              onAuthenticationCompleted?.call(
                customerAuthenticationController.state.normalizedPhoneNumber,
              );
            }
          },
          icon: const Icon(Icons.arrow_forward_rounded),
          label: const Text('Confirmar'),
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
          radius: 28,
          backgroundColor: colorScheme.primary,
          child: const Icon(
            Icons.verified_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(width: 14),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ache',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF13243C),
              ),
            ),
            Text(
              'profissional',
              style: TextStyle(
                fontSize: 16,
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

class _PhoneNumberInputField extends StatelessWidget {
  const _PhoneNumberInputField({
    required this.onChanged,
  });

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD9E3EE)),
      ),
      child: Row(
        children: [
          const Text(
            '🇧🇷',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 10),
          const Text(
            '+55',
            style: TextStyle(
              color: Color(0xFF13243C),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 1,
            height: 26,
            color: const Color(0xFFDCE4EE),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              key: const ValueKey('customer-phone-field'),
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: '(11) 9 9999-9999',
                border: InputBorder.none,
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmailAddressInputField extends StatelessWidget {
  const _EmailAddressInputField({
    required this.onChanged,
  });

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const ValueKey('customer-email-field'),
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.alternate_email_rounded),
        hintText: 'voce@email.com',
        labelText: 'Email para receber o codigo',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(22)),
      ),
      onChanged: onChanged,
    );
  }
}

class _VerificationChannelSelector extends StatelessWidget {
  const _VerificationChannelSelector({
    required this.selectedChannel,
    required this.onChanged,
  });

  final CustomerAuthenticationVerificationChannel selectedChannel;
  final ValueChanged<CustomerAuthenticationVerificationChannel> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<CustomerAuthenticationVerificationChannel>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(
          value: CustomerAuthenticationVerificationChannel.sms,
          icon: Icon(Icons.sms_outlined),
          label: Text('SMS'),
        ),
        ButtonSegment(
          value: CustomerAuthenticationVerificationChannel.whatsapp,
          icon: Icon(Icons.chat_outlined),
          label: Text('WhatsApp'),
        ),
        ButtonSegment(
          value: CustomerAuthenticationVerificationChannel.email,
          icon: Icon(Icons.alternate_email_rounded),
          label: Text('Email'),
        ),
      ],
      selected: {selectedChannel},
      onSelectionChanged: (channels) => onChanged(channels.single),
    );
  }
}

class _RegionChip extends StatelessWidget {
  const _RegionChip();

  @override
  Widget build(BuildContext context) {
    return Align(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FBF4),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFD5EFDE)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on_rounded,
              color: Color(0xFF16C35B),
            ),
            SizedBox(width: 10),
            Text(
              'Sua regiao: Charqueadas e arredores',
              style: TextStyle(
                color: Color(0xFF2E6A4F),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 10),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF2E6A4F),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialProviderButton extends StatelessWidget {
  const _SocialProviderButton({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(58),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class _OnboardingCallout extends StatelessWidget {
  const _OnboardingCallout();

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
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.groups_rounded,
              color: Color(0xFF16C35B),
              size: 34,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cadastre-se apenas quando for falar com um profissional',
                  style: TextStyle(
                    color: Color(0xFF13243C),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Sua conta e criada so na hora do contato. Sem pressao, do seu jeito.',
                  style: TextStyle(
                    color: Color(0xFF5E738E),
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

class _TrustBadge extends StatelessWidget {
  const _TrustBadge({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 164,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFEAF8EF),
            child: Icon(icon, color: const Color(0xFF16C35B)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF2F445F),
                fontSize: 15,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerificationCodeBoxes extends StatelessWidget {
  const _VerificationCodeBoxes({
    required this.verificationCode,
  });

  final String verificationCode;

  @override
  Widget build(BuildContext context) {
    final digits = verificationCode.padRight(4).split('');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var index = 0; index < 4; index++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index == 3 ? 0 : 12),
              child: Container(
                height: 112,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: index == verificationCode.length
                        ? const Color(0xFF16C35B)
                        : const Color(0xFFDCE4EE),
                    width: index == verificationCode.length ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    digits[index].trim().isEmpty ? '' : digits[index],
                    style: const TextStyle(
                      color: Color(0xFF13243C),
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
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
              style: TextStyle(
                color: Color(0xFF2F445F),
                fontSize: 16,
                height: 1.45,
              ),
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
      children: [
        const SizedBox(height: 36),
        const CircleAvatar(
          radius: 74,
          backgroundColor: Color(0xFFEAF8EF),
          child: Icon(
            Icons.check_rounded,
            size: 82,
            color: Color(0xFF16C35B),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Telefone verificado',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: const Color(0xFF13243C),
                fontWeight: FontWeight.w700,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          authenticationState.displayPhoneNumber,
          style: const TextStyle(
            color: Color(0xFF16C35B),
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
