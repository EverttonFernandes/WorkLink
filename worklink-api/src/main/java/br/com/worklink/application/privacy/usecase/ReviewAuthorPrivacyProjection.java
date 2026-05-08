package br.com.worklink.application.privacy.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;

import java.util.UUID;

public record ReviewAuthorPrivacyProjection(
        UUID internalAuthorIdentifier,
        UUID publicAuthorIdentifier,
        String publicAuthorDisplayName,
        boolean anonymousToPublic
) {

    private static final String ANONYMOUS_REVIEW_AUTHOR_DISPLAY_NAME = "Usuario anonimo";

    public static ReviewAuthorPrivacyProjection fromReviewAuthor(
            UUID internalAuthorIdentifier,
            UUID publicAuthorIdentifier,
            String publicAuthorDisplayName,
            boolean anonymousToPublic
    ) {
        if (internalAuthorIdentifier == null) {
            throw new ApplicationRuleViolationException("A autoria interna da avaliacao e obrigatoria.");
        }
        if (anonymousToPublic) {
            return new ReviewAuthorPrivacyProjection(
                    internalAuthorIdentifier,
                    null,
                    ANONYMOUS_REVIEW_AUTHOR_DISPLAY_NAME,
                    true
            );
        }
        if (publicAuthorIdentifier == null) {
            throw new ApplicationRuleViolationException("A autoria publica da avaliacao identificada e obrigatoria.");
        }
        if (publicAuthorDisplayName == null || publicAuthorDisplayName.isBlank()) {
            throw new ApplicationRuleViolationException("O nome publico da avaliacao identificada e obrigatorio.");
        }
        return new ReviewAuthorPrivacyProjection(
                internalAuthorIdentifier,
                publicAuthorIdentifier,
                publicAuthorDisplayName.trim(),
                false
        );
    }
}
