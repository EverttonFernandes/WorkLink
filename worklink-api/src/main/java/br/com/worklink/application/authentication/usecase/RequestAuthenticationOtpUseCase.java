package br.com.worklink.application.authentication.usecase;

import br.com.worklink.application.authentication.port.CurrentTimePort;
import br.com.worklink.application.authentication.port.GenerateOneTimePasswordPort;
import br.com.worklink.application.authentication.port.SaveAuthenticationOtpChallengePort;
import br.com.worklink.application.security.port.ProtectSensitiveValuePort;
import br.com.worklink.application.security.port.ProtectedSensitiveValuePurpose;
import br.com.worklink.domain.authentication.AuthenticationOtpChallenge;

import java.time.Duration;
import java.time.Instant;
import java.util.List;

public class RequestAuthenticationOtpUseCase {

    private static final List<String> AVAILABLE_DELIVERY_CHANNELS = List.of("SMS", "WHATSAPP", "EMAIL");
    private static final String GENERIC_OTP_MESSAGE =
            "Se os dados puderem ser autenticados, um codigo sera enviado pelo canal escolhido.";

    private final GenerateOneTimePasswordPort generateOneTimePasswordPort;
    private final ProtectSensitiveValuePort protectSensitiveValuePort;
    private final SaveAuthenticationOtpChallengePort saveAuthenticationOtpChallengePort;
    private final CurrentTimePort currentTimePort;
    private final Duration otpDuration;

    public RequestAuthenticationOtpUseCase(
            GenerateOneTimePasswordPort generateOneTimePasswordPort,
            ProtectSensitiveValuePort protectSensitiveValuePort,
            SaveAuthenticationOtpChallengePort saveAuthenticationOtpChallengePort,
            CurrentTimePort currentTimePort,
            Duration otpDuration
    ) {
        this.generateOneTimePasswordPort = generateOneTimePasswordPort;
        this.protectSensitiveValuePort = protectSensitiveValuePort;
        this.saveAuthenticationOtpChallengePort = saveAuthenticationOtpChallengePort;
        this.currentTimePort = currentTimePort;
        this.otpDuration = otpDuration;
    }

    public AuthenticationOtpRequestResponse requestAuthenticationOtp(RequestAuthenticationOtpRequest request) {
        String normalizedPhoneNumber = AuthenticationPhoneNumberNormalizer.normalizePhoneNumber(request.phoneNumber());
        Instant currentInstant = currentTimePort.currentInstant();
        String oneTimePassword = generateOneTimePasswordPort.generateOneTimePassword();
        String oneTimePasswordHash = protectSensitiveValuePort.protectSensitiveValue(
                oneTimePassword,
                ProtectedSensitiveValuePurpose.ONE_TIME_PASSWORD
        );
        Instant expiresAt = currentInstant.plus(otpDuration);
        saveAuthenticationOtpChallengePort.saveAuthenticationOtpChallenge(AuthenticationOtpChallenge.requestOtpChallenge(
                normalizedPhoneNumber,
                oneTimePasswordHash,
                expiresAt,
                currentInstant
        ));
        return new AuthenticationOtpRequestResponse(GENERIC_OTP_MESSAGE, expiresAt, AVAILABLE_DELIVERY_CHANNELS, true);
    }
}
