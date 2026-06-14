package br.com.worklink.api.authentication;

public record RegisterLocalAuthenticationHttpRequest(
        String fullName,
        String phoneNumber,
        String emailAddress,
        String password,
        String passwordConfirmation,
        boolean legalAccepted
) {
}
