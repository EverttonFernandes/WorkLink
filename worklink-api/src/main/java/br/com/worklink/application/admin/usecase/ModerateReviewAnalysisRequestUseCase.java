package br.com.worklink.application.admin.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.ResourceNotFoundException;
import br.com.worklink.application.admin.port.ModerateReviewAnalysisRequestPort;
import br.com.worklink.application.contact.port.CurrentContactTimePort;
import br.com.worklink.application.review.port.UpdateProfessionalReviewVisibilityPort;
import br.com.worklink.domain.moderation.ModerationDecision;
import br.com.worklink.domain.moderation.ModerationStatus;
import br.com.worklink.domain.review.ProfessionalReviewAnalysisRequest;

public class ModerateReviewAnalysisRequestUseCase {

    private final ModerateReviewAnalysisRequestPort moderateReviewAnalysisRequestPort;
    private final UpdateProfessionalReviewVisibilityPort updateProfessionalReviewVisibilityPort;
    private final CurrentContactTimePort currentContactTimePort;

    public ModerateReviewAnalysisRequestUseCase(
            ModerateReviewAnalysisRequestPort moderateReviewAnalysisRequestPort,
            UpdateProfessionalReviewVisibilityPort updateProfessionalReviewVisibilityPort,
            CurrentContactTimePort currentContactTimePort
    ) {
        this.moderateReviewAnalysisRequestPort = moderateReviewAnalysisRequestPort;
        this.updateProfessionalReviewVisibilityPort = updateProfessionalReviewVisibilityPort;
        this.currentContactTimePort = currentContactTimePort;
    }

    public AdministrativeReviewAnalysisRequestResponse moderateReviewAnalysisRequest(
            ModerateReviewAnalysisRequest request
    ) {
        ModerationDecision moderationDecision = parseModerationDecision(request.moderationDecision());
        ProfessionalReviewAnalysisRequest moderatedReviewAnalysisRequest = moderateReviewAnalysisRequestPort
                .moderateReviewAnalysisRequest(
                        request.reviewAnalysisRequestIdentifier(),
                        parseModerationStatus(request.moderationStatus()),
                        moderationDecision,
                        normalizeNotes(request.moderationNotes()),
                        currentContactTimePort.currentInstant()
                )
                .orElseThrow(() -> new ResourceNotFoundException("Contestacao de avaliacao nao encontrada."));

        updateProfessionalReviewVisibilityPort.updateProfessionalReviewVisibility(
                moderatedReviewAnalysisRequest.professionalReviewIdentifier(),
                moderationDecision == ModerationDecision.HIDE_FROM_PUBLIC
        );
        return AdministrativeReviewAnalysisRequestResponse.fromReviewAnalysisRequest(moderatedReviewAnalysisRequest);
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
            throw new ApplicationRuleViolationException("A decisao de moderacao da avaliacao e obrigatoria.");
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
