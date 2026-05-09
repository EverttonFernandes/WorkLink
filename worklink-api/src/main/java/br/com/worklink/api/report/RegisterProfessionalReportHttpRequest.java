package br.com.worklink.api.report;

import java.util.UUID;

public record RegisterProfessionalReportHttpRequest(
        UUID professionalIdentifier,
        String reportReason,
        String description,
        UUID evidenceFileIdentifier
) {
}
