enum CustomerAuthenticationStep {
  phoneEntry,
  codeVerification,
  authenticated,
}

class CustomerAuthenticationState {
  const CustomerAuthenticationState({
    this.authenticationStep = CustomerAuthenticationStep.phoneEntry,
    this.phoneNumber = '',
    this.normalizedPhoneNumber = '',
    this.verificationCode = '',
    this.errorMessage,
    this.statusMessage,
    this.resendCount = 0,
  });

  final CustomerAuthenticationStep authenticationStep;
  final String phoneNumber;
  final String normalizedPhoneNumber;
  final String verificationCode;
  final String? errorMessage;
  final String? statusMessage;
  final int resendCount;

  bool get authenticated =>
      authenticationStep == CustomerAuthenticationStep.authenticated;

  bool get canConfirmVerificationCode => verificationCode.length == 4;

  String get displayPhoneNumber {
    if (normalizedPhoneNumber.length == 11) {
      return '(${normalizedPhoneNumber.substring(0, 2)}) '
          '${normalizedPhoneNumber.substring(2, 3)} '
          '${normalizedPhoneNumber.substring(3, 7)}-'
          '${normalizedPhoneNumber.substring(7)}';
    }
    if (normalizedPhoneNumber.length == 10) {
      return '(${normalizedPhoneNumber.substring(0, 2)}) '
          '${normalizedPhoneNumber.substring(2, 6)}-'
          '${normalizedPhoneNumber.substring(6)}';
    }
    return phoneNumber;
  }

  CustomerAuthenticationState copyWith({
    CustomerAuthenticationStep? authenticationStep,
    String? phoneNumber,
    String? normalizedPhoneNumber,
    String? verificationCode,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? statusMessage,
    bool clearStatusMessage = false,
    int? resendCount,
  }) {
    return CustomerAuthenticationState(
      authenticationStep: authenticationStep ?? this.authenticationStep,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      normalizedPhoneNumber: normalizedPhoneNumber ?? this.normalizedPhoneNumber,
      verificationCode: verificationCode ?? this.verificationCode,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      statusMessage:
          clearStatusMessage ? null : statusMessage ?? this.statusMessage,
      resendCount: resendCount ?? this.resendCount,
    );
  }
}
