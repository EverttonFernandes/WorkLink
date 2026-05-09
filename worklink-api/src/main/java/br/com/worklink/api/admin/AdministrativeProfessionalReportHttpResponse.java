package br.com.worklink.api.admin;

import br.com.worklink.application.admin.usecase.AdministrativeProfessionalReportResponse;

import java.time.Instant;
import java.util.UUID;

public record AdministrativeProfessionalReportHttpResponse(
        UUID professionalReportIdentifier,
        UUID professionalIdentifier,
        String reportReason,
        boolean seriousCase,
        UUID evidenceFileIdentifier,
        Instant createdAt
) {

    static AdministrativeProfessionalReportHttpResponse fromResponse(
            AdministrativeProfessionalReportResponse administrativeProfessionalReportResponse
    ) {
        return new AdministrativeProfessionalReportHttpResponse(
                administrativeProfessionalReportResponse.professionalReportIdentifier(),
                administrativeProfessionalReportResponse.professionalIdentifier(),
                administrativeProfessionalReportResponse.reportReason(),
                administrativeProfessionalReportResponse.seriousCase(),
                administrativeProfessionalReportResponse.evidenceFileIdentifier(),
                administrativeProfessionalReportResponse.createdAt()
        );
    }
}
