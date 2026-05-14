package br.com.worklink.application.admin.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.ResourceNotFoundException;
import br.com.worklink.application.admin.port.ModerateProfessionalReportPort;
import br.com.worklink.application.contact.port.CurrentContactTimePort;
import br.com.worklink.domain.moderation.ModerationDecision;
import br.com.worklink.domain.moderation.ModerationStatus;
import br.com.worklink.domain.report.ProfessionalReport;

public class ModerateProfessionalReportUseCase {

    private final ModerateProfessionalReportPort moderateProfessionalReportPort;
    private final CurrentContactTimePort currentContactTimePort;

    public ModerateProfessionalReportUseCase(
            ModerateProfessionalReportPort moderateProfessionalReportPort,
            CurrentContactTimePort currentContactTimePort
    ) {
        this.moderateProfessionalReportPort = moderateProfessionalReportPort;
        this.currentContactTimePort = currentContactTimePort;
    }

    public AdministrativeProfessionalReportResponse moderateProfessionalReport(ModerateProfessionalReportRequest request) {
        ProfessionalReport moderatedProfessionalReport = moderateProfessionalReportPort.moderateProfessionalReport(
                request.professionalReportIdentifier(),
                parseModerationStatus(request.moderationStatus()),
                parseModerationDecision(request.moderationDecision()),
                normalizeNotes(request.moderationNotes()),
                currentContactTimePort.currentInstant()
        ).orElseThrow(() -> new ResourceNotFoundException("Denuncia profissional nao encontrada."));
        return AdministrativeProfessionalReportResponse.fromProfessionalReport(moderatedProfessionalReport);
    }

    private ModerationStatus parseModerationStatus(String moderationStatus) {
        try {
            ModerationStatus parsedStatus = ModerationStatus.valueOf(moderationStatus);
            if (parsedStatus == ModerationStatus.PENDING) {
                throw new ApplicationRuleViolationException("O status de moderacao informado e invalido.");
            }
            return parsedStatus;
        } catch (RuntimeException exception) {
            throw new ApplicationRuleViolationException("O status de moderacao informado e invalido.", exception);
        }
    }

    private ModerationDecision parseModerationDecision(String moderationDecision) {
        if (moderationDecision == null || moderationDecision.isBlank()) {
            return null;
        }
        try {
            return ModerationDecision.valueOf(moderationDecision);
        } catch (RuntimeException exception) {
            throw new ApplicationRuleViolationException("A decisao de moderacao informada e invalida.", exception);
        }
    }

    private String normalizeNotes(String moderationNotes) {
        if (moderationNotes == null || moderationNotes.isBlank()) {
            return null;
        }
        return moderationNotes.trim();
    }
}
