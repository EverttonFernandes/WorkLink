package br.com.worklink.application.authentication.usecase;

public record RevokeAuthenticationSessionRequest(
        String refreshToken
) {
}
