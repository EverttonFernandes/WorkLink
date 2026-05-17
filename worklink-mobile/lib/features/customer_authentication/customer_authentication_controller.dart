import 'package:flutter/foundation.dart';

import 'customer_authentication_state.dart';

typedef RequestCustomerAuthenticationCode = Future<void> Function(
  String phoneNumber,
);

typedef ConfirmCustomerAuthenticationCode = Future<void> Function({
  required String phoneNumber,
  required String verificationCode,
});

class CustomerAuthenticationController extends ChangeNotifier {
  CustomerAuthenticationController({
    this.expectedVerificationCode = '1234',
    this.requestCustomerAuthenticationCode,
    this.confirmCustomerAuthenticationCode,
  });

  final String expectedVerificationCode;
  final RequestCustomerAuthenticationCode? requestCustomerAuthenticationCode;
  final ConfirmCustomerAuthenticationCode? confirmCustomerAuthenticationCode;

  CustomerAuthenticationState _state = const CustomerAuthenticationState();

  CustomerAuthenticationState get state => _state;

  void changePhoneNumber(String phoneNumber) {
    _updateState(
      _state.copyWith(
        phoneNumber: phoneNumber,
        clearErrorMessage: true,
        clearStatusMessage: true,
      ),
    );
  }

  bool requestVerificationCode() {
    final normalizedPhoneNumber = _normalizePhoneNumber(_state.phoneNumber);
    if (!_isValidBrazilianPhoneNumber(normalizedPhoneNumber)) {
      _updateState(
        _state.copyWith(
          authenticationStep: CustomerAuthenticationStep.phoneEntry,
          normalizedPhoneNumber: normalizedPhoneNumber,
          errorMessage: 'Informe um telefone valido.',
          clearStatusMessage: true,
        ),
      );
      return false;
    }

    _updateState(
      _state.copyWith(
        authenticationStep: CustomerAuthenticationStep.codeVerification,
        normalizedPhoneNumber: normalizedPhoneNumber,
        verificationCode: '',
        statusMessage: 'Enviamos um codigo para seu telefone.',
        clearErrorMessage: true,
      ),
    );
    return true;
  }

  Future<bool> requestVerificationCodeAsync() async {
    final normalizedPhoneNumber = _normalizePhoneNumber(_state.phoneNumber);
    if (!_isValidBrazilianPhoneNumber(normalizedPhoneNumber)) {
      return requestVerificationCode();
    }

    final requestAuthenticationCode = requestCustomerAuthenticationCode;
    if (requestAuthenticationCode == null) {
      return requestVerificationCode();
    }

    try {
      await requestAuthenticationCode(normalizedPhoneNumber);
      _updateState(
        _state.copyWith(
          authenticationStep: CustomerAuthenticationStep.codeVerification,
          normalizedPhoneNumber: normalizedPhoneNumber,
          verificationCode: '',
          statusMessage: 'Enviamos um codigo para seu telefone.',
          clearErrorMessage: true,
        ),
      );
      return true;
    } catch (_) {
      _updateState(
        _state.copyWith(
          authenticationStep: CustomerAuthenticationStep.phoneEntry,
          normalizedPhoneNumber: normalizedPhoneNumber,
          errorMessage: 'Nao foi possivel enviar o codigo agora.',
          clearStatusMessage: true,
        ),
      );
      return false;
    }
  }

  void changeVerificationCode(String verificationCode) {
    final verificationCodeDigits = verificationCode.replaceAll(
      RegExp('[^0-9]'),
      '',
    );
    final verificationCodeLength =
        verificationCodeDigits.length > 4 ? 4 : verificationCodeDigits.length;
    final sanitizedVerificationCode = verificationCodeDigits.substring(
      0,
      verificationCodeLength,
    );
    _updateState(
      _state.copyWith(
        verificationCode: sanitizedVerificationCode,
        clearErrorMessage: true,
      ),
    );
  }

  bool confirmVerificationCode() {
    if (_state.verificationCode != expectedVerificationCode) {
      _updateState(
        _state.copyWith(
          errorMessage: 'Nao foi possivel concluir a autenticacao.',
          clearStatusMessage: true,
        ),
      );
      return false;
    }

    _updateState(
      _state.copyWith(
        authenticationStep: CustomerAuthenticationStep.authenticated,
        statusMessage: 'Telefone verificado.',
        clearErrorMessage: true,
      ),
    );
    return true;
  }

  Future<bool> confirmVerificationCodeAsync() async {
    final confirmAuthenticationCode = confirmCustomerAuthenticationCode;
    if (confirmAuthenticationCode == null) {
      return confirmVerificationCode();
    }

    try {
      await confirmAuthenticationCode(
        phoneNumber: _state.normalizedPhoneNumber,
        verificationCode: _state.verificationCode,
      );
      _updateState(
        _state.copyWith(
          authenticationStep: CustomerAuthenticationStep.authenticated,
          statusMessage: 'Telefone verificado.',
          clearErrorMessage: true,
        ),
      );
      return true;
    } catch (_) {
      _updateState(
        _state.copyWith(
          errorMessage: 'Nao foi possivel concluir a autenticacao.',
          clearStatusMessage: true,
        ),
      );
      return false;
    }
  }

  void resendVerificationCode() {
    if (_state.authenticationStep !=
        CustomerAuthenticationStep.codeVerification) {
      return;
    }
    _updateState(
      _state.copyWith(
        verificationCode: '',
        resendCount: _state.resendCount + 1,
        statusMessage: 'Enviamos um novo codigo para seu telefone.',
        clearErrorMessage: true,
      ),
    );
  }

  void editPhoneNumber() {
    _updateState(
      _state.copyWith(
        authenticationStep: CustomerAuthenticationStep.phoneEntry,
        verificationCode: '',
        clearErrorMessage: true,
        clearStatusMessage: true,
      ),
    );
  }

  void _updateState(CustomerAuthenticationState state) {
    _state = state;
    notifyListeners();
  }

  String _normalizePhoneNumber(String phoneNumber) {
    final onlyDigits = phoneNumber.replaceAll(RegExp('[^0-9]'), '');
    if (onlyDigits.length > 11 && onlyDigits.startsWith('55')) {
      return onlyDigits.substring(2);
    }
    return onlyDigits;
  }

  bool _isValidBrazilianPhoneNumber(String phoneNumber) {
    return phoneNumber.length == 10 || phoneNumber.length == 11;
  }
}
