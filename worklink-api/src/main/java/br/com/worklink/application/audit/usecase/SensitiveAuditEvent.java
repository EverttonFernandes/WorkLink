package br.com.worklink.application.audit.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal;
import br.com.worklink.application.authorization.usecase.AuthenticatedProfile;

import java.time.Instant;
import java.util.UUID;

public record SensitiveAuditEvent(
        UUID eventIdentifier,
        UUID authorIdentifier,
        AuthenticatedProfile authorProfile,
        SensitiveAuditAction sensitiveAuditAction,
        SensitiveAuditTargetType sensitiveAuditTargetType,
        UUID targetIdentifier,
        SensitiveAuditOutcome sensitiveAuditOutcome,
        Instant occurredAt
) {

    public static SensitiveAuditEvent registerSensitiveAuditEvent(
            AuthenticatedPrincipal authenticatedPrincipal,
            SensitiveAuditAction sensitiveAuditAction,
            SensitiveAuditTargetType sensitiveAuditTargetType,
            UUID targetIdentifier,
            SensitiveAuditOutcome sensitiveAuditOutcome,
            Instant occurredAt
    ) {
        AuthenticatedPrincipal validAuthenticatedPrincipal = requireAuthenticatedPrincipal(authenticatedPrincipal);
        return new SensitiveAuditEvent(
                UUID.randomUUID(),
                validAuthenticatedPrincipal.principalIdentifier(),
                validAuthenticatedPrincipal.profile(),
                requireAction(sensitiveAuditAction),
                requireTargetType(sensitiveAuditTargetType),
                targetIdentifier,
                requireOutcome(sensitiveAuditOutcome),
                requireOccurredAt(occurredAt)
        );
    }

    public static SensitiveAuditEvent restoreSensitiveAuditEvent(
            UUID eventIdentifier,
            UUID authorIdentifier,
            AuthenticatedProfile authorProfile,
            SensitiveAuditAction sensitiveAuditAction,
            SensitiveAuditTargetType sensitiveAuditTargetType,
            UUID targetIdentifier,
            SensitiveAuditOutcome sensitiveAuditOutcome,
            Instant occurredAt
    ) {
        return new SensitiveAuditEvent(
                requireIdentifier(eventIdentifier, "O identificador do evento de auditoria e obrigatorio."),
                requireIdentifier(authorIdentifier, "O autor interno do evento de auditoria e obrigatorio."),
                requireAuthorProfile(authorProfile),
                requireAction(sensitiveAuditAction),
                requireTargetType(sensitiveAuditTargetType),
                targetIdentifier,
                requireOutcome(sensitiveAuditOutcome),
                requireOccurredAt(occurredAt)
        );
    }

    private static AuthenticatedPrincipal requireAuthenticatedPrincipal(AuthenticatedPrincipal authenticatedPrincipal) {
        if (authenticatedPrincipal == null) {
            throw new ApplicationRuleViolationException("O principal autenticado da auditoria e obrigatorio.");
        }
        return authenticatedPrincipal;
    }

    private static UUID requireIdentifier(UUID identifier, String message) {
        if (identifier == null) {
            throw new ApplicationRuleViolationException(message);
        }
        return identifier;
    }

    private static AuthenticatedProfile requireAuthorProfile(AuthenticatedProfile authorProfile) {
        if (authorProfile == null) {
            throw new ApplicationRuleViolationException("O perfil do autor da auditoria e obrigatorio.");
        }
        return authorProfile;
    }

    private static SensitiveAuditAction requireAction(SensitiveAuditAction sensitiveAuditAction) {
        if (sensitiveAuditAction == null) {
            throw new ApplicationRuleViolationException("A acao sensivel da auditoria e obrigatoria.");
        }
        return sensitiveAuditAction;
    }

    private static SensitiveAuditTargetType requireTargetType(SensitiveAuditTargetType sensitiveAuditTargetType) {
        if (sensitiveAuditTargetType == null) {
            throw new ApplicationRuleViolationException("O tipo do alvo da auditoria e obrigatorio.");
        }
        return sensitiveAuditTargetType;
    }

    private static SensitiveAuditOutcome requireOutcome(SensitiveAuditOutcome sensitiveAuditOutcome) {
        if (sensitiveAuditOutcome == null) {
            throw new ApplicationRuleViolationException("O resultado da auditoria e obrigatorio.");
        }
        return sensitiveAuditOutcome;
    }

    private static Instant requireOccurredAt(Instant occurredAt) {
        if (occurredAt == null) {
            throw new ApplicationRuleViolationException("O momento do evento de auditoria e obrigatorio.");
        }
        return occurredAt;
    }
}
