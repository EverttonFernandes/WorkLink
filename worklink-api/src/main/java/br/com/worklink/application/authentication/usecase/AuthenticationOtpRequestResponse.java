package br.com.worklink.application.authentication.usecase;

import java.time.Instant;

public record AuthenticationOtpRequestResponse(
        String message,
        Instant expiresAt
) {
}
