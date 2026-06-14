package br.com.worklink.application.authentication.usecase;

public record ResetPasswordRequest(String recoveryToken, String newPassword) {
}
