package br.com.worklink.application.authentication.usecase;

import java.time.Instant;
import java.util.List;

public record AuthenticationOtpRequestResponse(
        String message,
        Instant expiresAt,
        List<String> deliveryChannels,
        boolean simulatedDelivery
) {
}
