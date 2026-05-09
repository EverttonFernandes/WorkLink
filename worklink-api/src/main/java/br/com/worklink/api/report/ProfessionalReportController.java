package br.com.worklink.api.report;

import br.com.worklink.api.authorization.AuthenticatedPrincipalHttpResolver;
import br.com.worklink.application.audit.usecase.RecordSensitiveAuditEventRequest;
import br.com.worklink.application.audit.usecase.RecordSensitiveAuditEventUseCase;
import br.com.worklink.application.audit.usecase.SensitiveAuditAction;
import br.com.worklink.application.audit.usecase.SensitiveAuditOutcome;
import br.com.worklink.application.audit.usecase.SensitiveAuditTargetType;
import br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal;
import br.com.worklink.application.report.usecase.RegisterProfessionalReportRequest;
import br.com.worklink.application.report.usecase.RegisterProfessionalReportResponse;
import br.com.worklink.application.report.usecase.RegisterProfessionalReportUseCase;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/professional-reports")
public class ProfessionalReportController {

    private final AuthenticatedPrincipalHttpResolver authenticatedPrincipalHttpResolver;
    private final RegisterProfessionalReportUseCase registerProfessionalReportUseCase;
    private final RecordSensitiveAuditEventUseCase recordSensitiveAuditEventUseCase;

    public ProfessionalReportController(
            AuthenticatedPrincipalHttpResolver authenticatedPrincipalHttpResolver,
            RegisterProfessionalReportUseCase registerProfessionalReportUseCase,
            RecordSensitiveAuditEventUseCase recordSensitiveAuditEventUseCase
    ) {
        this.authenticatedPrincipalHttpResolver = authenticatedPrincipalHttpResolver;
        this.registerProfessionalReportUseCase = registerProfessionalReportUseCase;
        this.recordSensitiveAuditEventUseCase = recordSensitiveAuditEventUseCase;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    RegisterProfessionalReportHttpResponse registerProfessionalReport(
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader,
            @RequestBody RegisterProfessionalReportHttpRequest request
    ) {
        AuthenticatedPrincipal authenticatedPrincipal = authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(
                authorizationHeader
        );
        RegisterProfessionalReportResponse response =
                registerProfessionalReportUseCase.registerProfessionalReport(new RegisterProfessionalReportRequest(
                        authenticatedPrincipal,
                        request.professionalIdentifier(),
                        request.reportReason(),
                        request.description(),
                        request.evidenceFileIdentifier()
                ));
        recordSensitiveAuditEventUseCase.recordSensitiveAuditEvent(new RecordSensitiveAuditEventRequest(
                authenticatedPrincipal,
                SensitiveAuditAction.REGISTER_PROFESSIONAL_REPORT,
                SensitiveAuditTargetType.REPORT,
                response.professionalReportIdentifier(),
                SensitiveAuditOutcome.SUCCESS
        ));
        return RegisterProfessionalReportHttpResponse.fromUseCaseResponse(response);
    }
}
