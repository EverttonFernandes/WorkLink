package br.com.worklink.application.authentication.port;

import java.time.Instant;

public record IssuedAccessToken(
        String accessToken,
        Instant expiresAt
) {
}
