import 'package:flutter/foundation.dart';

import 'customer_authentication_state.dart';

typedef AuthenticateWithEmailAndPassword = Future<void> Function({
  required String emailAddress,
  required String password,
});

typedef RegisterLocalAccount = Future<void> Function({
  required String fullName,
  required String phoneNumber,
  required String emailAddress,
  required String password,
  required String passwordConfirmation,
  required bool legalTermsAccepted,
});

typedef RequestPasswordRecovery = Future<void> Function({
  required String emailAddress,
});

typedef ResetPassword = Future<void> Function({
  required String recoveryToken,
  required String newPassword,
  required String newPasswordConfirmation,
});

class CustomerAuthenticationController extends ChangeNotifier {
  CustomerAuthenticationController({
    this.authenticateWithEmailAndPassword,
    this.registerLocalAccount,
    this.requestPasswordRecovery,
    this.resetPassword,
    CustomerAuthenticationState initialState =
        const CustomerAuthenticationState(),
  }) : _state = initialState;

  final AuthenticateWithEmailAndPassword? authenticateWithEmailAndPassword;
  final RegisterLocalAccount? registerLocalAccount;
  final RequestPasswordRecovery? requestPasswordRecovery;
  final ResetPassword? resetPassword;

  CustomerAuthenticationState _state;

  CustomerAuthenticationState get state => _state;

  void selectMode(CustomerAuthenticationMode mode) {
    _update(
      _state.copyWith(
        mode: mode,
        operationStatus: CustomerAuthenticationOperationStatus.idle,
        password: '',
        passwordConfirmation: '',
        recoveryToken: '',
        clearErrorMessage: true,
        clearStatusMessage: true,
      ),
    );
  }

  void openPasswordRecovery() {
    selectMode(CustomerAuthenticationMode.passwordRecoveryRequest);
  }

  void changeFullName(String value) => _change(fullName: value);

  void changePhoneNumber(String value) => _change(phoneNumber: value);

  void changeEmailAddress(String value) => _change(emailAddress: value);

  void changePassword(String value) => _change(password: value);

  void changePasswordConfirmation(String value) =>
      _change(passwordConfirmation: value);

  void changeRecoveryToken(String value) =>
      _change(recoveryToken: value.trim());

  void changeLegalTermsAccepted(bool value) =>
      _change(legalTermsAccepted: value);

  void togglePasswordVisibility() {
    _update(_state.copyWith(passwordObscured: !_state.passwordObscured));
  }

  void togglePasswordConfirmationVisibility() {
    _update(
      _state.copyWith(
        passwordConfirmationObscured: !_state.passwordConfirmationObscured,
      ),
    );
  }

  Future<bool> signIn() async {
    if (!_validEmail(_state.normalizedEmailAddress) ||
        _state.password.isEmpty) {
      return _validationFailure(
        'Informe um email válido e sua senha.',
      );
    }
    return _runAuthentication(
      () async {
        await authenticateWithEmailAndPassword?.call(
          emailAddress: _state.normalizedEmailAddress,
          password: _state.password,
        );
      },
      failureMessage:
          'Não foi possível entrar. Confira seus dados e tente novamente.',
    );
  }

  Future<bool> signUp() async {
    if (_state.fullName.trim().split(RegExp(r'\s+')).length < 2 ||
        !_validBrazilianPhone(_state.normalizedPhoneNumber) ||
        !_validEmail(_state.normalizedEmailAddress) ||
        _state.password.length < 12 ||
        _state.password != _state.passwordConfirmation ||
        !_state.legalTermsAccepted) {
      return _validationFailure(
        'Revise seus dados, use uma senha com pelo menos 12 caracteres e aceite os termos.',
      );
    }
    return _runAuthentication(
      () async {
        await registerLocalAccount?.call(
          fullName: _state.fullName.trim(),
          phoneNumber: _state.normalizedPhoneNumber,
          emailAddress: _state.normalizedEmailAddress,
          password: _state.password,
          passwordConfirmation: _state.passwordConfirmation,
          legalTermsAccepted: _state.legalTermsAccepted,
        );
      },
      failureMessage:
          'Não foi possível criar a conta agora. Revise os dados e tente novamente.',
    );
  }

