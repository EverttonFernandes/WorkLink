package br.com.worklink.application.privacy.usecase;

public enum PersonalDataRetentionPolicy {
    UNTIL_ACCOUNT_DELETION,
    UNTIL_PROFILE_REMOVAL,
    UNTIL_SESSION_EXPIRATION,
    SHORT_OPERATIONAL_WINDOW,
    AUDIT_RETENTION_WINDOW,
    NOT_COLLECTED
}
