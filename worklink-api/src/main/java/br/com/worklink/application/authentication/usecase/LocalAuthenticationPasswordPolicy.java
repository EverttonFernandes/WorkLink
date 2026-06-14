package br.com.worklink.application.authentication.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;

final class LocalAuthenticationPasswordPolicy {

    private static final int MINIMUM_LENGTH = 12;
    private static final int MAXIMUM_LENGTH = 128;

    private LocalAuthenticationPasswordPolicy() {
    }

    static String requireValidPassword(String password) {
        if (password == null || password.length() < MINIMUM_LENGTH || password.length() > MAXIMUM_LENGTH) {
            throw new ApplicationRuleViolationException("A senha deve possuir entre 12 e 128 caracteres.");
        }
        return password;
    }
}
