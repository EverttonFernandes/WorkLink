package br.com.worklink.api.authentication;

public record VerifyAuthenticationOtpHttpRequest(
        String phoneNumber,
        String oneTimePassword
) {
}
