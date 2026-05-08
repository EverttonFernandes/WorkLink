package br.com.worklink.application.authentication.usecase;

public record VerifyAuthenticationOtpRequest(
        String phoneNumber,
        String oneTimePassword
) {
}