  Future<bool> requestRecovery() async {
    if (!_validEmail(_state.normalizedEmailAddress)) {
      return _validationFailure('Informe um email válido.');
    }
    _startLoading();
    try {
      await requestPasswordRecovery?.call(
        emailAddress: _state.normalizedEmailAddress,
      );
      _update(
        _state.copyWith(
          mode: CustomerAuthenticationMode.passwordRecoveryReset,
          operationStatus: CustomerAuthenticationOperationStatus.success,
          statusMessage:
              'Se existir uma conta para este email, enviaremos as instruções de recuperação.',
          clearErrorMessage: true,
        ),
      );
      return true;
    } catch (_) {
      _update(
        _state.copyWith(
          operationStatus: CustomerAuthenticationOperationStatus.error,
          errorMessage:
              'Não foi possível solicitar a recuperação agora. Tente novamente.',
          clearStatusMessage: true,
        ),
      );
      return false;
    }
  }

  Future<bool> completePasswordReset() async {
    if (_state.recoveryToken.trim().isEmpty ||
        _state.password.length < 12 ||
        _state.password != _state.passwordConfirmation) {
      return _validationFailure(
        'Informe o código recebido e uma nova senha com pelo menos 12 caracteres.',
      );
    }
    _startLoading();
    try {
      await resetPassword?.call(
        recoveryToken: _state.recoveryToken.trim(),
        newPassword: _state.password,
        newPasswordConfirmation: _state.passwordConfirmation,
      );
      _update(
        _state.copyWith(
          mode: CustomerAuthenticationMode.signIn,
          operationStatus: CustomerAuthenticationOperationStatus.success,
          password: '',
          passwordConfirmation: '',
          recoveryToken: '',
          statusMessage: 'Senha alterada. Entre novamente.',
          clearErrorMessage: true,
        ),
      );
      return true;
    } catch (_) {
      _update(
        _state.copyWith(
          operationStatus: CustomerAuthenticationOperationStatus.error,
          errorMessage:
              'Não foi possível alterar a senha. Solicite um novo código.',
          clearStatusMessage: true,
        ),
      );
      return false;
    }
  }

  Future<bool> _runAuthentication(
    Future<void> Function() operation, {
    required String failureMessage,
  }) async {
    _startLoading();
    try {
      await operation();
      _update(
        _state.copyWith(
          mode: CustomerAuthenticationMode.authenticated,
          operationStatus: CustomerAuthenticationOperationStatus.success,
          authenticatedEmailAddress: _state.normalizedEmailAddress,
          statusMessage: 'Conta autenticada com segurança.',
          clearErrorMessage: true,
        ),
      );
      return true;
    } catch (_) {
      _update(
        _state.copyWith(
          operationStatus: CustomerAuthenticationOperationStatus.error,
          errorMessage: failureMessage,
          clearStatusMessage: true,
        ),
      );
      return false;
    }
  }

  void _change({
    String? fullName,
    String? phoneNumber,
    String? emailAddress,
    String? password,
    String? passwordConfirmation,
    String? recoveryToken,
    bool? legalTermsAccepted,
  }) {
    _update(
      _state.copyWith(
        fullName: fullName,
        phoneNumber: phoneNumber,
        emailAddress: emailAddress,
        password: password,
        passwordConfirmation: passwordConfirmation,
        recoveryToken: recoveryToken,
        legalTermsAccepted: legalTermsAccepted,
        operationStatus: CustomerAuthenticationOperationStatus.idle,
        clearErrorMessage: true,
        clearStatusMessage: true,
      ),
    );
  }

  bool _validationFailure(String message) {
    _update(
      _state.copyWith(
        operationStatus: CustomerAuthenticationOperationStatus.error,
        errorMessage: message,
        clearStatusMessage: true,
      ),
    );
    return false;
  }

  void _startLoading() {
    _update(
      _state.copyWith(
        operationStatus: CustomerAuthenticationOperationStatus.loading,
        clearErrorMessage: true,
        clearStatusMessage: true,
      ),
    );
  }

  bool _validEmail(String value) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);

  bool _validBrazilianPhone(String value) =>
      value.length == 10 || value.length == 11;

  void _update(CustomerAuthenticationState state) {
    _state = state;
    notifyListeners();
  }
}
