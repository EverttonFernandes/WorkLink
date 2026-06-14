package br.com.worklink.application;

public class InvalidAuthenticationCredentialsException extends ApplicationRuleViolationException {

    public InvalidAuthenticationCredentialsException(String message) {
        super(message);
    }
}
