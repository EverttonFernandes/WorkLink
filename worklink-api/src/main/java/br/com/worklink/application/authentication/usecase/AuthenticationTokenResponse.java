package br.com.worklink.application.authentication.usecase;

import java.time.Instant;
import java.util.UUID;

public record AuthenticationTokenResponse(
        UUID customerIdentifier,
        String accessToken,
        String refreshToken,
        Instant accessTokenExpiresAt,
        Instant refreshTokenExpiresAt
) {
}
