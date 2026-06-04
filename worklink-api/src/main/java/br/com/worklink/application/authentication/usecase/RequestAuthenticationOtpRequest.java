package br.com.worklink.application.authentication.usecase;

public record RequestAuthenticationOtpRequest(
        String phoneNumber,
        String deliveryChannel,
        String emailAddress
) {
}
