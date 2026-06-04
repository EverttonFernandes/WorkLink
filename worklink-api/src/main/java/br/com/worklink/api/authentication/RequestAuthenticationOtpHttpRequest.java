package br.com.worklink.api.authentication;

public record RequestAuthenticationOtpHttpRequest(
        String phoneNumber,
        String deliveryChannel,
        String emailAddress
) {
}
