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
    return AnimatedBuilder(
      animation: customerAuthenticationController,
      builder: (context, _) {
        final state = customerAuthenticationController.state;
        return Scaffold(
          backgroundColor: const Color(0xFFF8FBFF),
          appBar: AppBar(title: const Text('Profissional Perto')),
          body: SafeArea(
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                const _BrandHeader(),
                const SizedBox(height: 22),
                if (state.mode == CustomerAuthenticationMode.authenticated)
                  _AuthenticatedContent(state: state)
                else ...[
                  const _HeroCopy(),
                  const SizedBox(height: 18),
                  const _RegionChip(),
                  const SizedBox(height: 22),
                  _AuthenticationCard(
                    controller: customerAuthenticationController,
                    state: state,
                    onAuthenticationCompleted: onAuthenticationCompleted,
                  ),
                  const SizedBox(height: 20),
                  const _SecurityCallout(),
                  const SizedBox(height: 20),
                  const _LegalFooter(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AuthenticationCard extends StatelessWidget {
  const _AuthenticationCard({
    required this.controller,
    required this.state,
    required this.onAuthenticationCompleted,
  });

  final CustomerAuthenticationController controller;
  final CustomerAuthenticationState state;
  final ValueChanged<String>? onAuthenticationCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          if (state.mode == CustomerAuthenticationMode.signIn ||
              state.mode == CustomerAuthenticationMode.signUp) ...[
            _AuthenticationModeSelector(controller: controller, state: state),
            const SizedBox(height: 20),
          ],
          if (state.mode == CustomerAuthenticationMode.signIn)
            _SignInForm(
              controller: controller,
              state: state,
              onAuthenticationCompleted: onAuthenticationCompleted,
            )
          else if (state.mode == CustomerAuthenticationMode.signUp)
            _SignUpForm(
              controller: controller,
              state: state,
              onAuthenticationCompleted: onAuthenticationCompleted,
            )
          else if (state.mode ==
              CustomerAuthenticationMode.passwordRecoveryRequest)
            _RecoveryRequestForm(controller: controller, state: state)
          else
            _RecoveryResetForm(controller: controller, state: state),
          if (state.errorMessage != null) ...[
            const SizedBox(height: 14),
            _FeedbackMessage(
              icon: Icons.error_outline_rounded,
              message: state.errorMessage!,
              color: Theme.of(context).colorScheme.error,
            ),
          ],
          if (state.statusMessage != null) ...[
            const SizedBox(height: 14),
            _FeedbackMessage(
              icon: Icons.info_outline_rounded,
              message: state.statusMessage!,
              color: const Color(0xFF176B3A),
            ),
          ],
        ],
      ),
    );
  }
}

class _AuthenticationModeSelector extends StatelessWidget {
  const _AuthenticationModeSelector({
    required this.controller,
    required this.state,
  });

  final CustomerAuthenticationController controller;
  final CustomerAuthenticationState state;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<CustomerAuthenticationMode>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(
          value: CustomerAuthenticationMode.signIn,
          label: Text(
            'Entrar',
            key: ValueKey('sign-in-mode-button'),
          ),
          icon: Icon(Icons.login_rounded),
        ),
        ButtonSegment(
          value: CustomerAuthenticationMode.signUp,
          label: Text(
            'Criar conta',
            key: ValueKey('sign-up-mode-button'),
          ),
          icon: Icon(Icons.person_add_alt_1_rounded),
        ),
      ],
      selected: {state.mode},
      onSelectionChanged: state.loading
          ? null
          : (selection) => controller.selectMode(selection.single),
    );
  }
}

class _SignInForm extends StatelessWidget {
  const _SignInForm({
    required this.controller,
    required this.state,
    required this.onAuthenticationCompleted,
  });

  final CustomerAuthenticationController controller;
  final CustomerAuthenticationState state;
  final ValueChanged<String>? onAuthenticationCompleted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _FormTitle(
          icon: Icons.lock_open_rounded,
          title: 'Acesse sua conta',
          subtitle: 'Use seu email e sua senha para continuar.',
        ),
        const SizedBox(height: 18),
        _EmailField(onChanged: controller.changeEmailAddress),
        const SizedBox(height: 14),
        _PasswordField(
          fieldKey: const ValueKey('authentication-password-field'),
          label: 'Senha',
          obscureText: state.passwordObscured,
          visibilityKey: const ValueKey('toggle-password-visibility'),
          onChanged: controller.changePassword,
          onToggleVisibility: controller.togglePasswordVisibility,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: state.loading ? null : controller.openPasswordRecovery,
            child: const Text('Esqueci minha senha'),
          ),
        ),
        const SizedBox(height: 4),
        _PrimaryActionButton(
          key: const ValueKey('sign-in-button'),
          loading: state.loading,
          icon: Icons.arrow_forward_rounded,
          label: 'Entrar',
          onPressed: () async {
            final accepted = await controller.signIn();
            if (accepted) {
              onAuthenticationCompleted?.call(
                controller.state.authenticatedEmailAddress,
              );
            }
            return accepted;
          },
        ),
      ],
    );
  }
}

