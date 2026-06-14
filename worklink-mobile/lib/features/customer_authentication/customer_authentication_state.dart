enum CustomerAuthenticationMode {
  signIn,
  signUp,
  passwordRecoveryRequest,
  passwordRecoveryReset,
  authenticated,
}

enum CustomerAuthenticationOperationStatus {
  idle,
  loading,
  success,
  error,
}

// Kept for source compatibility while the future OTP channels remain disabled.
enum CustomerAuthenticationVerificationChannel {
  sms,
  whatsapp,
  email,
}

extension CustomerAuthenticationVerificationChannelText
    on CustomerAuthenticationVerificationChannel {
  String get apiValue => switch (this) {
        CustomerAuthenticationVerificationChannel.sms => 'SMS',
        CustomerAuthenticationVerificationChannel.whatsapp => 'WHATSAPP',
        CustomerAuthenticationVerificationChannel.email => 'EMAIL',
      };
}

class CustomerAuthenticationState {
  const CustomerAuthenticationState({
    this.mode = CustomerAuthenticationMode.signIn,
    this.operationStatus = CustomerAuthenticationOperationStatus.idle,
    this.fullName = '',
    this.phoneNumber = '',
    this.emailAddress = '',
    this.password = '',
    this.passwordConfirmation = '',
    this.recoveryToken = '',
    this.legalTermsAccepted = false,
    this.passwordObscured = true,
    this.passwordConfirmationObscured = true,
    this.phoneVerified = false,
    this.authenticatedEmailAddress = '',
    this.errorMessage,
    this.statusMessage,
  });

  final CustomerAuthenticationMode mode;
  final CustomerAuthenticationOperationStatus operationStatus;
  final String fullName;
  final String phoneNumber;
  final String emailAddress;
  final String password;
  final String passwordConfirmation;
  final String recoveryToken;
  final bool legalTermsAccepted;
  final bool passwordObscured;
  final bool passwordConfirmationObscured;
  final bool phoneVerified;
  final String authenticatedEmailAddress;
  final String? errorMessage;
  final String? statusMessage;

  bool get authenticated => mode == CustomerAuthenticationMode.authenticated;

  bool get loading =>
      operationStatus == CustomerAuthenticationOperationStatus.loading;

  String get normalizedEmailAddress => emailAddress.trim().toLowerCase();

  String get normalizedPhoneNumber {
    final digits = phoneNumber.replaceAll(RegExp('[^0-9]'), '');
    if (digits.length > 11 && digits.startsWith('55')) {
      return digits.substring(2);
    }
    return digits;
  }

  String get phoneVerificationLabel =>
      phoneVerified ? 'Celular verificado' : 'Celular não verificado';

  CustomerAuthenticationState copyWith({
    CustomerAuthenticationMode? mode,
    CustomerAuthenticationOperationStatus? operationStatus,
    String? fullName,
    String? phoneNumber,
    String? emailAddress,
    String? password,
    String? passwordConfirmation,
    String? recoveryToken,
    bool? legalTermsAccepted,
    bool? passwordObscured,
    bool? passwordConfirmationObscured,
    bool? phoneVerified,
    String? authenticatedEmailAddress,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? statusMessage,
    bool clearStatusMessage = false,
  }) {
    return CustomerAuthenticationState(
      mode: mode ?? this.mode,
      operationStatus: operationStatus ?? this.operationStatus,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailAddress: emailAddress ?? this.emailAddress,
      password: password ?? this.password,
      passwordConfirmation: passwordConfirmation ?? this.passwordConfirmation,
      recoveryToken: recoveryToken ?? this.recoveryToken,
      legalTermsAccepted: legalTermsAccepted ?? this.legalTermsAccepted,
      passwordObscured: passwordObscured ?? this.passwordObscured,
      passwordConfirmationObscured:
          passwordConfirmationObscured ?? this.passwordConfirmationObscured,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      authenticatedEmailAddress:
          authenticatedEmailAddress ?? this.authenticatedEmailAddress,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      statusMessage:
          clearStatusMessage ? null : statusMessage ?? this.statusMessage,
    );
  }
}
