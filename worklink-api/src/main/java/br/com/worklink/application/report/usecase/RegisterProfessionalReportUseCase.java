package br.com.worklink.application.report.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.AuthenticationRequiredException;
import br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal;
import br.com.worklink.application.contact.port.CurrentContactTimePort;
import br.com.worklink.application.professional.port.LoadProfessionalByIdentifierPort;
import br.com.worklink.application.report.port.SaveProfessionalReportPort;
import br.com.worklink.domain.BusinessRuleViolationException;
import br.com.worklink.domain.report.ProfessionalReport;
import br.com.worklink.domain.report.ProfessionalReportReason;

public class RegisterProfessionalReportUseCase {

    private final LoadProfessionalByIdentifierPort loadProfessionalByIdentifierPort;
    private final SaveProfessionalReportPort saveProfessionalReportPort;
    private final CurrentContactTimePort currentContactTimePort;

    public RegisterProfessionalReportUseCase(
            LoadProfessionalByIdentifierPort loadProfessionalByIdentifierPort,
            SaveProfessionalReportPort saveProfessionalReportPort,
            CurrentContactTimePort currentContactTimePort
    ) {
        this.loadProfessionalByIdentifierPort = loadProfessionalByIdentifierPort;
        this.saveProfessionalReportPort = saveProfessionalReportPort;
        this.currentContactTimePort = currentContactTimePort;
    }

    public RegisterProfessionalReportResponse registerProfessionalReport(RegisterProfessionalReportRequest request) {
        AuthenticatedPrincipal authenticatedPrincipal = requireAuthenticatedPrincipal(request.authenticatedPrincipal());
        loadProfessionalByIdentifierPort.loadProfessionalByIdentifier(request.professionalIdentifier())
                .orElseThrow(() -> new ApplicationRuleViolationException("O profissional denunciado nao foi encontrado."));
        try {
            ProfessionalReport professionalReport = ProfessionalReport.registerProfessionalReport(
                    request.professionalIdentifier(),
                    authenticatedPrincipal.principalIdentifier(),
                    parseReportReason(request.reportReason()),
                    request.description(),
                    request.evidenceFileIdentifier(),
                    currentContactTimePort.currentInstant()
            );
            return RegisterProfessionalReportResponse.fromProfessionalReport(
                    saveProfessionalReportPort.saveProfessionalReport(professionalReport)
            );
        } catch (BusinessRuleViolationException exception) {
            throw new ApplicationRuleViolationException("A denuncia profissional informada e invalida.", exception);
        }
    }

    private ProfessionalReportReason parseReportReason(String reportReason) {
        try {
            return ProfessionalReportReason.valueOf(reportReason);
        } catch (RuntimeException exception) {
            throw new ApplicationRuleViolationException("A denuncia profissional informada e invalida.", exception);
        }
    }

    private AuthenticatedPrincipal requireAuthenticatedPrincipal(AuthenticatedPrincipal authenticatedPrincipal) {
        if (authenticatedPrincipal == null) {
            throw new AuthenticationRequiredException("Autenticacao obrigatoria para denunciar profissional.");
        }
        return authenticatedPrincipal;
    }
}
