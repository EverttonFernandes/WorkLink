package br.com.worklink.application.authentication.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.authentication.port.AuthenticationOtpDeliveryRequest;
import br.com.worklink.application.authentication.port.CurrentTimePort;
import br.com.worklink.application.authentication.port.DeliverAuthenticationOtpPort;
import br.com.worklink.application.authentication.port.GenerateOneTimePasswordPort;
import br.com.worklink.application.authentication.port.LoadActiveAuthenticationOtpChallengePort;
import br.com.worklink.application.authentication.port.SaveAuthenticationOtpChallengePort;
import br.com.worklink.application.security.port.ProtectSensitiveValuePort;
import br.com.worklink.application.security.port.ProtectedSensitiveValuePurpose;
import br.com.worklink.domain.authentication.AuthenticationOtpChallenge;

import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.util.Locale;
import java.util.Optional;

public class RequestAuthenticationOtpUseCase {

    private static final String GENERIC_OTP_MESSAGE =
            "Se os dados puderem ser autenticados, um codigo sera enviado pelo canal escolhido.";

    private final GenerateOneTimePasswordPort generateOneTimePasswordPort;
    private final ProtectSensitiveValuePort protectSensitiveValuePort;
    private final SaveAuthenticationOtpChallengePort saveAuthenticationOtpChallengePort;
    private final LoadActiveAuthenticationOtpChallengePort loadActiveAuthenticationOtpChallengePort;
    private final DeliverAuthenticationOtpPort deliverAuthenticationOtpPort;
    private final CurrentTimePort currentTimePort;
    private final Duration otpDuration;
    private final Duration requestCooldown;
    private final boolean enabled;

    public RequestAuthenticationOtpUseCase(
            GenerateOneTimePasswordPort generateOneTimePasswordPort,
            ProtectSensitiveValuePort protectSensitiveValuePort,
            SaveAuthenticationOtpChallengePort saveAuthenticationOtpChallengePort,
            LoadActiveAuthenticationOtpChallengePort loadActiveAuthenticationOtpChallengePort,
            DeliverAuthenticationOtpPort deliverAuthenticationOtpPort,
            CurrentTimePort currentTimePort,
            Duration otpDuration,
            Duration requestCooldown
    ) {
        this(
                generateOneTimePasswordPort,
                protectSensitiveValuePort,
                saveAuthenticationOtpChallengePort,
                loadActiveAuthenticationOtpChallengePort,
                deliverAuthenticationOtpPort,
                currentTimePort,
                otpDuration,
                requestCooldown,
                true
        );
    }

    public RequestAuthenticationOtpUseCase(
            GenerateOneTimePasswordPort generateOneTimePasswordPort,
            ProtectSensitiveValuePort protectSensitiveValuePort,
            SaveAuthenticationOtpChallengePort saveAuthenticationOtpChallengePort,
            LoadActiveAuthenticationOtpChallengePort loadActiveAuthenticationOtpChallengePort,
            DeliverAuthenticationOtpPort deliverAuthenticationOtpPort,
            CurrentTimePort currentTimePort,
            Duration otpDuration,
            Duration requestCooldown,
            boolean enabled
    ) {
        this.generateOneTimePasswordPort = generateOneTimePasswordPort;
        this.protectSensitiveValuePort = protectSensitiveValuePort;
        this.saveAuthenticationOtpChallengePort = saveAuthenticationOtpChallengePort;
        this.loadActiveAuthenticationOtpChallengePort = loadActiveAuthenticationOtpChallengePort;
        this.deliverAuthenticationOtpPort = deliverAuthenticationOtpPort;
        this.currentTimePort = currentTimePort;
        this.otpDuration = otpDuration;
        this.requestCooldown = requestCooldown;
        this.enabled = enabled;
    }

    public AuthenticationOtpRequestResponse requestAuthenticationOtp(RequestAuthenticationOtpRequest request) {
        requireEnabled();
        String normalizedPhoneNumber = AuthenticationPhoneNumberNormalizer.normalizePhoneNumber(request.phoneNumber());
        Instant currentInstant = currentTimePort.currentInstant();
        List<String> availableDeliveryChannels = deliverAuthenticationOtpPort.availableDeliveryChannels();
        requireDeliveryAvailable(availableDeliveryChannels);
        String resolvedDeliveryChannel = resolveDeliveryChannel(request.deliveryChannel(), availableDeliveryChannels);
        requireElectronicMailWhenNeeded(resolvedDeliveryChannel, request.emailAddress());
        requireCooldown(normalizedPhoneNumber, currentInstant);
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
        deliverAuthenticationOtpPort.deliverAuthenticationOtp(new AuthenticationOtpDeliveryRequest(
                normalizedPhoneNumber,
                resolvedDeliveryChannel,
                request.emailAddress(),
                oneTimePassword,
                expiresAt
        ));
        return new AuthenticationOtpRequestResponse(
                GENERIC_OTP_MESSAGE,
                expiresAt,
                availableDeliveryChannels,
                deliverAuthenticationOtpPort.isSimulatedDelivery()
        );
    }

    private void requireEnabled() {
        if (!enabled) {
            throw new ApplicationRuleViolationException("A autenticacao por codigo esta indisponivel.");
        }
    }

    private void requireDeliveryAvailable(List<String> availableDeliveryChannels) {
        if (availableDeliveryChannels.isEmpty()) {
            throw new ApplicationRuleViolationException("A autenticacao por codigo esta indisponivel.");
        }
    }

    private String resolveDeliveryChannel(String requestedDeliveryChannel, List<String> availableDeliveryChannels) {
        String normalizedRequestedChannel = Optional.ofNullable(requestedDeliveryChannel)
                .map(channel -> channel.trim().toUpperCase(Locale.ROOT))
                .orElse("");
        if (normalizedRequestedChannel.isBlank()) {
            return availableDeliveryChannels.getFirst();
        }
        if (!availableDeliveryChannels.contains(normalizedRequestedChannel)) {
            throw new ApplicationRuleViolationException("O canal de entrega informado esta indisponivel.");
        }
        return normalizedRequestedChannel;
    }

    private void requireElectronicMailWhenNeeded(String deliveryChannel, String emailAddress) {
        if ("EMAIL".equals(deliveryChannel) && (emailAddress == null || emailAddress.isBlank())) {
            throw new ApplicationRuleViolationException("Informe um e-mail valido para receber o codigo.");
        }
    }

    private void requireCooldown(String normalizedPhoneNumber, Instant currentInstant) {
        Optional<AuthenticationOtpChallenge> existingChallenge = loadActiveAuthenticationOtpChallengePort
                .loadActiveAuthenticationOtpChallengeByPhoneNumber(normalizedPhoneNumber);
        if (existingChallenge.isEmpty()) {
            return;
        }
        AuthenticationOtpChallenge challenge = existingChallenge.get();
        if (challenge.isExpiredAt(currentInstant)) {
            return;
        }
        Instant availableAt = challenge.createdAt().plus(requestCooldown);
        if (availableAt.isAfter(currentInstant)) {
            throw new ApplicationRuleViolationException("Aguarde um instante antes de solicitar um novo codigo.");
        }
    }
}