class _SignUpForm extends StatelessWidget {
  const _SignUpForm({
    required this.controller,
    required this.state,
    required this.onAuthenticationCompleted,
  });

  final CustomerAuthenticationController controller;
  final CustomerAuthenticationState state;
  final ValueChanged<String>? onAuthenticationCompleted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _FormTitle(
          icon: Icons.person_add_alt_1_rounded,
          title: 'Crie sua conta',
          subtitle: 'Cadastre-se somente quando precisar falar com alguém.',
        ),
        const SizedBox(height: 18),
        _TextField(
          fieldKey: const ValueKey('authentication-full-name-field'),
          label: 'Nome completo',
          icon: Icons.person_outline_rounded,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.name],
          onChanged: controller.changeFullName,
        ),
        const SizedBox(height: 14),
        _TextField(
          fieldKey: const ValueKey('authentication-phone-field'),
          label: 'Celular',
          hintText: '(51) 9 9999-9999',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.telephoneNumber],
          onChanged: controller.changePhoneNumber,
        ),
        const SizedBox(height: 6),
        const Text(
          'Celular não verificado',
          style: TextStyle(
            color: Color(0xFF6A7D96),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 14),
        _EmailField(onChanged: controller.changeEmailAddress),
        const SizedBox(height: 14),
        _PasswordField(
          fieldKey: const ValueKey('authentication-password-field'),
          label: 'Senha',
          obscureText: state.passwordObscured,
          visibilityKey: const ValueKey('toggle-password-visibility'),
          onChanged: controller.changePassword,
          onToggleVisibility: controller.togglePasswordVisibility,
        ),
        const SizedBox(height: 14),
        _PasswordField(
          fieldKey:
              const ValueKey('authentication-password-confirmation-field'),
          label: 'Confirmar senha',
          obscureText: state.passwordConfirmationObscured,
          visibilityKey:
              const ValueKey('toggle-password-confirmation-visibility'),
          onChanged: controller.changePasswordConfirmation,
          onToggleVisibility: controller.togglePasswordConfirmationVisibility,
        ),
        const SizedBox(height: 8),
        const Text(
          'Use pelo menos 12 caracteres. Senhas longas e gerenciadores são bem-vindos.',
          style: TextStyle(color: Color(0xFF6A7D96), height: 1.35),
        ),
        const SizedBox(height: 10),
        Semantics(
          label: 'Aceitar Termos de Uso e Política de Privacidade',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: state.legalTermsAccepted,
                onChanged: state.loading
                    ? null
                    : (value) =>
                        controller.changeLegalTermsAccepted(value ?? false),
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'Li e aceito os Termos de Uso e a Política de Privacidade.',
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _PrimaryActionButton(
          key: const ValueKey('sign-up-button'),
          loading: state.loading,
          icon: Icons.person_add_alt_1_rounded,
          label: 'Criar conta',
          onPressed: () async {
            final accepted = await controller.signUp();
            if (accepted) {
              onAuthenticationCompleted?.call(
                controller.state.authenticatedEmailAddress,
              );
            }
            return accepted;
          },
        ),
      ],
    );
  }
}

class _RecoveryRequestForm extends StatelessWidget {
  const _RecoveryRequestForm({
    required this.controller,
    required this.state,
  });

  final CustomerAuthenticationController controller;
  final CustomerAuthenticationState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _FormTitle(
          icon: Icons.mark_email_read_outlined,
          title: 'Recuperar acesso',
          subtitle:
              'Informe seu email. A resposta será a mesma exista ou não uma conta.',
        ),
        const SizedBox(height: 18),
        _EmailField(onChanged: controller.changeEmailAddress),
        const SizedBox(height: 18),
        _PrimaryActionButton(
          key: const ValueKey('request-recovery-button'),
          loading: state.loading,
          icon: Icons.send_outlined,
          label: 'Enviar instruções',
          onPressed: controller.requestRecovery,
        ),
        TextButton.icon(
          onPressed: state.loading
              ? null
              : () => controller.selectMode(CustomerAuthenticationMode.signIn),
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text('Voltar para entrar'),
        ),
      ],
    );
  }
}

class _RecoveryResetForm extends StatelessWidget {
  const _RecoveryResetForm({
    required this.controller,
    required this.state,
  });

