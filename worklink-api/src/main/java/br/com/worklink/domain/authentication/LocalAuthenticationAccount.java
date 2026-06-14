package br.com.worklink.domain.authentication;

import br.com.worklink.domain.BusinessRuleViolationException;

import java.time.Duration;
import java.time.Instant;
import java.util.Locale;
import java.util.UUID;

public record LocalAuthenticationAccount(
        UUID customerIdentifier,
        String fullName,
        String phoneNumber,
        String normalizedEmailAddress,
        String passwordHash,
        boolean legalAccepted,
        boolean phoneVerified,
        int failedLoginAttempts,
        Instant blockedUntil,
        Instant createdAt,
        Instant updatedAt
) {

    public static LocalAuthenticationAccount register(
            UUID customerIdentifier,
            String fullName,
            String phoneNumber,
            String emailAddress,
            String passwordHash,
            boolean legalAccepted,
            Instant currentInstant
    ) {
        if (!legalAccepted) {
            throw new BusinessRuleViolationException("O aceite dos termos e obrigatorio.");
        }
        return restore(
                customerIdentifier,
                requiredText(fullName, "O nome completo e obrigatorio."),
                requiredText(phoneNumber, "O telefone e obrigatorio."),
                normalizeEmailAddress(emailAddress),
                requiredText(passwordHash, "O hash da senha e obrigatorio."),
                true,
                false,
                0,
                null,
                requiredInstant(currentInstant),
                currentInstant
        );
    }

    public static LocalAuthenticationAccount restore(
            UUID customerIdentifier,
            String fullName,
            String phoneNumber,
            String normalizedEmailAddress,
            String passwordHash,
            boolean legalAccepted,
            boolean phoneVerified,
            int failedLoginAttempts,
            Instant blockedUntil,
            Instant createdAt,
            Instant updatedAt
    ) {
        if (customerIdentifier == null) {
            throw new BusinessRuleViolationException("O identificador do cliente e obrigatorio.");
        }
        if (failedLoginAttempts < 0) {
            throw new BusinessRuleViolationException("A quantidade de falhas de login nao pode ser negativa.");
        }
        return new LocalAuthenticationAccount(
                customerIdentifier,
                requiredText(fullName, "O nome completo e obrigatorio."),
                requiredText(phoneNumber, "O telefone e obrigatorio."),
                normalizeEmailAddress(normalizedEmailAddress),
                requiredText(passwordHash, "O hash da senha e obrigatorio."),
                legalAccepted,
                phoneVerified,
                failedLoginAttempts,
                blockedUntil,
                requiredInstant(createdAt),
                requiredInstant(updatedAt)
        );
    }

    public boolean isBlockedAt(Instant currentInstant) {
        return blockedUntil != null && blockedUntil.isAfter(currentInstant);
    }

    public LocalAuthenticationAccount recordFailedLogin(
            int maximumFailedAttempts,
            Duration blockingDuration,
            Instant currentInstant
    ) {
        int nextFailedAttempts = failedLoginAttempts + 1;
        Instant nextBlockedUntil = nextFailedAttempts >= maximumFailedAttempts
                ? currentInstant.plus(blockingDuration)
                : blockedUntil;
        return restore(
                customerIdentifier, fullName, phoneNumber, normalizedEmailAddress, passwordHash,
                legalAccepted, phoneVerified, nextFailedAttempts, nextBlockedUntil, createdAt, currentInstant
        );
    }

    public LocalAuthenticationAccount clearLoginFailures(Instant currentInstant) {
        return restore(
                customerIdentifier, fullName, phoneNumber, normalizedEmailAddress, passwordHash,
                legalAccepted, phoneVerified, 0, null, createdAt, currentInstant
        );
    }

    public LocalAuthenticationAccount changePassword(String newPasswordHash, Instant currentInstant) {
        return restore(
                customerIdentifier, fullName, phoneNumber, normalizedEmailAddress, newPasswordHash,
                legalAccepted, phoneVerified, 0, null, createdAt, currentInstant
        );
    }

    public static String normalizeEmailAddress(String emailAddress) {
        String normalizedEmailAddress = requiredText(emailAddress, "O e-mail e obrigatorio.")
                .toLowerCase(Locale.ROOT);
        if (!normalizedEmailAddress.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
            throw new BusinessRuleViolationException("O e-mail informado e invalido.");
        }
        return normalizedEmailAddress;
    }

    private static String requiredText(String value, String message) {
        if (value == null || value.isBlank()) {
            throw new BusinessRuleViolationException(message);
        }
        return value.trim();
    }

    private static Instant requiredInstant(Instant instant) {
        if (instant == null) {
            throw new BusinessRuleViolationException("O momento da operacao e obrigatorio.");
        }
        return instant;
    }
}
