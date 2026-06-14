package br.com.worklink.application.authentication.usecase;

public record RegisterLocalAuthenticationRequest(
        String fullName,
        String phoneNumber,
        String emailAddress,
        String password,
        boolean legalAccepted
) {
}
