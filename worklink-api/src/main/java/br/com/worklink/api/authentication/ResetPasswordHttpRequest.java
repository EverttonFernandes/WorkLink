package br.com.worklink.api.authentication;

public record ResetPasswordHttpRequest(
        String recoveryToken,
        String newPassword,
        String newPasswordConfirmation
) {
}
