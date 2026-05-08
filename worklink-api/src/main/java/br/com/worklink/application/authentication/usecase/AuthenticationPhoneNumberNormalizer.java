package br.com.worklink.application.authentication.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;

final class AuthenticationPhoneNumberNormalizer {

    private AuthenticationPhoneNumberNormalizer() {
    }

    static String normalizePhoneNumber(String rawPhoneNumber) {
        if (rawPhoneNumber == null || rawPhoneNumber.isBlank()) {
            throw new ApplicationRuleViolationException("Nao foi possivel concluir a autenticacao.");
        }
        String normalizedPhoneNumber = rawPhoneNumber.replaceAll("\\D", "");
        if (normalizedPhoneNumber.length() < 10 || normalizedPhoneNumber.length() > 15) {
            throw new ApplicationRuleViolationException("Nao foi possivel concluir a autenticacao.");
        }
        return normalizedPhoneNumber;
    }
}
