package br.com.worklink.api.authentication;

import br.com.worklink.application.authentication.usecase.AuthenticationTokenResponse;

import java.time.Instant;
import java.util.UUID;

public record AuthenticationTokenHttpResponse(
        UUID customerIdentifier,
        String accessToken,
        String refreshToken,
        Instant accessTokenExpiresAt,
        Instant refreshTokenExpiresAt
) {

    static AuthenticationTokenHttpResponse fromResponse(AuthenticationTokenResponse response) {
        return new AuthenticationTokenHttpResponse(
                response.customerIdentifier(),
                response.accessToken(),
                response.refreshToken(),
                response.accessTokenExpiresAt(),
                response.refreshTokenExpiresAt()
        );
    }
}
