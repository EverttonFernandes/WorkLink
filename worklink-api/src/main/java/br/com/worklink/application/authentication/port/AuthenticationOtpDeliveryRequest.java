package br.com.worklink.application.authentication.port;

import java.time.Instant;

public record AuthenticationOtpDeliveryRequest(
        String normalizedPhoneNumber,
        String deliveryChannel,
        String emailAddress,
        String rawOneTimePassword,
        Instant expiresAt
) {
}
