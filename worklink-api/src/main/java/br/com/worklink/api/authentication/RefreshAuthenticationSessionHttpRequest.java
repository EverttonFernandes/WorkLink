package br.com.worklink.api.authentication;

public record RefreshAuthenticationSessionHttpRequest(
        String refreshToken
) {
}
