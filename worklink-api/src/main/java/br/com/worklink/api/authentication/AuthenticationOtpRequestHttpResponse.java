package br.com.worklink.api.authentication;

import br.com.worklink.application.authentication.usecase.AuthenticationOtpRequestResponse;

import java.time.Instant;
import java.util.List;

public record AuthenticationOtpRequestHttpResponse(
        String message,
        Instant expiresAt,
        List<String> deliveryChannels,
        boolean simulatedDelivery
) {

    static AuthenticationOtpRequestHttpResponse fromResponse(AuthenticationOtpRequestResponse response) {
        return new AuthenticationOtpRequestHttpResponse(
                response.message(),
                response.expiresAt(),
                response.deliveryChannels(),
                response.simulatedDelivery()
        );
    }
}
