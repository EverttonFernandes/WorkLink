package br.com.worklink.api.authentication;

public record RevokeAuthenticationSessionHttpRequest(
        String refreshToken
) {
}
