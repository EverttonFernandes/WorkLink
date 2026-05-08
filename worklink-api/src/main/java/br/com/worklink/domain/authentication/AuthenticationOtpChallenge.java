package br.com.worklink.domain.authentication;

import br.com.worklink.domain.BusinessRuleViolationException;

import java.time.Instant;
import java.util.UUID;

public record AuthenticationOtpChallenge(
        UUID challengeIdentifier,
        String phoneNumber,
        String otpHash,
        Instant expiresAt,
        int failedAttempts,
        boolean used,
        Instant createdAt
) {

    public static AuthenticationOtpChallenge requestOtpChallenge(
            String phoneNumber,
            String otpHash,
            Instant expiresAt,
            Instant createdAt
    ) {
        return restore(UUID.randomUUID(), phoneNumber, otpHash, expiresAt, 0, false, createdAt);
    }

    public static AuthenticationOtpChallenge restore(
            UUID challengeIdentifier,
            String phoneNumber,
            String otpHash,
            Instant expiresAt,
            int failedAttempts,
            boolean used,
            Instant createdAt
    ) {
        if (failedAttempts < 0) {
            throw new BusinessRuleViolationException("A quantidade de falhas do OTP nao pode ser negativa.");
        }
        return new AuthenticationOtpChallenge(
                requireIdentifier(challengeIdentifier),
                requireText(phoneNumber, "O telefone do desafio de OTP e obrigatorio."),
                requireText(otpHash, "O hash do OTP e obrigatorio."),
                requireInstant(expiresAt, "A expiracao do OTP e obrigatoria."),
                failedAttempts,
                used,
                requireInstant(createdAt, "O momento de criacao do OTP e obrigatorio.")
        );
    }

    public boolean isExpiredAt(Instant currentInstant) {
        return !expiresAt.isAfter(currentInstant);
    }

    public AuthenticationOtpChallenge recordFailedAttempt(int maximumFailedAttempts) {
        int updatedFailedAttempts = failedAttempts + 1;
        return restore(
                challengeIdentifier,
                phoneNumber,
                otpHash,
                expiresAt,
                updatedFailedAttempts,
                updatedFailedAttempts >= maximumFailedAttempts,
                createdAt
        );
    }

    public AuthenticationOtpChallenge markAsUsed() {
        return restore(challengeIdentifier, phoneNumber, otpHash, expiresAt, failedAttempts, true, createdAt);
    }

    private static UUID requireIdentifier(UUID identifier) {
        if (identifier == null) {
            throw new BusinessRuleViolationException("O identificador do desafio de OTP e obrigatorio.");
        }
        return identifier;
    }

    private static String requireText(String text, String message) {
        if (text == null || text.isBlank()) {
            throw new BusinessRuleViolationException(message);
        }
        return text.trim();
    }

    private static Instant requireInstant(Instant instant, String message) {
        if (instant == null) {
            throw new BusinessRuleViolationException(message);
        }
        return instant;
    }
}
