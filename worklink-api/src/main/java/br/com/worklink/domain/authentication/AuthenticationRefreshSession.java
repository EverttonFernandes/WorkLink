package br.com.worklink.domain.authentication;

import br.com.worklink.domain.BusinessRuleViolationException;

import java.time.Instant;
import java.util.UUID;

public record AuthenticationRefreshSession(
        UUID sessionIdentifier,
        UUID customerIdentifier,
        String refreshTokenHash,
        Instant expiresAt,
        boolean revoked,
        Instant createdAt
) {

    public static AuthenticationRefreshSession startSession(
            UUID customerIdentifier,
            String refreshTokenHash,
            Instant expiresAt,
            Instant createdAt
    ) {
        return restore(UUID.randomUUID(), customerIdentifier, refreshTokenHash, expiresAt, false, createdAt);
    }

    public static AuthenticationRefreshSession restore(
            UUID sessionIdentifier,
            UUID customerIdentifier,
            String refreshTokenHash,
            Instant expiresAt,
            boolean revoked,
            Instant createdAt
    ) {
        return new AuthenticationRefreshSession(
                requireIdentifier(sessionIdentifier, "O identificador da sessao e obrigatorio."),
                requireIdentifier(customerIdentifier, "O identificador do cliente da sessao e obrigatorio."),
                requireText(refreshTokenHash, "O hash do refresh token e obrigatorio."),
                requireInstant(expiresAt, "A expiracao do refresh token e obrigatoria."),
                revoked,
                requireInstant(createdAt, "O momento de criacao da sessao e obrigatorio.")
        );
    }

    public boolean isExpiredAt(Instant currentInstant) {
        return !expiresAt.isAfter(currentInstant);
    }

    public AuthenticationRefreshSession revoke() {
        return restore(sessionIdentifier, customerIdentifier, refreshTokenHash, expiresAt, true, createdAt);
    }

    private static UUID requireIdentifier(UUID identifier, String message) {
        if (identifier == null) {
            throw new BusinessRuleViolationException(message);
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