  final CustomerAuthenticationController controller;
  final CustomerAuthenticationState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _FormTitle(
          icon: Icons.password_rounded,
          title: 'Definir nova senha',
          subtitle: 'Use o código recebido por email e escolha uma nova senha.',
        ),
        const SizedBox(height: 18),
        _TextField(
          fieldKey: const ValueKey('recovery-token-field'),
          label: 'Código de recuperação',
          icon: Icons.key_rounded,
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.next,
          onChanged: controller.changeRecoveryToken,
        ),
        const SizedBox(height: 14),
        _PasswordField(
          fieldKey: const ValueKey('authentication-password-field'),
          label: 'Nova senha',
          obscureText: state.passwordObscured,
          visibilityKey: const ValueKey('toggle-password-visibility'),
          onChanged: controller.changePassword,
          onToggleVisibility: controller.togglePasswordVisibility,
        ),
        const SizedBox(height: 14),
        _PasswordField(
          fieldKey:
              const ValueKey('authentication-password-confirmation-field'),
          label: 'Confirmar nova senha',
          obscureText: state.passwordConfirmationObscured,
          visibilityKey:
              const ValueKey('toggle-password-confirmation-visibility'),
          onChanged: controller.changePasswordConfirmation,
          onToggleVisibility: controller.togglePasswordConfirmationVisibility,
        ),
        const SizedBox(height: 18),
        _PrimaryActionButton(
          key: const ValueKey('reset-password-button'),
          loading: state.loading,
          icon: Icons.check_rounded,
          label: 'Alterar senha',
          onPressed: controller.completePasswordReset,
        ),
        TextButton(
          onPressed: state.loading ? null : controller.openPasswordRecovery,
          child: const Text('Solicitar novo código'),
        ),
      ],
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.fieldKey,
    required this.label,
    required this.icon,
    required this.onChanged,
    this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
  });

  final Key fieldKey;
  final String label;
  final String? hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: fieldKey,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      autofillHints: autofillHints,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      ),
      onChanged: onChanged,
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return _TextField(
      fieldKey: const ValueKey('authentication-email-field'),
      label: 'Email',
      hintText: 'voce@email.com',
      icon: Icons.alternate_email_rounded,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      onChanged: onChanged,
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.fieldKey,
    required this.label,
    required this.obscureText,
    required this.visibilityKey,
    required this.onChanged,
    required this.onToggleVisibility,
  });

  final Key fieldKey;
  final String label;
  final bool obscureText;
  final Key visibilityKey;
  final ValueChanged<String> onChanged;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: fieldKey,
      obscureText: obscureText,
      enableSuggestions: false,
      autocorrect: false,
      autofillHints: const [AutofillHints.password],
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          key: visibilityKey,
          tooltip: obscureText ? 'Mostrar senha' : 'Ocultar senha',
          onPressed: onToggleVisibility,
          icon: Icon(
            obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      ),
      onChanged: onChanged,
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    super.key,
    required this.loading,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final bool loading;
  final IconData icon;
  final String label;
  final Future<bool> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: loading ? null : onPressed,
      icon: loading
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon),
      label: Text(loading ? 'Aguarde...' : label),
    );
  }
}

class _FormTitle extends StatelessWidget {
  const _FormTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: const Color(0xFFEAF8EF),
          child: Icon(icon, color: const Color(0xFF16C35B)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF13243C),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF6A7D96),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeedbackMessage extends StatelessWidget {
  const _FeedbackMessage({
    required this.icon,
    required this.message,
    required this.color,
  });

  final IconData icon;
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Color(0xFF16C35B),
          child: Icon(Icons.verified_rounded, color: Colors.white, size: 30),
        ),
        SizedBox(width: 14),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'profissional',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF13243C),
                  ),
                ),
              ),
              Text(
                'perto',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF16C35B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF13243C),
                  height: 1.12,
                ),
            children: const [
              TextSpan(text: 'Encontre profissionais\n'),
              TextSpan(
                text: 'perto de você',
                style: TextStyle(color: Color(0xFF16C35B)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Acesse sua conta somente quando precisar falar com um profissional.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF6A7D96), height: 1.45),
        ),
      ],
    );
  }
}

class _RegionChip extends StatelessWidget {
  const _RegionChip();

  @override
  Widget build(BuildContext context) {
    return Align(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FBF4),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFD5EFDE)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on_rounded, color: Color(0xFF16C35B)),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Sua região: Charqueadas e arredores',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Color(0xFF2E6A4F)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecurityCallout extends StatelessWidget {
  const _SecurityCallout();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5FBF7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD4EFDE)),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified_user_outlined, color: Color(0xFF16C35B)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Sua senha é protegida e nunca deve ser compartilhada.',
              style: TextStyle(color: Color(0xFF2F445F), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalFooter extends StatelessWidget {
  const _LegalFooter();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.lock_outline_rounded, color: Color(0xFF7D8FA8)),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'Seus dados são usados conforme os Termos de Uso e a Política de Privacidade.',
            style: TextStyle(color: Color(0xFF6A7D96), height: 1.45),
          ),
        ),
      ],
    );
  }
}

class _AuthenticatedContent extends StatelessWidget {
  const _AuthenticatedContent({required this.state});

  final CustomerAuthenticationState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        const CircleAvatar(
          radius: 62,
          backgroundColor: Color(0xFFEAF8EF),
          child: Icon(Icons.check_rounded, size: 70, color: Color(0xFF16C35B)),
        ),
        const SizedBox(height: 24),
        Text(
          'Conta autenticada',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: const Color(0xFF13243C),
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          state.authenticatedEmailAddress,
          style: const TextStyle(color: Color(0xFF16C35B), fontSize: 18),
        ),
      ],
    );
  }
}
