package br.com.worklink.application.report.usecase;

import br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal;

import java.util.UUID;

public record RegisterProfessionalReportRequest(
        AuthenticatedPrincipal authenticatedPrincipal,
        UUID professionalIdentifier,
        String reportReason,
        String description,
        UUID evidenceFileIdentifier
) {
}
