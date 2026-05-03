package br.com.worklink.application;

public class ApplicationRuleViolationException extends RuntimeException {

    public ApplicationRuleViolationException(String message, Throwable cause) {
        super(message, cause);
    }

    public ApplicationRuleViolationException(String message) {
        super(message);
    }
}
