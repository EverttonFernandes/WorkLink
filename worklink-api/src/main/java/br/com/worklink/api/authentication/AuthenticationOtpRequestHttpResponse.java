package br.com.worklink.api.authentication;

import br.com.worklink.application.authentication.usecase.AuthenticationOtpRequestResponse;

import java.time.Instant;

public record AuthenticationOtpRequestHttpResponse(
        String message,
        Instant expiresAt
) {

    static AuthenticationOtpRequestHttpResponse fromResponse(AuthenticationOtpRequestResponse response) {
        return new AuthenticationOtpRequestHttpResponse(response.message(), response.expiresAt());
    }
}
