package br.com.worklink.application.audit.usecase;

import br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal;

import java.util.UUID;

public record RecordSensitiveAuditEventRequest(
        AuthenticatedPrincipal authenticatedPrincipal,
        SensitiveAuditAction sensitiveAuditAction,
        SensitiveAuditTargetType sensitiveAuditTargetType,
        UUID targetIdentifier,
        SensitiveAuditOutcome sensitiveAuditOutcome
) {
}
