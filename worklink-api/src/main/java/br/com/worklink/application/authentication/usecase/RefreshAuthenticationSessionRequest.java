package br.com.worklink.application.authentication.usecase;

public record RefreshAuthenticationSessionRequest(
        String refreshToken
) {
}
