package br.com.worklink.domain.authentication;

import br.com.worklink.domain.BusinessRuleViolationException;

import java.time.Instant;
import java.util.UUID;

public record PasswordRecoveryChallenge(
        UUID challengeIdentifier,
        UUID customerIdentifier,
        String tokenHash,
        Instant expiresAt,
        boolean used,
        Instant createdAt
) {

    public static PasswordRecoveryChallenge request(
            UUID customerIdentifier,
            String tokenHash,
            Instant expiresAt,
            Instant createdAt
    ) {
        return restore(UUID.randomUUID(), customerIdentifier, tokenHash, expiresAt, false, createdAt);
    }

    public static PasswordRecoveryChallenge restore(
            UUID challengeIdentifier,
            UUID customerIdentifier,
            String tokenHash,
            Instant expiresAt,
            boolean used,
            Instant createdAt
    ) {
        if (challengeIdentifier == null || customerIdentifier == null) {
            throw new BusinessRuleViolationException("Os identificadores da recuperacao sao obrigatorios.");
        }
        if (tokenHash == null || tokenHash.isBlank() || expiresAt == null || createdAt == null) {
            throw new BusinessRuleViolationException("Os dados da recuperacao sao obrigatorios.");
        }
        return new PasswordRecoveryChallenge(
                challengeIdentifier, customerIdentifier, tokenHash.trim(), expiresAt, used, createdAt
        );
    }

    public boolean isExpiredAt(Instant currentInstant) {
        return !expiresAt.isAfter(currentInstant);
    }

    public PasswordRecoveryChallenge use() {
        return restore(challengeIdentifier, customerIdentifier, tokenHash, expiresAt, true, createdAt);
    }
}
