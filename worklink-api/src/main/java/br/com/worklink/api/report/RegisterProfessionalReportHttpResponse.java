package br.com.worklink.api.report;

import br.com.worklink.application.report.usecase.RegisterProfessionalReportResponse;

import java.time.Instant;
import java.util.UUID;

public record RegisterProfessionalReportHttpResponse(
        UUID professionalReportIdentifier,
        UUID professionalIdentifier,
        String reportReason,
        String description,
        UUID evidenceFileIdentifier,
        boolean seriousCase,
        String authorityGuidance,
        Instant createdAt
) {

    static RegisterProfessionalReportHttpResponse fromUseCaseResponse(
            RegisterProfessionalReportResponse response
    ) {
        return new RegisterProfessionalReportHttpResponse(
                response.professionalReportIdentifier(),
                response.professionalIdentifier(),
                response.reportReason(),
                response.description(),
                response.evidenceFileIdentifier(),
                response.seriousCase(),
                response.authorityGuidance(),
                response.createdAt()
        );
    }
}
