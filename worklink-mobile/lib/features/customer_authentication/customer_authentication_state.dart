enum CustomerAuthenticationStep {
  phoneEntry,
  codeVerification,
  authenticated,
}

enum CustomerAuthenticationVerificationChannel {
  sms,
  whatsapp,
  email,
}

extension CustomerAuthenticationVerificationChannelText
    on CustomerAuthenticationVerificationChannel {
  String get apiValue {
    return switch (this) {
      CustomerAuthenticationVerificationChannel.sms => 'SMS',
      CustomerAuthenticationVerificationChannel.whatsapp => 'WHATSAPP',
      CustomerAuthenticationVerificationChannel.email => 'EMAIL',
    };
  }

  String get displayName {
    return switch (this) {
      CustomerAuthenticationVerificationChannel.sms => 'SMS',
      CustomerAuthenticationVerificationChannel.whatsapp => 'WhatsApp',
      CustomerAuthenticationVerificationChannel.email => 'email',
    };
  }
}

class CustomerAuthenticationState {
  const CustomerAuthenticationState({
    this.authenticationStep = CustomerAuthenticationStep.phoneEntry,
    this.phoneNumber = '',
    this.normalizedPhoneNumber = '',
    this.verificationChannel = CustomerAuthenticationVerificationChannel.sms,
    this.emailAddress = '',
    this.verificationCode = '',
    this.errorMessage,
    this.statusMessage,
    this.resendCount = 0,
  });

  final CustomerAuthenticationStep authenticationStep;
  final String phoneNumber;
  final String normalizedPhoneNumber;
  final CustomerAuthenticationVerificationChannel verificationChannel;
  final String emailAddress;
  final String verificationCode;
  final String? errorMessage;
  final String? statusMessage;
  final int resendCount;

  bool get authenticated =>
      authenticationStep == CustomerAuthenticationStep.authenticated;

  bool get canConfirmVerificationCode => verificationCode.length == 4;

  bool get emailAddressRequired =>
      verificationChannel == CustomerAuthenticationVerificationChannel.email;

  String get normalizedEmailAddress => emailAddress.trim().toLowerCase();

  String get verificationChannelDisplayName => verificationChannel.displayName;

  String get verificationDestination {
    if (emailAddressRequired) {
      return normalizedEmailAddress;
    }
    return displayPhoneNumber;
  }

  String get verificationChannelSummary => 'SMS, WhatsApp ou email';

  String get verificationChannelStatusMessage {
    return 'Enviamos um codigo por ${verificationChannel.displayName}.';
  }

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
    CustomerAuthenticationVerificationChannel? verificationChannel,
    String? emailAddress,
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
      normalizedPhoneNumber:
          normalizedPhoneNumber ?? this.normalizedPhoneNumber,
      verificationChannel: verificationChannel ?? this.verificationChannel,
      emailAddress: emailAddress ?? this.emailAddress,
      verificationCode: verificationCode ?? this.verificationCode,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      statusMessage:
          clearStatusMessage ? null : statusMessage ?? this.statusMessage,
      resendCount: resendCount ?? this.resendCount,
    );
  }
}
